program derived_types
  implicit none
  intrinsic             :: selected_real_kind
  integer, parameter    :: wp = selected_real_kind(15)

! derived type cleary specifying a chemical structure
type :: geometry
  !> number of atoms
  integer               :: n
  !> xyz coordinates of the atoms in angstrom
  real(wp), allocatable :: xyz(:,:)
end type
  
  type(geometry)        :: geo


! define number of atoms
geo%n = 2

! allocate memory for atoms  and set initial values to zero
allocate(geo%xyz(3, geo%n), source=0.0_wp)

! define atom types and positions
! first atom is oxygen
geo%xyz(1,1) = -1.16_wp
! second atom is carbon

! third atom is oxygen


call geometry_info(geo)


contains

subroutine geometry_info(geo)
  type(geometry)    :: geo
  integer           :: i
  write(*,'(a, i0, a)') 'The input geometry has ', geo%n, ' atoms.'
  write(*,'(a)') 'Writing atom positions:'
  do i=1, geo%n
    write(*,'(3f10.4)') geo%xyz(:,i)
  enddo
end subroutine geometry_info


end program derived_types
