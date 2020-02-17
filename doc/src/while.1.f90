program while_loop
  implicit none
  integer :: i
  integer :: number
  ! initialize
  number = 0
  read(*, *) i
  do while(i > 0)
    number = number + i
    read(*, *) i
  end do
  write(*, *) "Sum of all input", number
end program while_loop
