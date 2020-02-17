program array
  implicit none
  intrinsic :: sum, product, maxval, minval
  integer :: vec(3)
  ! get all elements from standard input
  read(*, *) vec
  ! produce some results
  write(*, *) "Sum of all elements", sum(vec)
  write(*, *) "Product of all elemnts", product(vec)
  write(*, *) "Maximal/minimal value at", maxval(vec), minval(vec)
end program array
