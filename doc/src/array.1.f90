program array
  implicit none
  intrinsic :: sum, product, maxval, minval
  integer :: vec(3)
  ! get all elements from standard input
  read(*, *) vec
  ! produce some results
  write(*, *) "Sum of all elements", sum(vec)
  write(*, *) "Product of all elemnts", product(vec)
  write(*, *) "Maximal/minimal value", maxval(vec), minval(vec)
  write(*,*) "Positions of maximal/minimal values", maxloc(vec), minloc(vec)
end program array
