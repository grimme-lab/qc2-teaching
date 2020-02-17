program cumulative_sum
  implicit none
  integer :: i, n
  integer :: number
  ! initialize
  number = 0
  read(*, *) n
  do i = 1, n
    number = number + i
  end do
  write(*, *) "Sum is", number
end program cumulative_sum
