WP8 -- Quantum Chemistry II
===========================

This is the guide to the practical course for WP8.

.. code:: fortran

   program my_scf
      use, intrinsic :: iso_fortran_env

      implicit none

   !  system specific data
   !> number of atoms
      integer(kind=int32) :: nat
   !> number of electrons
      integer(kind=int32) :: nel
   !> atom coordinates of the system, all distances in bohr
      real(kind=real64), allocatable :: xyz(:,:)
   !> nuclear charges
      real(kind=real64), allocatable :: chrg(:)

   !> number of basis functions
      integer(kind=int32) :: nbf
   !> slater exponents of basis functions
      real(kind=real64), allocatable :: zeta(:)

   !> name of the input file
      character(len=:), allocatable :: input_name

   !> Hartree-Fock energy
      real(kind=real64) :: escf

   !  declarations may not be complete, so you have to add your own soon.
   !  Create a program that reads the input and prints out final results.
   !  And, please, indent your code.

   !  Write the self-consistent field procedure in a subroutine.
      write(output_unit, '(a)') "Here could start a Hartree-Fock calculation"

      ...

   end program my_scf


.. toctree::
   :maxdepth: 3
   :caption: Programming

   intro
