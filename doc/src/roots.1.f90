program roots
  implicit none
  ! sqrt is the square root and abs is the absolute value
  intrinsic :: selected_real_kind, sqrt, abs
  integer, parameter :: wp = selected_real_kind(15)
  real(wp) :: p, q
  real(wp) :: d

  ! request user input
  write(*, *) "Solving x² + p·x + q = 0, please enter p and q"
  read(*, *) p, q
  d = 0.25_wp * p**2 - q
  ! discriminant is positive, we have two real roots
  if (d > 0.0_wp) then
    write(*, *) "x1 =", -0.5_wp * p + sqrt(d)
    write(*, *) "x2 =", -0.5_wp * p - sqrt(d)
  ! discriminant is negative, we have two complex roots
  else if (d < 0.0_wp) then
    write(*, *) "x1 =", -0.5_wp * p, "+ i ·", sqrt(abs(d))
    write(*, *) "x2 =", -0.5_wp * p, "- i ·", sqrt(abs(d))
  else  ! discriminant is zero, we have only one root
    write(*, *) "x1 = x2 =", -0.5_wp * p
  endif
end program roots
