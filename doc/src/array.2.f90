program array
  implicit none
  intrinsic :: sum, product, maxval, minval
  integer :: ndim
  integer, allocatable :: vec(:)
  ! read the dimension of the vector first
  read(*, *) ndim
  ! request the necessary memory
  allocate(vec(ndim))
  ! now read the ndim elements of the vector
  read(*, *) vec
  write(*, *) "Sum of all elements", sum(vec)
  write(*, *) "Product of all elemnts", product(vec)
  write(*, *) "Maximal/minimal value", maxval(vec), minval(vec)
end program array

