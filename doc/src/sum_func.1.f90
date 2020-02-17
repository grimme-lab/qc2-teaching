program array_sum
  implicit none
  interface
  function sum_func(vector) result(vector_sum)
    integer, intent(in) :: vector(:)
    integer :: vector_sum
  end function sum_func
  end interface
  integer :: ndim
  integer, allocatable :: vec(:)
  ! read the dimension of the vector first
  read(*, *) ndim
  ! request the necessary memory
  allocate(vec(ndim))
  ! now read the ndim elements of the vector
  read(*, *) vec
  write(*, *) "Sum of all elements", sum_func(vec)
end program array_sum

function sum_func(vector) result(vector_sum)
  implicit none
  intrinsic :: size
  integer, intent(in) :: vector(:)
  integer :: vector_sum, i
  vector_sum = 0
  do i = 1, size(vector)
    vector_sum = vector_sum + vector(i)
  end do
end function sum_func
