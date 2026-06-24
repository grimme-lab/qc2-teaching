program test_grid
    use grid, only: generate_grid
    implicit none

    integer, parameter :: wp = selected_real_kind(15)
    real(wp), parameter :: pi = 4.0_wp*atan(1.0_wp)

    logical :: all_passed

    all_passed = .true.
    call test_grid_size(all_passed)
    call test_grid_size_override(all_passed)
    call test_positive_weights(all_passed)
    call test_gaussian_single_atom(all_passed)
    call test_gaussian_two_atoms(all_passed)
    call test_gaussian_h2_nang230(all_passed)
    call test_gaussian_h2_nang434(all_passed)
    call test_gaussian_h2_nang1202(all_passed)
    call test_gaussian_h2_huge(all_passed)

    if (.not. all_passed) then
        write (*, '(a)') 'SOME TESTS FAILED'
        error stop 1
    end if
    write (*, '(a)') 'ALL TESTS PASSED'

contains

!> check that ngrid matches expected nr*nl per atom
    subroutine test_grid_size(passed)
        logical, intent(inout) :: passed
        ! H2: two hydrogen atoms -> 2 * 35 * 230 = 16100
        real(wp) :: xyz(3, 2), chrg(2)
        real(wp), allocatable :: grid_xyz(:, :), grid_w(:)
        integer :: ngrid

        xyz(:, 1) = [0.0_wp, 0.0_wp, -0.7_wp]
        xyz(:, 2) = [0.0_wp, 0.0_wp, 0.7_wp]
        chrg = [1.0_wp, 1.0_wp]

        call generate_grid(xyz, chrg, grid_xyz, grid_w, ngrid)

        if (ngrid /= 2*35*230) then
            write (*, '(a,i0,a,i0)') 'FAIL test_grid_size: got ', ngrid, &
                ', expected ', 2*35*230
            passed = .false.
        else
            write (*, '(a)') 'PASS test_grid_size'
        end if
    end subroutine test_grid_size

!> check that nrad/nang optional arguments override grid size
    subroutine test_grid_size_override(passed)
        logical, intent(inout) :: passed
        real(wp) :: xyz(3, 1), chrg(1)
        real(wp), allocatable :: grid_xyz(:, :), grid_w(:)
        integer :: ngrid

        xyz(:, 1) = [0.0_wp, 0.0_wp, 0.0_wp]
        chrg = [6.0_wp]  ! carbon: default would be 65*434

        call generate_grid(xyz, chrg, grid_xyz, grid_w, ngrid, nrad=20, nang=230)

        if (ngrid /= 20*230) then
            write (*, '(a,i0,a,i0)') 'FAIL test_grid_size_override: got ', ngrid, &
                ', expected ', 20*230
            passed = .false.
        else
            write (*, '(a)') 'PASS test_grid_size_override'
        end if
    end subroutine test_grid_size_override

!> all integration weights must be non-negative when using the 434-point
!! Lebedev rule (the 230-point rule has known negative axial weights)
    subroutine test_positive_weights(passed)
        logical, intent(inout) :: passed
        real(wp) :: xyz(3, 2), chrg(2)
        real(wp), allocatable :: grid_xyz(:, :), grid_w(:)
        integer :: ngrid, nneg

        ! use carbon atoms so we get the 434-point Lebedev rule
        xyz(:, 1) = [0.0_wp, 0.0_wp, -1.2_wp]
        xyz(:, 2) = [0.0_wp, 0.0_wp, 1.2_wp]
        chrg = [6.0_wp, 6.0_wp]

        call generate_grid(xyz, chrg, grid_xyz, grid_w, ngrid)

        nneg = count(grid_w < 0.0_wp)
        if (nneg > 0) then
            write (*, '(a,i0,a)') 'FAIL test_positive_weights: ', nneg, &
                ' negative weights'
            passed = .false.
        else
            write (*, '(a)') 'PASS test_positive_weights'
        end if
    end subroutine test_positive_weights

!> integrate exp(-r^2) over all space for a single atom at the origin
!! analytical result: pi^(3/2) = 5.568328...
    subroutine test_gaussian_single_atom(passed)
        logical, intent(inout) :: passed
        real(wp) :: xyz(3, 1), chrg(1)
        real(wp), allocatable :: grid_xyz(:, :), grid_w(:)
        integer :: ngrid, ig
        real(wp) :: r2, integral, exact, rel_err

        xyz(:, 1) = [0.0_wp, 0.0_wp, 0.0_wp]
        chrg = [1.0_wp]

        call generate_grid(xyz, chrg, grid_xyz, grid_w, ngrid)

        integral = 0.0_wp
        do ig = 1, ngrid
            r2 = grid_xyz(1, ig)**2 + grid_xyz(2, ig)**2 + grid_xyz(3, ig)**2
            integral = integral + grid_w(ig)*exp(-r2)
        end do

        exact = pi**(1.5_wp)
        rel_err = abs(integral - exact)/exact

        if (rel_err > 1.0e-4_wp) then
            write (*, '(a,es12.5,a,es12.5,a,es8.1)') &
                'FAIL test_gaussian_single_atom: got ', integral, &
                ', expected ', exact, ', rel_err=', rel_err
            passed = .false.
        else
            write (*, '(a,es8.1)') 'PASS test_gaussian_single_atom  rel_err=', rel_err
        end if
    end subroutine test_gaussian_single_atom

!> integrate exp(-r^2) for H2 molecule (default grid)
!! Becke partition of unity means this must still give pi^(3/2)
    subroutine test_gaussian_two_atoms(passed)
        logical, intent(inout) :: passed
        call gaussian_h2_helper(passed, 'test_gaussian_two_atoms   ')
    end subroutine test_gaussian_two_atoms

!> H2 Gaussian integral with nang=230
    subroutine test_gaussian_h2_nang230(passed)
        logical, intent(inout) :: passed
        call gaussian_h2_helper(passed, 'test_gaussian_h2_nang230  ', nang=230)
    end subroutine test_gaussian_h2_nang230

!> H2 Gaussian integral with nang=434
    subroutine test_gaussian_h2_nang434(passed)
        logical, intent(inout) :: passed
        call gaussian_h2_helper(passed, 'test_gaussian_h2_nang434  ', nang=434)
    end subroutine test_gaussian_h2_nang434

!> H2 Gaussian integral with nang=1202
    subroutine test_gaussian_h2_nang1202(passed)
        logical, intent(inout) :: passed
        call gaussian_h2_helper(passed, 'test_gaussian_h2_nang1202 ', nang=1202)
    end subroutine test_gaussian_h2_nang1202

!> H2 Gaussian integral with huge grid: nrad=200, nang=1202
!! with a tighter tolerance to check convergence
    subroutine test_gaussian_h2_huge(passed)
        logical, intent(inout) :: passed
        call gaussian_h2_helper(passed, 'test_gaussian_h2_huge     ', &
            nrad=250, nang=434, tol=1.0e-10_wp)
    end subroutine test_gaussian_h2_huge

!> helper: integrate exp(-r^2) over H2 with optional grid size overrides
    subroutine gaussian_h2_helper(passed, label, nrad, nang, tol)
        logical, intent(inout) :: passed
        character(len=*), intent(in) :: label
        integer, optional, intent(in) :: nrad, nang
        real(wp), optional, intent(in) :: tol

        real(wp) :: xyz(3, 2), chrg(2)
        real(wp), allocatable :: grid_xyz(:, :), grid_w(:)
        integer :: ngrid, ig
        real(wp) :: r2, integral, exact, rel_err, threshold

        xyz(:, 1) = [0.0_wp, 0.0_wp, -0.7_wp]
        xyz(:, 2) = [0.0_wp, 0.0_wp, 0.7_wp]
        chrg = [1.0_wp, 1.0_wp]

        call generate_grid(xyz, chrg, grid_xyz, grid_w, ngrid, nrad=nrad, nang=nang)

        integral = 0.0_wp
        do ig = 1, ngrid
            r2 = grid_xyz(1, ig)**2 + grid_xyz(2, ig)**2 + grid_xyz(3, ig)**2
            integral = integral + grid_w(ig)*exp(-r2)
        end do

        exact = pi**(1.5_wp)
        rel_err = abs(integral - exact)/exact

        threshold = 1.0e-4_wp
        if (present(tol)) threshold = tol

        if (rel_err > threshold) then
            write (*, '(a,a,a,es12.5,a,es12.5,a,es8.1)') &
                'FAIL ', label, ': got ', integral, &
                ', expected ', exact, ', rel_err=', rel_err
            passed = .false.
        else
            write (*, '(a,a,a,es8.1)') 'PASS ', label, ' rel_err=', rel_err
        end if
    end subroutine gaussian_h2_helper

end program test_grid
