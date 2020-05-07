module print_matrix
    use iso_fortran_env, only : output_unit
    implicit none

    private
    public :: write_vector, write_matrix

    integer, parameter :: wp = selected_real_kind(15)

    interface write_matrix
        module procedure write_2d_matrix
        module procedure write_packed_matrix
    end interface write_matrix


contains


subroutine write_vector(vector, name, unit)
    implicit none
    real(wp),intent(in) :: vector(:)
    character(len=*),intent(in),optional :: name
    integer, intent(in),optional :: unit
    integer :: d
    integer :: i, j, k, l, istep, iunit

    d = size(vector, dim=1)

    if (present(unit)) then
        iunit = unit
    else
        iunit = output_unit
    end if

    if (present(name)) write(iunit,'(/,"vector printed:",1x,a)') name

    do j = 1, d
        write(iunit, '(i6)', advance='no') j
        write(iunit, '(1x,f15.8)', advance='no') vector(j)
        write(iunit, '(a)')
    end do

end subroutine write_vector


subroutine write_2d_matrix(matrix, name, unit, step)
    implicit none
    real(wp),intent(in) :: matrix(:, :)
    character(len=*),intent(in),optional :: name
    integer, intent(in),optional :: unit
    integer, intent(in),optional :: step
    integer :: d1, d2
    integer :: i, j, k, l, istep, iunit

    d1 = size(matrix, dim=1)
    d2 = size(matrix, dim=2)

    if (present(unit)) then
        iunit = unit
    else
        iunit = output_unit
    end if

    if (present(step)) then
        istep = step
    else
        istep = 5
    end if

    if (present(name)) write(iunit,'(/,"matrix printed:",1x,a)') name

    do i = 1, d2, istep
        l = min(i+istep-1,d2)
        write(iunit,'(/,6x)',advance='no')
        do k = i, l
            write(iunit,'(6x,i7,3x)',advance='no') k
        end do
        write(iunit,'(a)')
        do j = 1, d1
            write(iunit,'(i6)',advance='no') j
            do k = i, l
                write(iunit,'(1x,f15.8)',advance='no') matrix(j,k)
            end do
            write(iunit,'(a)')
        end do
    end do

end subroutine write_2d_matrix


subroutine write_packed_matrix(matrix, name, unit, step)
    implicit none
    real(wp), intent(in) :: matrix(:)
    character(len=*),intent(in),optional :: name
    integer, intent(in),optional :: unit
    integer, intent(in),optional :: step
    integer :: d
    integer :: i, j, k, l, istep, iunit

    d = (nint(sqrt(real(8*size(matrix, 1) + 1, wp))) - 1)/2

    if (present(unit)) then
        iunit = unit
    else
        iunit = output_unit
    end if

    if (present(step)) then
        istep = step
    else
        istep = 5
    end if

    if (present(name)) write(iunit,'(/,"matrix printed:",1x,a)') name
    do i = 1, d, istep
        l = min(i+istep-1, d)
        write(iunit, '(/,6x)', advance='no')
        do k = i, l
            write(iunit, '(6x,i7,3x)', advance='no') k
        end do
        write(iunit, '(a)')
        do j = i, d
            l = min(i+(istep-1), j)
            write(iunit,'(i6)', advance='no') j
            do k = i, l
                write(iunit,'(1x,f15.8)', advance='no') matrix(j*(j-1)/2+k)
            end do
            write(iunit,'(a)')
        end do
    end do

end subroutine write_packed_matrix


end module print_matrix
