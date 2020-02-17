program add
  implicit none
  ! declare variables: integers
  integer :: a, b
  integer :: res

  ! get two values to be stored in a and b
  read(*, *) a, b

  res = a + b  ! perform the addition

  write(*, *) "The result is", res
end program add
