module integrals
    implicit none

    private
    public :: oneint,twoint

    integer, parameter :: wp = selected_real_kind(15)

    real(wp), parameter :: pi = 4.0_wp*atan(1.0_wp)
    real(wp), parameter :: tpi = 2.0_wp*pi
    real(wp), parameter :: twopi25 = 2.0_wp*pi**(2.5_wp)

contains

!> one electron integrals over spherical gaussian functions
pure subroutine oneint(xyz, chrg, r_a, r_b, alp, bet, ci, cj, sab, tab, vab)

    implicit none

    !> position of all atoms in atomic units
    real(wp), intent(in)  :: xyz(:, :)
    !> nuclear charges
    real(wp), intent(in)  :: chrg(:)
    !> aufpunkt of gaussians
    real(wp), intent(in)  :: r_a(:)
    real(wp), intent(in)  :: r_b(:)
    !> gaussian exponents of the primitives
    real(wp), intent(in)  :: alp(:)
    real(wp), intent(in)  :: bet(:)
    !> contraction coeffients with normalisation constants of primitives
    real(wp), intent(in)  :: ci(:)
    real(wp), intent(in)  :: cj(:)

    !> overlap integral <a|b>
    real(wp), intent(out) :: sab
    !> kinetic energy integral <a|T|b>
    real(wp), intent(out) :: tab
    !> nuclear attraction integrals <a|Σ z/r|b>
    real(wp), intent(out) :: vab

    !> number of primitives
    integer :: npa
    integer :: npb
    !> number of atoms in the system
    integer :: nat
    !> local variables
    integer  :: i,j,k
    real(wp) :: rab,ab,eab,oab,xab,est
    real(wp) :: s00,fact,rcp,r_p(3),cab

    intrinsic :: sum,sqrt,exp

    nat = min(size(xyz, dim=2), size(chrg))
    npa = min(size(alp), size(ci))
    npb = min(size(bet), size(cj))

    sab = 0.0_wp
    tab = 0.0_wp
    vab = 0.0_wp

    rab = sum( (r_a-r_b)**2 )

    do i=1,npa
        do j=1,npb
            eab = alp(i)+bet(j)
            oab = 1.0_wp/eab
            cab = ci(i)*cj(j)
            xab = alp(i)*bet(j)*oab
            est = rab*xab
            ab = exp(-est)
            s00 = cab*ab*sqrt(pi*oab)**3

            !        overlap
            sab = sab+s00

            !        kinetic energy
            tab = tab + xab*(3.0_wp-2.0_wp*est)*s00

            !        nuclear attraction
            fact = cab*tpi*oab*ab
            r_p = (alp(i)*r_a+bet(j)*r_b)*oab
            do k = 1, nat
                rcp = sum( (r_p-xyz(:,k))**2 )
                vab  = vab - fact*chrg(k)*boysf0(eab*rcp)
            enddo

        enddo
    enddo

end subroutine oneint

!> two-electron repulsion integral (ab|cd) over spherical gaussian functions
!  quantity is given in chemist's notation
pure subroutine twoint(r_a, r_b, r_c, r_d, alp, bet, gam, del, ci, cj, ck, cl, tei)

    implicit none

    !> aufpunkte of gaussians
    real(wp), intent(in)  :: r_a(:)
    real(wp), intent(in)  :: r_b(:)
    real(wp), intent(in)  :: r_c(:)
    real(wp), intent(in)  :: r_d(:)
    !> gaussian exponents of the primitives
    real(wp), intent(in)  :: alp(:)
    real(wp), intent(in)  :: bet(:)
    real(wp), intent(in)  :: gam(:)
    real(wp), intent(in)  :: del(:)
    !> contraction coeffients with normalisation constants of primitives
    real(wp), intent(in)  :: ci(:)
    real(wp), intent(in)  :: cj(:)
    real(wp), intent(in)  :: ck(:)
    real(wp), intent(in)  :: cl(:)

    !> two electron integral (ab|cd) in chemist notation
    real(wp), intent(out) :: tei

    !> number of primitives
    integer :: npa, npb, npc, npd
    integer :: i,j,k,l
    real(wp) :: rab,rcd,rpq,r_p(3),r_q(3),est
    real(wp) :: eab,ecd,eabcd,epq,oab,ocd,cab,ccd
    real(wp) :: ab,cd,abcd,pq

    intrinsic :: sum,sqrt,exp

    npa = min(size(alp), size(ci))
    npb = min(size(bet), size(cj))
    npc = min(size(gam), size(ck))
    npd = min(size(del), size(cl))

    tei = 0.0_wp

    !  R²(a-b)
    rab=sum( (r_a-r_b)**2 )
    !  R²(c-d)
    rcd=sum( (r_c-r_d)**2 )

    do i = 1, npa
        do j = 1, npb
            cab = ci(i)*cj(j)
            eab = alp(i)+bet(j)
            oab = 1.0_wp/eab
            est = alp(i)*bet(j)*rab*oab
            ab = exp(-est)

            !        new gaussian at r_p
            r_p = (alp(i)*r_a+bet(j)*r_b)*oab

            do k = 1, npc
                do l = 1, npd
                    ccd = ck(k)*cl(l)
                    ecd = gam(k)+del(l)
                    ocd = 1.0_wp/ecd
                    est = gam(k)*del(l)*rcd*ocd
                    cd = exp(-est)

                    !              new gaussian at r_q
                    r_q = (gam(k)*r_c+del(l)*r_d)*ocd

                    abcd = ab*cd

                    !              distance between product gaussians
                    rpq = sum( (r_p-r_q)**2 )

                    epq = eab*ecd
                    eabcd = eab+ecd

                    pq = rpq*epq/eabcd
                    tei = tei + cab*ccd*abcd * twopi25/(epq*sqrt(eabcd)) &
                        &           * boysf0(pq)

                enddo
            enddo
        enddo
    enddo

end subroutine twoint

!> zeroth order boys function
pure elemental function boysf0(arg) result(boys)
    implicit none
    real(wp),intent(in) :: arg
    real(wp) :: boys

    intrinsic :: sqrt,erf

    !> six term taylor expansion is suffient for precisions of 10e-14,
    !  use analyical expression for all other term
    if (arg.lt.0.05_wp) then
        boys = 1.0_wp - 3.333333333333333e-1_wp * arg    &
            &         + 6.666666666666666e-2_wp * arg**2 &
            &         - 4.761904761904761e-3_wp * arg**3 &
            &         + 1.763668430335097e-4_wp * arg**4 &
            &         - 4.008337341670675e-6_wp * arg**5
    else
        boys = 0.5_wp*sqrt(pi/arg)*erf(sqrt(arg))
    endif

end function boysf0

end module integrals
