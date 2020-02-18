module print_matrix
implicit none
integer,private,parameter :: wp = selected_real_kind(15)

public  :: prmat
private :: prgemat,prsymat

interface prmat
   module procedure prgemat
   module procedure prsymat
end interface prmat

contains

subroutine prgemat(mat,d1,d2,name,unit,step)
   use iso_fortran_env, only : output_unit
   implicit none
   integer, intent(in) :: d1
   integer, intent(in) :: d2
   real(wp),intent(in) :: mat(d1,d2)
   character(len=*),intent(in),optional :: name
   integer, intent(in),optional :: unit
   integer, intent(in),optional :: step
   integer :: i,j,k,l,istep,iunit

   if (present(unit)) then
      iunit = unit
   else
      iunit = output_unit
   endif

   if (present(step)) then
      istep = step
   else
      istep = 5
   endif

   if(present(name)) write(iunit,'(/,''matrix printed:'',1x,a)') name

   do i = 1, d2, istep
      l = min(i+istep-1,d2)
      write(iunit,'(/,6x)',advance='no')
      do k = i, l
         write(iunit,'(6x,i7,3x)',advance='no') k
      enddo
      write(iunit,'(a)')
      do j = 1, d1
         write(iunit,'(i6)',advance='no') j
         do k = i, l
            write(iunit,'(1x,f15.8)',advance='no') mat(j,k)
         enddo
         write(iunit,'(a)')
      enddo
   enddo
end subroutine prgemat

subroutine prsymat(mat,d,name,unit,step)
   use iso_fortran_env, only : output_unit
   implicit none
   integer, intent(in) :: d
   real(wp),intent(in) :: mat(d*(d+1))
   character(len=*),intent(in),optional :: name
   integer, intent(in),optional :: unit
   integer, intent(in),optional :: step
   integer :: i,j,k,l,istep,iunit

   if (present(unit)) then
      iunit = unit
   else
      iunit = output_unit
   endif

   if (present(step)) then
      istep = step
   else
      istep = 5
   endif

   if(present(name)) write(iunit,'(/,''matrix printed:'',1x,a)') name
   do i = 1, d, istep
      l = min(i+istep-1,d)
      write(iunit,'(/,6x)',advance='no')
      do k = i, l
         write(iunit,'(6x,i7,3x)',advance='no') k
      enddo
      write(iunit,'(a)')
      do j = i, d
         l = min(i+(istep-1),j)
         write(iunit,'(i6)',advance='no') j
         do k = i, l
            write(iunit,'(x,f15.8)',advance='no') mat(j*(j-1)/2+k)
         enddo
         write(iunit,'(a)')
      enddo
   enddo
end subroutine prsymat

end module print_matrix
