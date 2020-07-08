program array_rank
  implicit none

  intrinsic :: selected_real_kind
  ! kind parameter for real variables
  integer, parameter :: wp = selected_real_kind(15)
  integer :: i
  integer :: d1, d2
  real(wp), allocatable :: arr2(:, :)

  read(*, *) d1, d2

  allocate(arr2(d1, d2))

  do i = 1, size(arr2, 2)
    read(*, *) arr2(:, i)
  end do

end program array_rank
