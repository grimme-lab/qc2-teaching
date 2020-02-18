program my_scf
!* this is the standard FORTRAN environment, which contains some declarations
!  which are useful for I/O-heavy tasks.
!  output_unit = STDOUT, error_unit = STDERR,  input_unit = STDIN
!  iostat_end  = EOF,    iostat_eor = newline, real64     = double precision
   use iso_fortran_env

!! ======================================================================== !!
!  library functions provided by your lab assistents:

!* interface to LAPACK's double precision symmetric eigenvalue solver (dspev)
   use linear_algebra
!  examples:
!  call solve_spev(mat,eigval,eigvec)

!* expansion of slater-functions into contracted gaussians,
!  coefficients and primitive exponents are taken from R.F. Stewart, JCP, 1970
   use slater
!  example:
!  call slater_expansion(6,zeta,alpha,coeff)

!* calculates one-electron integrals and two-electron integrals over
!  spherical gaussians (s-functions). One-electron quanities supported
!  are overlap, kinetic energy and nuclear attraction integrals.
!  Two-electron integrals are provided in chemist notation.
   use integrals
!  examples:
!  call oneint(npa,npb,nat,xyz,chrg,r_a,r_b,alp,bet,ci,cj,s,t,v)
!  call twoint(npa,npb,npc,npd,r_a,r_b,r_c,r_d,alp,bet,gam,del,ci,cj,ck,cl,g)

!* prints a matrix quantity to screen
   use print_matrix
!  examples:
!  call prmat(mat,n,n,name='matrix')
!  call prmat(mat,n,name='packed matrix')

!* other tools that may help you jump ahead with I/O-heavy tasks
   use io_tools
!  examples:
!  call rdcmdarg(1,input_name)
!  call getline(input_unit,input_name)
!! ======================================================================== !!

!  include this line in *every* function and subroutine you write
   implicit none

!* system specific data
!  number of atoms
   integer :: nat
!  number of electrons
   integer :: nel
!  atom coordinates of the system, all distances in bohr
   real(8),allocatable :: xyz(:,:)
!  nuclear charges
   real(8),allocatable :: chrg(:)

!  number of basis functions
   integer :: nbf
!  slater exponents of basis functions
   real(8),allocatable :: zeta(:)

!  name of the input file
   character(len=:),allocatable :: input_name

!  Hartree-Fock energy
   real(8) :: escf

!  declarations may not be complete, so you have to add your own soon.
!  Create a program that reads the input and prints out final results.
!  And, please, indent your code.

!  Write the self-consistent field procedure in a subroutine.
   write(output_unit,'(a)') 'Here could start a Hartree-Fock calculation'

   write(error_unit, '(a)') 'normal termination of my program'

contains
!  Put all subroutines and functions here or use modules


end program my_scf
