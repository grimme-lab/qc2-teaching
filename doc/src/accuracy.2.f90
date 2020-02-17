program accuracy
  implicit none

  intrinsic :: selected_real_kind
  ! kind parameter for real variables
  integer, parameter :: wp = selected_real_kind(15)
  real(wp) :: a, b, c

  ! also use the kind parameter here
  a = 1.0_wp
  b = 6.0_wp
  c = a / b

  write(*, *) 'a is', a
  write(*, *) 'b is', b
  write(*, *) 'c is', c

end program accuracy
