module array_funcs
  implicit none
contains
  subroutine sum_sub(vector, vector_sum)
    intrinsic :: size
    integer, intent(in) :: vector(:)
    integer, intent(out) :: vector_sum
    integer :: i
    vector_sum = 0
    do i = 1, size(vector)
      vector_sum = vector_sum + vector(i)
    end do
  end subroutine sum_sub
end module array_funcs

program array_sum
  use array_funcs
  implicit none
  integer :: ndim
  integer, allocatable :: vec(:)
  integer :: vec_sum
  ! read the dimension of the vector first
  read(*, *) ndim
  ! request the necessary memory
  allocate(vec(ndim))
  ! now read the ndim elements of the vector
  read(*, *) vec
  call sum_sub(vec, vec_sum)
  write(*, *) "Sum of all elements", vec_sum
end program array_sum
