program kinds
  implicit none
  intrinsic :: selected_real_kind
  integer :: single, double
  single = selected_real_kind(6)
  double = selected_real_kind(15)
  write(*, *) "For 6 significant digits", single, "bytes are required"
  write(*, *) "For 15 significant digits", double, "bytes are required"
end program kinds
