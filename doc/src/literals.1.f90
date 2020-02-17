program literals
  implicit none

  intrinsic :: selected_real_kind
  ! kind parameter for real variables
  integer, parameter :: wp = selected_real_kind(15)
  real(wp) :: a, b, c

  a = 1.0_wp / 6.0_wp
  b =    1.0 / 6.0
  c =      1 / 6

  write(*, *) 'a is', a
  write(*, *) 'b is', b
  write(*, *) 'c is', c

end program literals
