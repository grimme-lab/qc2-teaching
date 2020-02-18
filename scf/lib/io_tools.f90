!> general tools for input/output tasks
!  this module implements wrappers for common input tasks
module io_tools
implicit none

intrinsic :: present,get_command_argument,allocated

contains

!> read from `unit' (bound to a file or STDIN) into the `line'.
! `line' is a deferred-length character, holding the content of one line
!  read from `unit' after successful termination of `getline'.
!
!  example for a simple reader with getline
!  reads arbitrary number of coordinate tuples (x,y,z) from a file
!
!  subroutine read_input_file(unit,npoints,grid)
!  use iso_fortran_env
!  use io_tools
!  integer,intent(in) :: unit
!  integer,intent(out) :: npoints
!  real(real64),allocatable,intent(out) :: grid(:,:)
!  character(len=:),allocatable :: line
!  real(real64) :: x,y,z
!  integer :: n
!  integer :: error
!  intrinsic :: len,is_iostat_end
!  n = 0
!  count_lines: do
!     call getline(unit,line,error)
!     if (is_iostat_end(error)) exit count_lines
!     if (len(line) == 0) cycle count_lines
!     n = n+1
!  enddo count_lines
!  npoints = n
!  allocate( grid(3,npoints), source = 0.0_real64 )
!  rewind(unit)
!  n = 0
!  read_lines: do
!     call getline(unit,line,error)
!     if (is_iostat_end(error)) exit read_lines
!     if (len(line) == 0) cycle read_lines
!     n = n+1
!     if (n > npoints) exit read_lines ! something went wrong
!     read(line,*,iostat=error) x,y,z
!     if (error /= 0) then
!        write(error_unit,'("#ERROR!",1x,a)') "could not read from: '"//line//"'"
!        error stop
!     endif
!     grid(:,n) = [x,y,z]
!  enddo read_lines
!  end subroutine read_input_file
!
subroutine getline(unit,line,iostat)
   use iso_fortran_env, only : iostat_eor
   implicit none
   integer,intent(in) :: unit
   character(len=:),allocatable,intent(out) :: line
   integer,intent(out),optional :: iostat

   integer,parameter  :: buffersize=128
   character(len=buffersize) :: buffer
   integer :: size
   integer :: err

   line = ''
   do
      read(unit,'(a)',advance='no',iostat=err,size=size)  &
      &    buffer
      if (err.gt.0) exit ! an error occured
      line = line // buffer(:size)
      if (err.lt.0) exit
   enddo
   if (err.eq.iostat_eor) err = 0
   if (present(iostat)) iostat=err

end subroutine getline

!> read the `i'th commandline argument into `arg'
!
!  example for a simple parser
!  
!  subroutine read_command_arguments(file,lgrad)
!  use iso_fortran_env
!  use io_tools
!  character(len=:),allocatable,intent(out) :: file ! input file name
!  logical,intent(out) :: lgrad ! calculate gradient
!  ! local variables
!  integer :: iarg,nargs
!  logical :: exist
!  character(len=:),allocatable :: arg
!  intrinsic :: command_argument_count,allocated
!  nargs = command_argument_count()
!  do iarg = 1, nargs
!     call rdcmdarg(iarg,arg)
!     select case(arg)
!     case('--help')
!        call write_help(output_unit)
!        stop
!     case('--grad')
!        lgrad = .true.
!     case default ! no match -> check for filename
!        inquire(file=arg,exist=exist)
!        if (exist) then
!           file = arg
!        endif
!     end select
!  enddo
!  if (.not.allocated(file)) then
!     write(error_unit,'("#ERROR!",1x,a)') "no file given"
!     error stop
!  endif
!  end subroutine read_command_arguments
!
subroutine rdcmdarg(i,arg,iostat)
   implicit none
   integer,intent(in) :: i
   character(len=:),allocatable,intent(out) :: arg
   integer,intent(out),optional :: iostat
   integer :: l,err
   if (allocated(arg)) deallocate(arg)
   call get_command_argument(i,length=l,status=err)
   if (err.ne.0) then
      if (present(iostat)) iostat = err
      return
   endif
   allocate( character(len=l) :: arg, stat=err )
   if (err.ne.0) then
      if (present(iostat)) iostat = err
      return
   endif
   call get_command_argument(i,arg,status=err)
   if (present(iostat)) iostat = err
end subroutine rdcmdarg

end module io_tools
