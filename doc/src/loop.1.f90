program loop
  implicit none
  integer :: i
  integer :: number
  ! initialize
  number = 0
  do
    read(*, *) i
    if (i <= 0) then
      exit
    else
      number = number + i
    end if
  end do
  write(*, *) "Sum of all input", number
end program loop

