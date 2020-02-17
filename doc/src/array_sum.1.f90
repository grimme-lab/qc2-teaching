program array_sum
  implicit none
  intrinsic :: size
  integer :: ndim, i, vec_sum
  integer, allocatable :: vec(:)
  ! read the dimension of the vector first
  read(*, *) ndim
  ! request the necessary memory
  allocate(vec(ndim))
  ! now read the ndim elements of the vector
  read(*, *) vec
  vec_sum = 0
  do i = 1, size(vec)
    vec_sum = vec_sum + vec(i)
  end do
  write(*, *) "Sum of all elements", vec_sum
end program array_sum
