program cumulative_sum
  implicit none
  intrinsic :: modulo
  integer :: i, n
  integer :: number
  ! initialize
  number = 0
  read(*, *) n
  do i = 1, n
    if (modulo(i, 2) == 1) cycle
    number = number + i
  end do
  write(*, *) "Sum is", number
end program cumulative_sum
