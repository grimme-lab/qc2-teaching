module grid
    implicit none

    private
    public :: generate_grid

    integer, parameter :: wp = selected_real_kind(15)

    real(wp), parameter :: pi = 4.0_wp*atan(1.0_wp)

    !> covalent radii in bohr (H-Zn), used for Becke partitioning
    !! and radial grid scaling
    real(wp), parameter :: cov_rad(30) = [ &
                           0.59_wp, 0.53_wp, &
                           2.42_wp, 1.81_wp, &
                           1.59_wp, 1.38_wp, 1.34_wp, 1.25_wp, 1.08_wp, 1.10_wp, &
                           3.14_wp, 2.66_wp, &
                           2.29_wp, 2.10_wp, 2.02_wp, 1.98_wp, 1.93_wp, 2.00_wp, &
                           3.84_wp, 3.33_wp, 3.21_wp, 3.02_wp, 2.89_wp, 2.63_wp, &
                           2.83_wp, 2.68_wp, 2.61_wp, 2.34_wp, 2.49_wp, 2.31_wp]

contains

!> generate a molecular integration grid using atom-centered
!! Chebyshev-Lebedev quadrature with Becke partitioning
!!
!! returns allocatable arrays of grid points and weights
    subroutine generate_grid(xyz, chrg, grid_xyz, grid_w, ngrid, nrad, nang)

        !> atomic coordinates in bohr, shape (3, nat)
        real(wp), intent(in) :: xyz(:, :)
        !> nuclear charges (used to determine element type)
        real(wp), intent(in) :: chrg(:)
        !> grid point coordinates, shape (3, ngrid)
        real(wp), allocatable, intent(out) :: grid_xyz(:, :)
        !> grid point weights, shape (ngrid)
        real(wp), allocatable, intent(out) :: grid_w(:)
        !> total number of grid points
        integer, intent(out) :: ngrid
        !> optional: number of radial grid points (overrides element-based default)
        integer, optional, intent(in) :: nrad
        !> optional: number of angular grid points, must be 230 or 434
    !! (overrides element-based default)
        integer, optional, intent(in) :: nang

        integer :: nat, iat, iz, nr, nl, ir, il, ig, max_pts
        real(wp) :: p, x_i
        real(wp) :: spacew
        real(wp), allocatable :: radii(:), rad_w(:)
        real(wp), allocatable :: lx(:), ly(:), lz(:), lw(:)
        real(wp), allocatable :: tmp_xyz(:, :), tmp_w(:)
        real(wp) :: point(3)
        integer :: nl2

        nat = size(chrg)

        ! estimate maximum grid size: sum over atoms of nr*nl
        max_pts = 0
        do iat = 1, nat
            iz = nint(chrg(iat))
            call grid_sizes(iz, nr, nl)
            if (present(nrad)) nr = nrad
            if (present(nang)) nl = nang
            max_pts = max_pts + nr*nl
        end do

        allocate (tmp_xyz(3, max_pts), tmp_w(max_pts))

        ig = 0
        do iat = 1, nat
            iz = nint(chrg(iat))
            call grid_sizes(iz, nr, nl)
            if (present(nrad)) nr = nrad
            if (present(nang)) nl = nang

            ! radial grid scaling parameter
            if (iz == 1) then
                p = cov_rad(iz)
            else
                p = cov_rad(iz)*0.5_wp
            end if

            ! compute radial grid (2nd Chebyshev)
            allocate (radii(nr), rad_w(nr))
            do ir = 1, nr
                x_i = cos(ir*pi/real(nr + 1, wp))
                radii(ir) = (1.0_wp + x_i)/(1.0_wp - x_i)*p
                rad_w(ir) = (2.0_wp*pi/real(nr + 1, wp)) &
                           & *p**3*((x_i + 1.0_wp)**2.5_wp/(1.0_wp - x_i)**3.5_wp)
            end do

            ! compute angular grid (Lebedev)
            allocate (lx(nl), ly(nl), lz(nl), lw(nl))
            nl2 = 0
            if (nl == 230) then
                call LD0230(lx, ly, lz, lw, nl2)
            else if (nl == 434) then
                call LD0434(lx, ly, lz, lw, nl2)
            else
                call LD1202(lx, ly, lz, lw, nl2)
            end if
            lw = lw*4.0_wp*pi

            ! combine radial and angular grids, shift to atom center,
            ! and apply Becke partitioning
            do ir = 1, nr
                do il = 1, nl
                    ig = ig + 1
                    tmp_xyz(1, ig) = radii(ir)*lx(il) + xyz(1, iat)
                    tmp_xyz(2, ig) = radii(ir)*ly(il) + xyz(2, iat)
                    tmp_xyz(3, ig) = radii(ir)*lz(il) + xyz(3, iat)
                    tmp_w(ig) = rad_w(ir)*lw(il)

                    ! apply Becke space partitioning weight
                    point = tmp_xyz(:, ig)
                    call becke_weight(point, iat, nat, xyz, chrg, spacew)
                    tmp_w(ig) = tmp_w(ig)*spacew
                end do
            end do

            deallocate (radii, rad_w, lx, ly, lz, lw)
        end do

        ngrid = ig
        allocate (grid_xyz(3, ngrid), grid_w(ngrid))
        grid_xyz(:, 1:ngrid) = tmp_xyz(:, 1:ngrid)
        grid_w(1:ngrid) = tmp_w(1:ngrid)
        deallocate (tmp_xyz, tmp_w)

    end subroutine generate_grid

!> determine number of radial and angular grid points based on element
    pure subroutine grid_sizes(iz, nr, nl)
        integer, intent(in) :: iz
        integer, intent(out) :: nr, nl

        if (iz <= 2) then
            nr = 35; nl = 230
        else if (iz <= 10) then
            nr = 65; nl = 434
        else if (iz <= 18) then
            nr = 80; nl = 434
        else
            nr = 100; nl = 434
        end if
    end subroutine grid_sizes

!> Becke fuzzy partitioning weight for a point assigned to atom `iat`
    pure subroutine becke_weight(point, iat, nat, xyz, chrg, weight)
        real(wp), intent(in) :: point(3)
        integer, intent(in) :: iat, nat
        real(wp), intent(in) :: xyz(3, nat)
        real(wp), intent(in) :: chrg(nat)
        real(wp), intent(out) :: weight

        real(wp) :: weights(nat)
        real(wp) :: ri, rj, rij, chi, mu_prime, a_adj, mu, nu, s
        integer :: ii, jj, izi, izj

        weights = 1.0_wp
        do ii = 1, nat
            izi = nint(chrg(ii))
            ri = sqrt(sum((point - xyz(:, ii))**2))
            do jj = 1, nat
                if (jj == ii) cycle
                izj = nint(chrg(jj))
                rj = sqrt(sum((point - xyz(:, jj))**2))
                rij = sqrt(sum((xyz(:, ii) - xyz(:, jj))**2))
                mu = (ri - rj)/rij
                ! size-adjusted Becke partitioning using covalent radii
                chi = cov_rad(izi)/cov_rad(izj)
                mu_prime = (chi - 1.0_wp)/(chi + 1.0_wp)
                a_adj = mu_prime/(mu_prime**2 - 1.0_wp)
                if (a_adj > 0.5_wp) a_adj = 0.5_wp
                if (a_adj < -0.5_wp) a_adj = -0.5_wp
                nu = mu + a_adj*(1.0_wp - mu**2)
                s = 0.5_wp*(1.0_wp - becke_mu(nu, 3))
                weights(ii) = weights(ii)*s
            end do
        end do
        weight = weights(iat)/sum(weights)
    end subroutine becke_weight

!> iterated Becke smoothing function: f(x) = 1.5*x - 0.5*x^3, applied p times
    pure recursive function becke_mu(x, p) result(y)
        real(wp), intent(in) :: x
        integer, intent(in) :: p
        real(wp) :: y

        if (p <= 1) then
            y = 1.5_wp*x - 0.5_wp*x**3
        else
            y = 1.5_wp*becke_mu(x, p - 1) - 0.5_wp*becke_mu(x, p - 1)**3
        end if
    end function becke_mu

! ============================================================
! Lebedev angular quadrature rules
! Based on code by Christoph van Wuellen (modified by Dirac4pi)
! ============================================================

!> core symmetry generator for Lebedev grid
    pure subroutine gen_oh(code, num, x, y, z, w, a, b, v)
        integer, intent(in) :: code
        integer, intent(inout) :: num
        double precision, intent(inout) :: x(:), y(:), z(:), w(:)
        double precision, intent(inout) :: a, b, v
        double precision :: c

        select case (code)
        case (1)
            a = 1.0d0
            x(1) = a; y(1) = 0.0d0; z(1) = 0.0d0; w(1) = v
            x(2) = -a; y(2) = 0.0d0; z(2) = 0.0d0; w(2) = v
            x(3) = 0.0d0; y(3) = a; z(3) = 0.0d0; w(3) = v
            x(4) = 0.0d0; y(4) = -a; z(4) = 0.0d0; w(4) = v
            x(5) = 0.0d0; y(5) = 0.0d0; z(5) = a; w(5) = v
            x(6) = 0.0d0; y(6) = 0.0d0; z(6) = -a; w(6) = v
            num = num + 6
        case (2)
            a = sqrt(0.5d0)
            x(1) = 0.0d0; y(1) = a; z(1) = a; w(1) = v
            x(2) = 0.0d0; y(2) = -a; z(2) = a; w(2) = v
            x(3) = 0.0d0; y(3) = a; z(3) = -a; w(3) = v
            x(4) = 0.0d0; y(4) = -a; z(4) = -a; w(4) = v
            x(5) = a; y(5) = 0.0d0; z(5) = a; w(5) = v
            x(6) = -a; y(6) = 0.0d0; z(6) = a; w(6) = v
            x(7) = a; y(7) = 0.0d0; z(7) = -a; w(7) = v
            x(8) = -a; y(8) = 0.0d0; z(8) = -a; w(8) = v
            x(9) = a; y(9) = a; z(9) = 0.0d0; w(9) = v
            x(10) = -a; y(10) = a; z(10) = 0.0d0; w(10) = v
            x(11) = a; y(11) = -a; z(11) = 0.0d0; w(11) = v
            x(12) = -a; y(12) = -a; z(12) = 0.0d0; w(12) = v
            num = num + 12
        case (3)
            a = sqrt(1.0d0/3.0d0)
            x(1) = a; y(1) = a; z(1) = a; w(1) = v
            x(2) = -a; y(2) = a; z(2) = a; w(2) = v
            x(3) = a; y(3) = -a; z(3) = a; w(3) = v
            x(4) = -a; y(4) = -a; z(4) = a; w(4) = v
            x(5) = a; y(5) = a; z(5) = -a; w(5) = v
            x(6) = -a; y(6) = a; z(6) = -a; w(6) = v
            x(7) = a; y(7) = -a; z(7) = -a; w(7) = v
            x(8) = -a; y(8) = -a; z(8) = -a; w(8) = v
            num = num + 8
        case (4)
            b = sqrt(1.0d0 - 2.0d0*a*a)
            x(1) = a; y(1) = a; z(1) = b; w(1) = v
            x(2) = -a; y(2) = a; z(2) = b; w(2) = v
            x(3) = a; y(3) = -a; z(3) = b; w(3) = v
            x(4) = -a; y(4) = -a; z(4) = b; w(4) = v
            x(5) = a; y(5) = a; z(5) = -b; w(5) = v
            x(6) = -a; y(6) = a; z(6) = -b; w(6) = v
            x(7) = a; y(7) = -a; z(7) = -b; w(7) = v
            x(8) = -a; y(8) = -a; z(8) = -b; w(8) = v
            x(9) = a; y(9) = b; z(9) = a; w(9) = v
            x(10) = -a; y(10) = b; z(10) = a; w(10) = v
            x(11) = a; y(11) = -b; z(11) = a; w(11) = v
            x(12) = -a; y(12) = -b; z(12) = a; w(12) = v
            x(13) = a; y(13) = b; z(13) = -a; w(13) = v
            x(14) = -a; y(14) = b; z(14) = -a; w(14) = v
            x(15) = a; y(15) = -b; z(15) = -a; w(15) = v
            x(16) = -a; y(16) = -b; z(16) = -a; w(16) = v
            x(17) = b; y(17) = a; z(17) = a; w(17) = v
            x(18) = -b; y(18) = a; z(18) = a; w(18) = v
            x(19) = b; y(19) = -a; z(19) = a; w(19) = v
            x(20) = -b; y(20) = -a; z(20) = a; w(20) = v
            x(21) = b; y(21) = a; z(21) = -a; w(21) = v
            x(22) = -b; y(22) = a; z(22) = -a; w(22) = v
            x(23) = b; y(23) = -a; z(23) = -a; w(23) = v
            x(24) = -b; y(24) = -a; z(24) = -a; w(24) = v
            num = num + 24
        case (5)
            b = sqrt(1.0d0 - a*a)
            x(1) = a; y(1) = b; z(1) = 0.0d0; w(1) = v
            x(2) = -a; y(2) = b; z(2) = 0.0d0; w(2) = v
            x(3) = a; y(3) = -b; z(3) = 0.0d0; w(3) = v
            x(4) = -a; y(4) = -b; z(4) = 0.0d0; w(4) = v
            x(5) = b; y(5) = a; z(5) = 0.0d0; w(5) = v
            x(6) = -b; y(6) = a; z(6) = 0.0d0; w(6) = v
            x(7) = b; y(7) = -a; z(7) = 0.0d0; w(7) = v
            x(8) = -b; y(8) = -a; z(8) = 0.0d0; w(8) = v
            x(9) = a; y(9) = 0.0d0; z(9) = b; w(9) = v
            x(10) = -a; y(10) = 0.0d0; z(10) = b; w(10) = v
            x(11) = a; y(11) = 0.0d0; z(11) = -b; w(11) = v
            x(12) = -a; y(12) = 0.0d0; z(12) = -b; w(12) = v
            x(13) = b; y(13) = 0.0d0; z(13) = a; w(13) = v
            x(14) = -b; y(14) = 0.0d0; z(14) = a; w(14) = v
            x(15) = b; y(15) = 0.0d0; z(15) = -a; w(15) = v
            x(16) = -b; y(16) = 0.0d0; z(16) = -a; w(16) = v
            x(17) = 0.0d0; y(17) = a; z(17) = b; w(17) = v
            x(18) = 0.0d0; y(18) = -a; z(18) = b; w(18) = v
            x(19) = 0.0d0; y(19) = a; z(19) = -b; w(19) = v
            x(20) = 0.0d0; y(20) = -a; z(20) = -b; w(20) = v
            x(21) = 0.0d0; y(21) = b; z(21) = a; w(21) = v
            x(22) = 0.0d0; y(22) = -b; z(22) = a; w(22) = v
            x(23) = 0.0d0; y(23) = b; z(23) = -a; w(23) = v
            x(24) = 0.0d0; y(24) = -b; z(24) = -a; w(24) = v
            num = num + 24
        case (6)
            c = sqrt(1.0d0 - a*a - b*b)
            x(1) = a; y(1) = b; z(1) = c; w(1) = v
            x(2) = -a; y(2) = b; z(2) = c; w(2) = v
            x(3) = a; y(3) = -b; z(3) = c; w(3) = v
            x(4) = -a; y(4) = -b; z(4) = c; w(4) = v
            x(5) = a; y(5) = b; z(5) = -c; w(5) = v
            x(6) = -a; y(6) = b; z(6) = -c; w(6) = v
            x(7) = a; y(7) = -b; z(7) = -c; w(7) = v
            x(8) = -a; y(8) = -b; z(8) = -c; w(8) = v
            x(9) = a; y(9) = c; z(9) = b; w(9) = v
            x(10) = -a; y(10) = c; z(10) = b; w(10) = v
            x(11) = a; y(11) = -c; z(11) = b; w(11) = v
            x(12) = -a; y(12) = -c; z(12) = b; w(12) = v
            x(13) = a; y(13) = c; z(13) = -b; w(13) = v
            x(14) = -a; y(14) = c; z(14) = -b; w(14) = v
            x(15) = a; y(15) = -c; z(15) = -b; w(15) = v
            x(16) = -a; y(16) = -c; z(16) = -b; w(16) = v
            x(17) = b; y(17) = a; z(17) = c; w(17) = v
            x(18) = -b; y(18) = a; z(18) = c; w(18) = v
            x(19) = b; y(19) = -a; z(19) = c; w(19) = v
            x(20) = -b; y(20) = -a; z(20) = c; w(20) = v
            x(21) = b; y(21) = a; z(21) = -c; w(21) = v
            x(22) = -b; y(22) = a; z(22) = -c; w(22) = v
            x(23) = b; y(23) = -a; z(23) = -c; w(23) = v
            x(24) = -b; y(24) = -a; z(24) = -c; w(24) = v
            x(25) = b; y(25) = c; z(25) = a; w(25) = v
            x(26) = -b; y(26) = c; z(26) = a; w(26) = v
            x(27) = b; y(27) = -c; z(27) = a; w(27) = v
            x(28) = -b; y(28) = -c; z(28) = a; w(28) = v
            x(29) = b; y(29) = c; z(29) = -a; w(29) = v
            x(30) = -b; y(30) = c; z(30) = -a; w(30) = v
            x(31) = b; y(31) = -c; z(31) = -a; w(31) = v
            x(32) = -b; y(32) = -c; z(32) = -a; w(32) = v
            x(33) = c; y(33) = a; z(33) = b; w(33) = v
            x(34) = -c; y(34) = a; z(34) = b; w(34) = v
            x(35) = c; y(35) = -a; z(35) = b; w(35) = v
            x(36) = -c; y(36) = -a; z(36) = b; w(36) = v
            x(37) = c; y(37) = a; z(37) = -b; w(37) = v
            x(38) = -c; y(38) = a; z(38) = -b; w(38) = v
            x(39) = c; y(39) = -a; z(39) = -b; w(39) = v
            x(40) = -c; y(40) = -a; z(40) = -b; w(40) = v
            x(41) = c; y(41) = b; z(41) = a; w(41) = v
            x(42) = -c; y(42) = b; z(42) = a; w(42) = v
            x(43) = c; y(43) = -b; z(43) = a; w(43) = v
            x(44) = -c; y(44) = -b; z(44) = a; w(44) = v
            x(45) = c; y(45) = b; z(45) = -a; w(45) = v
            x(46) = -c; y(46) = b; z(46) = -a; w(46) = v
            x(47) = c; y(47) = -b; z(47) = -a; w(47) = v
            x(48) = -c; y(48) = -b; z(48) = -a; w(48) = v
            num = num + 48
        end select
    end subroutine gen_oh

!> generate 230 grid points in Lebedev scheme
    pure subroutine LD0230(x, y, z, w, n)
        double precision, intent(out) :: x(:), y(:), z(:), w(:)
        integer, intent(out) :: n
        double precision :: a, b, v

        n = 1
        v = -0.5522639919727325d-1
        call gen_oh(1, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        v = 0.4450274607445226d-2
        call gen_oh(3, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.4492044687397611d+0
        v = 0.4496841067921404d-2
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.2520419490210201d+0
        v = 0.5049153450478750d-2
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.6981906658447242d+0
        v = 0.3976408018051883d-2
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.6587405243460960d+0
        v = 0.4401400650381014d-2
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.4038544050097660d-1
        v = 0.1724544350544401d-1
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.5823842309715585d+0
        v = 0.4231083095357343d-2
        call gen_oh(5, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.3545877390518688d+0
        v = 0.5198069864064399d-2
        call gen_oh(5, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.2272181808998187d+0
        b = 0.4864661535886647d+0
        v = 0.4695720972568883d-2
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        n = n - 1
    end subroutine LD0230

!> generate 434 grid points in Lebedev scheme
    pure subroutine LD0434(x, y, z, w, n)
        double precision, intent(out) :: x(:), y(:), z(:), w(:)
        integer, intent(out) :: n
        double precision :: a, b, v

        n = 1
        v = 0.5265897968224436d-3
        call gen_oh(1, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        v = 0.2548219972002607d-2
        call gen_oh(2, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        v = 0.2512317418927307d-2
        call gen_oh(3, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.6909346307509111d+0
        v = 0.2530403801186355d-2
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.1774836054609158d+0
        v = 0.2014279020918528d-2
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.4914342637784746d+0
        v = 0.2501725168402936d-2
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.6456664707424256d+0
        v = 0.2513267174597564d-2
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.2861289010307638d+0
        v = 0.2302694782227416d-2
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.7568084367178018d-1
        v = 0.1462495621594614d-2
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.3927259763368002d+0
        v = 0.2445373437312980d-2
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.8818132877794288d+0
        v = 0.2417442375638981d-2
        call gen_oh(5, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.9776428111182649d+0
        v = 0.1910951282179532d-2
        call gen_oh(5, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.2054823696403044d+0
        b = 0.8689460322872412d+0
        v = 0.2416930044324775d-2
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.5905157048925271d+0
        b = 0.7999278543857286d+0
        v = 0.2512236854563495d-2
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.5550152361076807d+0
        b = 0.7717462626915901d+0
        v = 0.2496644054553086d-2
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.9371809858553722d+0
        b = 0.3344363145343455d+0
        v = 0.2236607760437849d-2
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        n = n - 1
    end subroutine LD0434

    pure subroutine LD1202(x, y, z, w, n)
        double precision, intent(out) :: x(:), y(:), z(:), w(:)
        integer, intent(out) :: n
        double precision :: a, b, v

        n = 1
        v = 0.1105189233267572e-3_wp
        call gen_oh(1, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        v = 0.9205232738090741e-3_wp
        call gen_oh(2, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        v = 0.9133159786443561e-3_wp
        call gen_oh(3, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.3712636449657089e-1_wp
        v = 0.3690421898017899e-3_wp
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.9140060412262223e-1_wp
        v = 0.5603990928680660e-3_wp
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.1531077852469906e+0_wp
        v = 0.6865297629282609e-3_wp
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.2180928891660612e+0_wp
        v = 0.7720338551145630e-3_wp
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.2839874532200175e+0_wp
        v = 0.8301545958894795e-3_wp
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.3491177600963764e+0_wp
        v = 0.8686692550179628e-3_wp
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.4121431461444309e+0_wp
        v = 0.8927076285846890e-3_wp
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.4718993627149127e+0_wp
        v = 0.9060820238568219e-3_wp
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.5273145452842337e+0_wp
        v = 0.9119777254940867e-3_wp
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.6209475332444019e+0_wp
        v = 0.9128720138604181e-3_wp
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.6569722711857291e+0_wp
        v = 0.9130714935691735e-3_wp
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.6841788309070143e+0_wp
        v = 0.9152873784554116e-3_wp
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.7012604330123631e+0_wp
        v = 0.9187436274321654e-3_wp
        call gen_oh(4, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.1072382215478166e+0_wp
        v = 0.5176977312965694e-3_wp
        call gen_oh(5, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.2582068959496968e+0_wp
        v = 0.7331143682101417e-3_wp
        call gen_oh(5, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.4172752955306717e+0_wp
        v = 0.8463232836379928e-3_wp
        call gen_oh(5, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.5700366911792503e+0_wp
        v = 0.9031122694253992e-3_wp
        call gen_oh(5, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.9827986018263947e+0_wp
        b = 0.1771774022615325e+0_wp
        v = 0.6485778453163257e-3_wp
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.9624249230326228e+0_wp
        b = 0.2475716463426288e+0_wp
        v = 0.7435030910982369e-3_wp
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.9402007994128811e+0_wp
        b = 0.3354616289066489e+0_wp
        v = 0.7998527891839054e-3_wp
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.9320822040143202e+0_wp
        b = 0.3173615246611977e+0_wp
        v = 0.8101731497468018e-3_wp
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.9043674199393299e+0_wp
        b = 0.4090268427085357e+0_wp
        v = 0.8483389574594331e-3_wp
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.8912407560074747e+0_wp
        b = 0.3854291150669224e+0_wp
        v = 0.8556299257311812e-3_wp
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.8676435628462708e+0_wp
        b = 0.4932221184851285e+0_wp
        v = 0.8803208679738260e-3_wp
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.8581979986041619e+0_wp
        b = 0.4785320675922435e+0_wp
        v = 0.8811048182425720e-3_wp
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.8396753624049856e+0_wp
        b = 0.4507422593157064e+0_wp
        v = 0.8850282341265444e-3_wp
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.8165288564022188e+0_wp
        b = 0.5632123020762100e+0_wp
        v = 0.9021342299040653e-3_wp
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.8015469370783529e+0_wp
        b = 0.5434303569693900e+0_wp
        v = 0.9010091677105086e-3_wp
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.7773563069070351e+0_wp
        b = 0.5123518486419871e+0_wp
        v = 0.9022692938426915e-3_wp
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.7661621213900394e+0_wp
        b = 0.6394279634749102e+0_wp
        v = 0.9158016174693465e-3_wp
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.7553584143533510e+0_wp
        b = 0.6269805509024392e+0_wp
        v = 0.9131578003189435e-3_wp
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.7344305757559503e+0_wp
        b = 0.6031161693096310e+0_wp
        v = 0.9107813579482705e-3_wp
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        a = 0.7043837184021765e+0_wp
        b = 0.5693702498468441e+0_wp
        v = 0.9105760258970126e-3_wp
        call gen_oh(6, n, x(n:), y(n:), z(n:), w(n:), a, b, v)
        n = n - 1
    end subroutine LD1202

end module grid
