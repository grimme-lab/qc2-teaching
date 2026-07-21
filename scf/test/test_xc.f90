program test_xc
    use xc, only: vwn5_correlation, pbe_exchange, pbe_correlation
    implicit none

    integer, parameter :: wp = selected_real_kind(15)

    logical :: all_passed

    all_passed = .true.

    ! --- VWN-5 correlation ---
    call test_vwn5_zero_density(all_passed)
    call test_vwn5_potential_numerical(all_passed)
    call test_vwn5_libxc(all_passed)

    ! --- PBE exchange ---
    call test_pbe_x_zero_density(all_passed)
    call test_pbe_x_lda_limit(all_passed)
    call test_pbe_x_potential_numerical(all_passed)
    call test_pbe_x_libxc(all_passed)

    ! --- PBE correlation ---
    call test_pbe_c_zero_density(all_passed)
    call test_pbe_c_lda_limit(all_passed)
    call test_pbe_c_potential_numerical(all_passed)
    call test_pbe_c_libxc(all_passed)

    if (.not. all_passed) then
        write (*, '(a)') 'SOME TESTS FAILED'
        error stop 1
    end if
    write (*, '(a)') 'ALL TESTS PASSED'

contains

! ================================================================
!  Helpers
! ================================================================

!> compare against a libxc reference value for VWN-5
!! libxc convention: zk = rho*eps_c (energy per volume), vrhoa = d(zk)/d(rhoa)
!! for unpolarized: rho = 2*rhoa, eps = zk/rho, vrho = vrhoa
    subroutine check_vwn_ref(passed, label, rhoa, zk_ref, vrhoa_ref, tol)
        logical, intent(inout) :: passed
        character(len=*), intent(in) :: label
        real(wp), intent(in) :: rhoa, zk_ref, vrhoa_ref, tol

        real(wp) :: rho, eps_c, v_c
        real(wp) :: eps_ref, err_e, err_v

        rho = 2.0_wp*rhoa
        call vwn5_correlation(rho, eps_c, v_c)

        eps_ref = zk_ref/rho
        err_e = abs(eps_c - eps_ref)/abs(eps_ref)
        err_v = abs(v_c - vrhoa_ref)/abs(vrhoa_ref)

        if (err_e > tol .or. err_v > tol) then
            write (*, '(a,a,a,es10.3,a,es10.3)') 'FAIL ', label, &
                '  rel_e=', err_e, '  rel_v=', err_v
            passed = .false.
        else
            write (*, '(a,a)') 'PASS ', label
        end if
    end subroutine check_vwn_ref

!> compare against a libxc reference value for a GGA functional
!! for unpolarized: rho = 2*rhoa, sigma = 4*sigmaaa
!! vsigma = (vsigmaaa + vsigmaab + vsigmabb) / 4
    subroutine check_gga_ref(passed, label, func, rhoa, sigmaaa, &
            zk_ref, vrhoa_ref, vsigmaaa_ref, vsigmaab_ref, vsigmabb_ref, tol)
        logical, intent(inout) :: passed
        character(len=*), intent(in) :: label
        character(len=1), intent(in) :: func  ! 'x' or 'c'
        real(wp), intent(in) :: rhoa, sigmaaa
        real(wp), intent(in) :: zk_ref, vrhoa_ref
        real(wp), intent(in) :: vsigmaaa_ref, vsigmaab_ref, vsigmabb_ref
        real(wp), intent(in) :: tol

        real(wp) :: rho, sigma, eps, vrho, vsigma
        real(wp) :: eps_ref, vsigma_ref
        real(wp) :: err_e, err_v, err_s

        rho   = 2.0_wp*rhoa
        sigma = 4.0_wp*sigmaaa

        if (func == 'x') then
            call pbe_exchange(rho, sigma, eps, vrho, vsigma)
        else
            call pbe_correlation(rho, sigma, eps, vrho, vsigma)
        end if

        eps_ref    = zk_ref/rho
        vsigma_ref = (vsigmaaa_ref + vsigmaab_ref + vsigmabb_ref)/4.0_wp

        err_e = abs(eps - eps_ref)/abs(eps_ref)
        err_v = abs(vrho - vrhoa_ref)/abs(vrhoa_ref)
        err_s = abs(vsigma - vsigma_ref)/abs(vsigma_ref)

        if (err_e > tol .or. err_v > tol .or. err_s > tol) then
            write (*, '(a,a,a,3es10.3)') 'FAIL ', label, &
                '  rel(e,v,s)=', err_e, err_v, err_s
            passed = .false.
        else
            write (*, '(a,a)') 'PASS ', label
        end if
    end subroutine check_gga_ref

! ================================================================
!  VWN-5 tests
! ================================================================

!> VWN-5 should return zeros for zero density
    subroutine test_vwn5_zero_density(passed)
        logical, intent(inout) :: passed
        real(wp) :: eps_c, v_c

        call vwn5_correlation(0.0_wp, eps_c, v_c)

        if (eps_c /= 0.0_wp .or. v_c /= 0.0_wp) then
            write (*, '(a)') 'FAIL test_vwn5_zero_density'
            passed = .false.
        else
            write (*, '(a)') 'PASS test_vwn5_zero_density'
        end if
    end subroutine test_vwn5_zero_density

!> verify VWN-5 potential by numerical differentiation of rho*eps_c
    subroutine test_vwn5_potential_numerical(passed)
        logical, intent(inout) :: passed
        real(wp) :: rho, h, eps_p, v_p, eps_m, v_m, eps_c, v_c
        real(wp) :: v_num, rel_err

        rho = 0.1_wp
        h   = 1.0e-6_wp

        call vwn5_correlation(rho + h, eps_p, v_p)
        call vwn5_correlation(rho - h, eps_m, v_m)
        call vwn5_correlation(rho, eps_c, v_c)

        v_num = ((rho + h)*eps_p - (rho - h)*eps_m)/(2.0_wp*h)
        rel_err = abs(v_c - v_num)/abs(v_c)

        if (rel_err > 1.0e-6_wp) then
            write (*, '(a,es12.5,a,es12.5,a,es8.1)') &
                'FAIL test_vwn5_potential_numerical: v_c=', v_c, &
                ' v_num=', v_num, ' rel_err=', rel_err
            passed = .false.
        else
            write (*, '(a,es8.1)') 'PASS test_vwn5_potential_numerical  rel_err=', rel_err
        end if
    end subroutine test_vwn5_potential_numerical

!> compare VWN-5 against libxc reference data (test/refs/lda_c_vwn.data)
    subroutine test_vwn5_libxc(passed)
        logical, intent(inout) :: passed
        real(wp), parameter :: tol = 1.0e-11_wp

        ! rhoa=1.7, rhob=1.7, sigma~0
        call check_vwn_ref(passed, 'vwn5_libxc  rho=3.40 ', &
            1.7_wp, -0.278978177367_wp, -0.0907896301530_wp, tol)

        ! rhoa=1.5, rhob=1.5
        call check_vwn_ref(passed, 'vwn5_libxc  rho=3.00 ', &
            1.5_wp, -0.242883397986_wp, -0.0896613951966_wp, tol)

        ! rhoa=0.088, rhob=0.088
        call check_vwn_ref(passed, 'vwn5_libxc  rho=0.176', &
            0.088_wp, -0.0101483720780_wp, -0.0653289336535_wp, tol)

        ! rhoa=0.26, rhob=0.26
        call check_vwn_ref(passed, 'vwn5_libxc  rho=0.52 ', &
            0.26_wp, -0.0344300981310_wp, -0.0743196778205_wp, tol)

        ! rhoa=0.15, rhob=0.15
        call check_vwn_ref(passed, 'vwn5_libxc  rho=0.30 ', &
            0.15_wp, -0.0185432270230_wp, -0.0697024933328_wp, tol)

        ! rhoa=1800, rhob=1800 (high density)
        call check_vwn_ref(passed, 'vwn5_libxc  rho=3600 ', &
            1800.0_wp, -0.532741477023e+03_wp, -0.157944671704_wp, tol)
    end subroutine test_vwn5_libxc

! ================================================================
!  PBE exchange tests
! ================================================================

!> PBE exchange should return zeros for zero density
    subroutine test_pbe_x_zero_density(passed)
        logical, intent(inout) :: passed
        real(wp) :: eps_x, vrho, vsigma

        call pbe_exchange(0.0_wp, 0.0_wp, eps_x, vrho, vsigma)

        if (eps_x /= 0.0_wp .or. vrho /= 0.0_wp .or. vsigma /= 0.0_wp) then
            write (*, '(a)') 'FAIL test_pbe_x_zero_density'
            passed = .false.
        else
            write (*, '(a)') 'PASS test_pbe_x_zero_density'
        end if
    end subroutine test_pbe_x_zero_density

!> PBE exchange with sigma=0 should reduce to LDA exchange
    subroutine test_pbe_x_lda_limit(passed)
        logical, intent(inout) :: passed
        real(wp) :: rho, eps_x, vrho, vsigma
        real(wp), parameter :: pi_val = 4.0_wp*atan(1.0_wp)
        real(wp) :: ex_lda, vx_lda, rel_err_e, rel_err_v

        rho = 0.1_wp
        call pbe_exchange(rho, 0.0_wp, eps_x, vrho, vsigma)

        ex_lda = -0.75_wp*(3.0_wp/pi_val)**(1.0_wp/3.0_wp)*rho**(1.0_wp/3.0_wp)
        vx_lda = (4.0_wp/3.0_wp)*ex_lda

        rel_err_e = abs(eps_x - ex_lda)/abs(ex_lda)
        rel_err_v = abs(vrho - vx_lda)/abs(vx_lda)

        if (rel_err_e > 1.0e-12_wp .or. rel_err_v > 1.0e-12_wp) then
            write (*, '(a,2es12.5)') 'FAIL test_pbe_x_lda_limit  err=', &
                rel_err_e, rel_err_v
            passed = .false.
        else
            write (*, '(a)') 'PASS test_pbe_x_lda_limit'
        end if
    end subroutine test_pbe_x_lda_limit

!> verify PBE exchange potential and vsigma by numerical differentiation
    subroutine test_pbe_x_potential_numerical(passed)
        logical, intent(inout) :: passed
        real(wp) :: rho, sigma, h
        real(wp) :: eps_x, vrho, vsigma
        real(wp) :: eps_p, vr_p, vs_p, eps_m, vr_m, vs_m
        real(wp) :: vrho_num, vsigma_num, rel_err_rho, rel_err_sigma

        rho   = 0.1_wp
        sigma = 0.01_wp
        h     = 1.0e-6_wp

        call pbe_exchange(rho, sigma, eps_x, vrho, vsigma)

        call pbe_exchange(rho + h, sigma, eps_p, vr_p, vs_p)
        call pbe_exchange(rho - h, sigma, eps_m, vr_m, vs_m)
        vrho_num = ((rho + h)*eps_p - (rho - h)*eps_m)/(2.0_wp*h)
        rel_err_rho = abs(vrho - vrho_num)/abs(vrho)

        call pbe_exchange(rho, sigma + h, eps_p, vr_p, vs_p)
        call pbe_exchange(rho, sigma - h, eps_m, vr_m, vs_m)
        vsigma_num = (rho*eps_p - rho*eps_m)/(2.0_wp*h)
        rel_err_sigma = abs(vsigma - vsigma_num)/abs(vsigma)

        if (rel_err_rho > 1.0e-5_wp .or. rel_err_sigma > 1.0e-5_wp) then
            write (*, '(a,2es12.5)') &
                'FAIL test_pbe_x_potential_numerical  err=', &
                rel_err_rho, rel_err_sigma
            passed = .false.
        else
            write (*, '(a,2es8.1)') &
                'PASS test_pbe_x_potential_numerical  rel_err=', &
                rel_err_rho, rel_err_sigma
        end if
    end subroutine test_pbe_x_potential_numerical

!> compare PBE exchange against libxc reference data (test/refs/gga_x_pbe.data)
    subroutine test_pbe_x_libxc(passed)
        logical, intent(inout) :: passed
        real(wp), parameter :: tol = 1.0e-11_wp

        ! rhoa=1.7, sigma~0 (LDA limit)
        call check_gga_ref(passed, 'pbe_x_libxc rho=3.40  sig~0  ', 'x', &
            1.7_wp, 0.81e-11_wp, &
            -0.377592720836e+01_wp, -0.148075576798e+01_wp, &
            -0.165665974842e-02_wp, 0.0_wp, -0.165665974842e-02_wp, tol)

        ! rhoa=1.7, sigmaaa=1.7 (moderate gradient)
        call check_gga_ref(passed, 'pbe_x_libxc rho=3.40  sig=6.8', 'x', &
            1.7_wp, 1.7_wp, &
            -0.378154942017e+01_wp, -0.147855914532e+01_wp, &
            -0.165052935245e-02_wp, 0.0_wp, -0.165052935245e-02_wp, tol)

        ! rhoa=1.5, sigmaaa=36 (large gradient)
        call check_gga_ref(passed, 'pbe_x_libxc rho=3.00  sig=144', 'x', &
            1.5_wp, 36.0_wp, &
            -0.332917118617e+01_wp, -0.136704102604e+01_wp, &
            -0.175922831660e-02_wp, 0.0_wp, -0.175922831660e-02_wp, tol)

        ! rhoa=0.088, sigmaaa=0.087 (low density)
        call check_gga_ref(passed, 'pbe_x_libxc rho=0.176 sig=0.3', 'x', &
            0.088_wp, 0.087_wp, &
            -0.847500738867e-01_wp, -0.498335317577e+00_wp, &
            -0.545109539268e-01_wp, 0.0_wp, -0.545109539268e-01_wp, tol)

        ! rhoa=0.26, sigmaaa=0.28
        call check_gga_ref(passed, 'pbe_x_libxc rho=0.52  sig=1.1', 'x', &
            0.26_wp, 0.28_wp, &
            -0.319679717401e+00_wp, -0.766494428708e+00_wp, &
            -0.185240091115e-01_wp, 0.0_wp, -0.185240091115e-01_wp, tol)

        ! rhoa=1800, sigmaaa=0.55 (high density, low gradient)
        call check_gga_ref(passed, 'pbe_x_libxc rho=3600  sig=2.2', 'x', &
            1800.0_wp, 0.55_wp, &
            -0.407494475322e+05_wp, -0.150923879748e+02_wp, &
            -0.153509482897e-06_wp, 0.0_wp, -0.153509482897e-06_wp, tol)
    end subroutine test_pbe_x_libxc

! ================================================================
!  PBE correlation tests
! ================================================================

!> PBE correlation should return zeros for zero density
    subroutine test_pbe_c_zero_density(passed)
        logical, intent(inout) :: passed
        real(wp) :: eps_c, vrho, vsigma

        call pbe_correlation(0.0_wp, 0.0_wp, eps_c, vrho, vsigma)

        if (eps_c /= 0.0_wp .or. vrho /= 0.0_wp .or. vsigma /= 0.0_wp) then
            write (*, '(a)') 'FAIL test_pbe_c_zero_density'
            passed = .false.
        else
            write (*, '(a)') 'PASS test_pbe_c_zero_density'
        end if
    end subroutine test_pbe_c_zero_density

!> PBE correlation with sigma=0 should reduce to PW92
    subroutine test_pbe_c_lda_limit(passed)
        use xc, only: pw92_correlation
        logical, intent(inout) :: passed
        real(wp) :: rho, eps_c, vrho, vsigma
        real(wp) :: e0, v0, rel_err_e, rel_err_v

        rho = 0.1_wp
        call pbe_correlation(rho, 0.0_wp, eps_c, vrho, vsigma)
        call pw92_correlation(rho, e0, v0)

        rel_err_e = abs(eps_c - e0)/abs(e0)
        rel_err_v = abs(vrho - v0)/abs(v0)

        if (rel_err_e > 1.0e-12_wp .or. rel_err_v > 1.0e-12_wp) then
            write (*, '(a,2es12.5)') 'FAIL test_pbe_c_lda_limit  err=', &
                rel_err_e, rel_err_v
            passed = .false.
        else
            write (*, '(a)') 'PASS test_pbe_c_lda_limit'
        end if
    end subroutine test_pbe_c_lda_limit

!> verify PBE correlation potential and vsigma by numerical differentiation
    subroutine test_pbe_c_potential_numerical(passed)
        logical, intent(inout) :: passed
        real(wp) :: rho, sigma, h
        real(wp) :: eps_c, vrho, vsigma
        real(wp) :: eps_p, vr_p, vs_p, eps_m, vr_m, vs_m
        real(wp) :: vrho_num, vsigma_num, rel_err_rho, rel_err_sigma

        rho   = 0.1_wp
        sigma = 0.01_wp
        h     = 1.0e-6_wp

        call pbe_correlation(rho, sigma, eps_c, vrho, vsigma)

        call pbe_correlation(rho + h, sigma, eps_p, vr_p, vs_p)
        call pbe_correlation(rho - h, sigma, eps_m, vr_m, vs_m)
        vrho_num = ((rho + h)*eps_p - (rho - h)*eps_m)/(2.0_wp*h)
        rel_err_rho = abs(vrho - vrho_num)/abs(vrho)

        call pbe_correlation(rho, sigma + h, eps_p, vr_p, vs_p)
        call pbe_correlation(rho, sigma - h, eps_m, vr_m, vs_m)
        vsigma_num = (rho*eps_p - rho*eps_m)/(2.0_wp*h)
        rel_err_sigma = abs(vsigma - vsigma_num)/abs(vsigma)

        if (rel_err_rho > 1.0e-5_wp .or. rel_err_sigma > 1.0e-5_wp) then
            write (*, '(a,2es12.5)') &
                'FAIL test_pbe_c_potential_numerical  err=', &
                rel_err_rho, rel_err_sigma
            passed = .false.
        else
            write (*, '(a,2es8.1)') &
                'PASS test_pbe_c_potential_numerical  rel_err=', &
                rel_err_rho, rel_err_sigma
        end if
    end subroutine test_pbe_c_potential_numerical

!> compare PBE correlation against libxc reference data (test/refs/gga_c_pbe.data)
    subroutine test_pbe_c_libxc(passed)
        logical, intent(inout) :: passed
        real(wp), parameter :: tol = 1.0e-11_wp

        ! rhoa=1.7, sigma~0 (LDA limit)
        call check_gga_ref(passed, 'pbe_c_libxc rho=3.40  sig~0  ', 'c', &
            1.7_wp, 0.81e-11_wp, &
            -0.277343302026e+00_wp, -0.902545684170e-01_wp, &
            0.828329874208e-03_wp, 0.165665974842e-02_wp, 0.828329874208e-03_wp, tol)

        ! rhoa=1.7, sigmaaa=1.7
        call check_gga_ref(passed, 'pbe_c_libxc rho=3.40  sig=6.8', 'c', &
            1.7_wp, 1.7_wp, &
            -0.271855691853e+00_wp, -0.923103473041e-01_wp, &
            0.786385334368e-03_wp, 0.157277066874e-02_wp, 0.786385334368e-03_wp, tol)

        ! rhoa=1.5, sigmaaa=36
        call check_gga_ref(passed, 'pbe_c_libxc rho=3.00  sig=144', 'c', &
            1.5_wp, 36.0_wp, &
            -0.156330536080e+00_wp, -0.102948996370e+00_wp, &
            0.378004824716e-03_wp, 0.756009649433e-03_wp, 0.378004824716e-03_wp, tol)

        ! rhoa=0.088, sigmaaa=0.087 (low density)
        call check_gga_ref(passed, 'pbe_c_libxc rho=0.176 sig=0.3', 'c', &
            0.088_wp, 0.087_wp, &
            -0.353114293615e-02_wp, -0.644123523321e-01_wp, &
            0.830804942063e-02_wp, 0.166160988413e-01_wp, 0.830804942063e-02_wp, tol)

        ! rhoa=0.26, sigmaaa=0.28
        call check_gga_ref(passed, 'pbe_c_libxc rho=0.52  sig=1.1', 'c', &
            0.26_wp, 0.28_wp, &
            -0.257202574589e-01_wp, -0.866997760784e-01_wp, &
            0.582853357983e-02_wp, 0.116570671597e-01_wp, 0.582853357983e-02_wp, tol)

        ! rhoa=1800, sigmaaa=0.55 (high density)
        call check_gga_ref(passed, 'pbe_c_libxc rho=3600  sig=2.2', 'c', &
            1800.0_wp, 0.55_wp, &
            -0.531558156901e+03_wp, -0.157670707589e+00_wp, &
            0.767547413336e-07_wp, 0.153509482667e-06_wp, 0.767547413336e-07_wp, tol)
    end subroutine test_pbe_c_libxc

end program test_xc
