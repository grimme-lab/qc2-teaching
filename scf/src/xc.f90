module xc
    implicit none

    private
    public :: vwn5_correlation, pw92_correlation, pbe_exchange, pbe_correlation

    integer, parameter :: wp = selected_real_kind(15)
    real(wp), parameter :: pi = 4.0_wp*atan(1.0_wp)

    !> density threshold below which all outputs are set to zero
    real(wp), parameter :: rho_thr = 1.0e-15_wp

    !> VWN-5 parameters
    !! S.H. Vosko, L. Wilk, M. Nusair, Can. J. Phys. 58, 1200 (1980)
    real(wp), parameter :: vwn_A  =  0.0621814_wp
    real(wp), parameter :: vwn_b  =  3.72744_wp
    real(wp), parameter :: vwn_c  = 12.9352_wp
    real(wp), parameter :: vwn_x0 = -0.10498_wp

    !> PW92 parameters (unpolarized electron gas)
    !! J.P. Perdew, Y. Wang, Phys. Rev. B 45, 13244 (1992)
    real(wp), parameter :: pw92_A  = 0.0310907_wp
    real(wp), parameter :: pw92_a1 = 0.21370_wp
    real(wp), parameter :: pw92_b1 = 7.5957_wp
    real(wp), parameter :: pw92_b2 = 3.5876_wp
    real(wp), parameter :: pw92_b3 = 1.6382_wp
    real(wp), parameter :: pw92_b4 = 0.49294_wp

    !> PBE exchange parameters
    !! J.P. Perdew, K. Burke, M. Ernzerhof, PRL 77, 3865 (1996)
    real(wp), parameter :: pbe_kappa = 0.8040_wp
    real(wp), parameter :: pbe_mu    = 0.2195149727645171_wp

    !> PBE correlation parameters
    real(wp), parameter :: pbe_gamma = 0.03109069086965489503494086371273_wp
    real(wp), parameter :: pbe_beta  = 0.06672455060314922_wp

contains

!> VWN-5 correlation energy density and potential (spin-unpolarized)
!!
!! Returns the correlation energy density per particle eps_c and the
!! correlation potential v_c = d(rho*eps_c)/drho for a given density rho.
    subroutine vwn5_correlation(rho, eps_c, v_c)
        real(wp), intent(in)  :: rho
        real(wp), intent(out) :: eps_c, v_c

        real(wp) :: rs, x, Xx, Xx0, Q, decdx

        if (rho < rho_thr) then
            eps_c = 0.0_wp
            v_c   = 0.0_wp
            return
        end if

        ! Wigner-Seitz radius
        rs = (3.0_wp/(4.0_wp*pi*rho))**(1.0_wp/3.0_wp)
        x  = sqrt(rs)

        ! X(x) = x^2 + b*x + c
        Xx  = x*x + vwn_b*x + vwn_c
        Xx0 = vwn_x0*vwn_x0 + vwn_b*vwn_x0 + vwn_c
        Q   = sqrt(4.0_wp*vwn_c - vwn_b*vwn_b)

        ! energy density
        eps_c = 0.5_wp*vwn_A*( &
            log(x*x/Xx) &
            + (2.0_wp*vwn_b/Q)*atan(Q/(2.0_wp*x + vwn_b)) &
            - (vwn_b*vwn_x0/Xx0)*( &
                log((x - vwn_x0)**2/Xx) &
                + (2.0_wp*(vwn_b + 2.0_wp*vwn_x0)/Q) &
                    *atan(Q/(2.0_wp*x + vwn_b)) &
            ) &
        )

        ! derivative d(eps_c)/dx
        decdx = 0.5_wp*vwn_A*( &
            2.0_wp/x - (2.0_wp*x + 2.0_wp*vwn_b)/Xx &
            - (vwn_b*vwn_x0/Xx0)*( &
                2.0_wp/(x - vwn_x0) &
                - 2.0_wp*(x + vwn_b + vwn_x0)/Xx &
            ) &
        )

        ! potential: v_c = eps_c - (x/6) * d(eps_c)/dx
        v_c = eps_c - (x/6.0_wp)*decdx

    end subroutine vwn5_correlation


!> PW92 correlation energy density and potential (spin-unpolarized)
!!
!! J.P. Perdew, Y. Wang, Phys. Rev. B 45, 13244 (1992)
!! This is the LDA correlation used internally by PBE correlation.
    subroutine pw92_correlation(rho, eps_c, v_c)
        real(wp), intent(in)  :: rho
        real(wp), intent(out) :: eps_c, v_c

        real(wp) :: rs, srs, Q, dQdrs, G, dGdrs, F, dFdrs

        if (rho < rho_thr) then
            eps_c = 0.0_wp
            v_c   = 0.0_wp
            return
        end if

        rs  = (3.0_wp/(4.0_wp*pi*rho))**(1.0_wp/3.0_wp)
        srs = sqrt(rs)

        ! Q(rs) = 2A(b1*rs^(1/2) + b2*rs + b3*rs^(3/2) + b4*rs^2)
        Q = 2.0_wp*pw92_A*(pw92_b1*srs + pw92_b2*rs &
            + pw92_b3*srs*rs + pw92_b4*rs*rs)

        ! dQ/drs
        dQdrs = 2.0_wp*pw92_A*(pw92_b1/(2.0_wp*srs) + pw92_b2 &
            + 1.5_wp*pw92_b3*srs + 2.0_wp*pw92_b4*rs)

        ! G(rs) = -2A(1 + a1*rs)  [prefactor]
        G = -2.0_wp*pw92_A*(1.0_wp + pw92_a1*rs)
        dGdrs = -2.0_wp*pw92_A*pw92_a1

        ! F(rs) = ln(1 + 1/Q)  [log term]
        F = log(1.0_wp + 1.0_wp/Q)
        dFdrs = -dQdrs/(Q*(Q + 1.0_wp))

        ! eps_c = G * F
        eps_c = G*F

        ! v_c = eps_c - (rs/3) * d(eps_c)/d(rs)
        v_c = eps_c - (rs/3.0_wp)*(dGdrs*F + G*dFdrs)

    end subroutine pw92_correlation


!> PBE exchange energy density, potential and sigma-derivative
!!
!! Returns the PBE exchange energy density per particle eps_x,
!! vrho = d(rho*eps_x)/drho, and vsigma = d(rho*eps_x)/dsigma
!! where sigma = |nabla rho|^2.
    subroutine pbe_exchange(rho, sigma, eps_x, vrho, vsigma)
        real(wp), intent(in)  :: rho, sigma
        real(wp), intent(out) :: eps_x, vrho, vsigma

        real(wp) :: ex_lda, kf2, s2, denom, Fx, dFds2

        if (rho < rho_thr) then
            eps_x  = 0.0_wp
            vrho   = 0.0_wp
            vsigma = 0.0_wp
            return
        end if

        ! LDA exchange energy density per particle
        ! eps_x^LDA = -(3/4)(3/pi)^(1/3) rho^(1/3)
        ex_lda = -0.75_wp*(3.0_wp/pi)**(1.0_wp/3.0_wp)*rho**(1.0_wp/3.0_wp)

        ! s^2 = sigma / (4 * (3*pi^2)^(2/3) * rho^(8/3))
        kf2 = (3.0_wp*pi*pi)**(2.0_wp/3.0_wp)
        s2  = sigma/(4.0_wp*kf2*rho**(8.0_wp/3.0_wp))

        ! enhancement factor F_x = 1 + kappa - kappa/(1 + mu*s^2/kappa)
        denom = 1.0_wp + pbe_mu*s2/pbe_kappa
        Fx    = 1.0_wp + pbe_kappa - pbe_kappa/denom

        ! dF_x/d(s^2) = mu / (1 + mu*s^2/kappa)^2
        dFds2 = pbe_mu/denom**2

        ! energy density
        eps_x = ex_lda*Fx

        ! potential: d(rho*eps_x)/drho
        ! = (4/3)*ex_lda*Fx - (8/3)*ex_lda*s2*dFds2
        vrho = (4.0_wp/3.0_wp)*ex_lda*Fx &
             - (8.0_wp/3.0_wp)*ex_lda*s2*dFds2

        ! sigma-derivative: d(rho*eps_x)/dsigma
        ! = rho*ex_lda*dFds2 / (4*kf2*rho^(8/3))
        vsigma = ex_lda*dFds2/(4.0_wp*kf2*rho**(5.0_wp/3.0_wp))

    end subroutine pbe_exchange


!> PBE correlation energy density, potential and sigma-derivative
!!
!! Uses PW92 as the LDA correlation base, consistent with the original
!! PBE paper (Perdew, Burke, Ernzerhof, PRL 77, 3865, 1996).
!!
!! Returns the PBE correlation energy density per particle eps_c,
!! vrho = d(rho*eps_c)/drho, and vsigma = d(rho*eps_c)/dsigma
!! where sigma = |nabla rho|^2.
    subroutine pbe_correlation(rho, sigma, eps_c, vrho, vsigma)
        real(wp), intent(in)  :: rho, sigma
        real(wp), intent(out) :: eps_c, vrho, vsigma

        real(wp) :: e0, v0, de0drho
        real(wp) :: ks2, t2
        real(wp) :: argexp, expval, A, dAdrho
        real(wp) :: At2, A2t4, fAtden, fAtden2
        real(wp) :: P, dPdt2, dPdA
        real(wp) :: dt2drho, dt2dsigma
        real(wp) :: arglog, H, dHdrho, dHdsigma

        if (rho < rho_thr) then
            eps_c  = 0.0_wp
            vrho   = 0.0_wp
            vsigma = 0.0_wp
            return
        end if

        ! LDA correlation (PW92)
        call pw92_correlation(rho, e0, v0)

        ! Thomas-Fermi screening: ks^2 = 4*(3*pi^2)^(1/3)*rho^(1/3)/pi
        ks2 = 4.0_wp*(3.0_wp*pi*pi)**(1.0_wp/3.0_wp)*rho**(1.0_wp/3.0_wp)/pi

        ! reduced density gradient squared: t^2 = sigma/(4*ks^2*rho^2)
        t2 = sigma/(4.0_wp*ks2*rho*rho)

        ! A = (beta/gamma) / [exp(-e0/gamma) - 1]
        argexp = -e0/pbe_gamma
        if (abs(argexp) < 40.0_wp) then
            expval = exp(argexp)
        else
            expval = 0.0_wp
        end if
        A = (pbe_beta/pbe_gamma)/(expval - 1.0_wp)

        ! convenience
        At2    = A*t2
        A2t4   = At2*At2
        fAtden = 1.0_wp + At2 + A2t4
        fAtden2 = fAtden*fAtden

        ! P = (beta/gamma)*t^2*(1+A*t^2)/(1+A*t^2+A^2*t^4)
        P = (pbe_beta/pbe_gamma)*t2*(1.0_wp + At2)/fAtden

        ! arglog = 1 + P
        arglog = 1.0_wp + P

        ! H = gamma * ln(arglog)   [phi=1 for spin-restricted]
        H = pbe_gamma*log(arglog)

        ! energy density
        eps_c = e0 + H

        ! --- derivatives for the potential ---

        ! dP/dt^2 = (beta/gamma) * (1 + 2*A*t^2) / (1+At^2+A^2t^4)^2
        dPdt2 = (pbe_beta/pbe_gamma)*(1.0_wp + 2.0_wp*At2)/fAtden2

        ! dP/dA = -(beta/gamma) * A * t^6 * (2+At^2) / (1+At^2+A^2t^4)^2
        dPdA = -(pbe_beta/pbe_gamma)*A*t2*t2*t2*(2.0_wp + At2)/fAtden2

        ! dt^2/drho = -(7/3)*t^2/rho
        dt2drho = -(7.0_wp/3.0_wp)*t2/rho

        ! dt^2/dsigma = 1/(4*ks^2*rho^2)
        dt2dsigma = 1.0_wp/(4.0_wp*ks2*rho*rho)

        ! dA/drho = A*exp(-e0/gamma)/((exp(-e0/gamma)-1)*gamma) * de0/drho
        ! where de0/drho = (v0 - e0)/rho
        de0drho = (v0 - e0)/rho
        dAdrho  = A*expval/((expval - 1.0_wp)*pbe_gamma)*de0drho

        ! dH/drho and dH/dsigma
        dHdrho   = pbe_gamma/arglog*(dPdt2*dt2drho + dPdA*dAdrho)
        dHdsigma = pbe_gamma/arglog*dPdt2*dt2dsigma

        ! vrho = d(rho*eps_c)/drho = v0 + H + rho*dH/drho
        vrho = v0 + H + rho*dHdrho

        ! vsigma = d(rho*eps_c)/dsigma = rho*dH/dsigma
        vsigma = rho*dHdsigma

    end subroutine pbe_correlation

end module xc
