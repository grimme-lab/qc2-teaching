module linear_algebra

    !> Always declare everything explicitly
    implicit none

    !> Export solve_spev
    private
    public :: solve_spev

    integer, parameter :: wp = selected_real_kind(15)


    !> interfaces to lapack
    interface
        subroutine dspev(jobz, uplo, n, ap, w, z, ldz, work, info)
            import wp
            integer, intent(in) :: ldz
            real(wp), intent(inout) :: ap(*)
            real(wp), intent(out) :: w(*)
            real(wp), intent(out) :: z(ldz,*)
            character, intent(in) :: jobz
            character, intent(in) :: uplo
            integer, intent(out) :: info
            integer, intent(in) :: n
            real(wp), intent(inout) :: work(*)
        end subroutine dspev
    end interface


contains


subroutine solve_spev(matrix, eigval, eigvec, stat)
    !> plain lapack call:
    !  dspev(jobz,uplo,n,matrix,eigval,eigvec,n,work,info)

    implicit none

    !> symmetric matrix is diagonalized by this routine
    real(wp), intent(inout) :: matrix(:)
    !> eigenvalues of matrix are written to eigval
    real(wp), intent(out) :: eigval(:)
    !> eigenvectors are written to eigvec if provided
    real(wp), intent(out) :: eigvec(:, :)
    !> error status
    integer, intent(out), optional :: stat
    !> local variables
    character, parameter :: jobz = 'v'
    character, parameter :: uplo = 'u'
    integer :: info
    integer :: n, np, ldz
    !> workspace for dspev
    real(wp), allocatable :: work(:)

    intrinsic :: max, present, size

    info = 0

    n   = max(1, size(eigval, 1))
    np  = max(1, size(matrix, 1))
    ldz = max(1, size(eigvec, 1))

    ! dimension missmatch
    if (np /= n*(n+1)/2 .or. ldz /= n) then
        info = 1000
    endif

    if (info == 0) then
       ! allocate work arrays with requested size
       allocate(work(3*n), stat=info)
    end if

    ! call lapack routine
    if(info == 0) then
        call dspev(jobz, uplo, n, matrix, eigval, eigvec, ldz, work, info)
    endif

    ! error handler
    if (present(stat)) then
        stat = info
    else if(info.ne.0) then
        error stop "[LAPACK] Solving eigenvalue problem failed!"
    endif

end subroutine solve_spev


end module linear_algebra
