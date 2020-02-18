module linear_algebra
implicit none
integer,private,parameter :: wp = selected_real_kind(15)

public  :: solve_spev
private :: xerbla,dspev

!* interfaces to lapack
interface
pure subroutine dspev( jobz, uplo, n, ap, w, z, ldz, work, info )
   import wp
   integer,  intent(in)    :: ldz
   real(wp), intent(inout) :: ap(*)
   real(wp), intent(out)   :: w(*)
   real(wp), intent(out)   :: z(ldz,*)
   character,intent(in)    :: jobz
   character,intent(in)    :: uplo
   integer,  intent(out)   :: info
   integer,  intent(in)    :: n
   real(wp), intent(inout) :: work(*)
end subroutine dspev
pure subroutine xerbla(name,info)
   character(len=*),intent(in) :: name
   integer, intent(in) :: info
end subroutine xerbla
end interface

contains

pure subroutine solve_spev(a,w,v,info_out)
!  plain lapack call:
!  dspev(jobz,uplo,n,a,w,v,n,work,info)

   implicit none

!  symmetric matrix a is diagonalized by this routine
!  eigenvalues of a are written to w
!  eigenvectors are written to v if provided
   real(wp),intent(inout) :: a(:)
   real(wp),intent(out)   :: w(:)
   real(wp),intent(out)   :: v(:,:)
   integer, intent(out),optional :: info_out
!  for xerbla output
   character(len=*),parameter :: thisis = 'dspev'
!  local variables
   character,parameter :: jobz = 'v'
   character,parameter :: uplo = 'u'
   integer   :: info
   integer   :: n
   integer   :: np
!  workspace for dspev
   real(wp),allocatable :: work(:)

   intrinsic :: max,present,size

   info = 0

   n  = max(1,size(w,1))
   np = max(1,size(a,1))

   ! dimension missmatch
   if (np /= n*(n+1)/2) then
      info = 1000
   endif

!  allocate work arrays with requested size
   allocate( work(3*n), stat=info )

!  call lapack routine
   if(info.eq.0) then
      call dspev(jobz,uplo,n,a,w,v,n,work,info)
   else
      info = 1000
   endif

!  deallocate work arrays with requested sizes
   deallocate( work, stat=info )

!  error handler
   if (present(info_out)) then
      info_out = info
   else if(info.ne.0) then
      call xerbla(thisis,info)
   endif

end subroutine solve_spev

end module linear_algebra
