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
  !> atom type
  integer, allocatable  :: at(:)
end type
  
  type(geometry)        :: geo


! define number of atoms
geo%n = 3

! allocate memory for atoms  and set initial values to zero
allocate(geo%xyz(3, geo%n), source=0.0_wp)
allocate(geo%at(geo%n), source=0)

! define atom types and positions
! first atom is oxygen
geo%at(1) = 8
geo%xyz(1,1) = -1.16_wp
! second atom is carbon
geo%at(2) = 6
! third atom is oxygen
geo%at(3) = 8
! carbondioxide should be linear and symetric
! therefore the x-coordinate of the new oxygen should be 1.16 angstrom
geo%xyz(1,3) =  1.16_wp

call geometry_info(geo)


contains

subroutine geometry_info(geo)
  type(geometry)    :: geo
  integer           :: i
  write(*,'(a, i0, a)') 'The input geometry has ', geo%n, ' atoms.'
  write(*,'(a)') 'Writing atom positions followed by atom type:'
  do i=1, geo%n
    write(*,'(3f10.4,4x,i0)') geo%xyz(:,i), geo%at(i)
  enddo
end subroutine geometry_info


end program derived_types
