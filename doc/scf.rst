Introduction to Quantum Chemistry
=================================

The main objective of this course is to write a working restricted Hartree-Fock
program.

Restricted Hartree-Fock
-----------------------

The first task in this course is to code a working restricted Hartree-Fock
program.

Getting Input
~~~~~~~~~~~~~

First we have to gather which information are important to perform a
Hartree-Fock calculation.
We need to know about the molecular geometry. There are several ways
to represent the geometry, the most simple is to use Cartesian coordinates
as a vector of *x*, *y* and *z* coordinates.
What maybe is not that obvious, we have to decide on a unit system for
the coordinates, usually we would follow IUPAC recommendations and use
SI units like meters, but if you think about a molecule on the length
scale in meters it becomes quite inconvenient.
To get into the right ballpark we could choose Ångström which have an
obvious relation to the SI unit, but here we will use Bohr which is
the length unit of the atomic units system.
Atomic units have the advantage that a lot of constants drop out of the
equations we want to code up and we can convert them easily back,
in fact we provide a conversion routine back to SI units for you.

This were the considerations we have to put in the geometry, now we have
to identify the atoms/nuclei in our molecule. Chemical identity like the
element is given by the nuclear charge and the number of electrons.
It is quite popular to specify both with the element symbol which
map to the atomic number (which corresponds to the nuclear charge and the
number of electrons of the neutral atom), since it is the intuitive choice.
We will not follow this approach, since it would require you to work with
character type variables, instead we will separate the nuclear charge information
and the number of electrons. For each element we will read the nuclear charge
in multiples of the electron charge (which is the atomic unit of charge)
and specify the number of electrons separately.

Having put some thoughts in the geometric representation of the system,
we now have to tackle the electronic representation, we need a basis set
to expand our wavefunction.
There are many possible choices, like atom centered basis functions
(Slater-type, Gaussian-type, ...) plain waves, wavelets, ...
This is one of the most important choices for every quantum chemistry code,
usually a single kind of functions is supported which is limiting the chemical
systems which can be calculated with this.
The most common distinction is made between codes that support periodic boundary
conditions or not, while periodic boundary conditions are naturally included
in plain wave and wavelet based programs, extra effort has to be put into
codes using Gaussian-type basis function to support this kind of calculations.
Also most wavefunction centered programs use atom centered orbitals since the
resulting integrals are easier to solve.
Here the exception from the rule is quite common in our field of research
and usually offers a unique competitive edge.

For writing your Hartree-Fock program you do not have to bother with this
choice, because we already made it for you by providing the implementation
for integrals over Gaussian-type basis functions.
We will limit you here to spherical basis functions only, so you can concentrate
on coding the self-consistent field procedure and do not have to worry about
mapping shells to orbitals to basis functions to primitives.

We will start with the input for the dihydrogen molecule in a minimal basis set.
With the input format we provide, the geometrical structure of the system
and the basis set are tied together.

.. code-block:: none
   :caption: h2.in
   :linenos:

   2 2 2
   0.0  0.0 -0.7  1.0  1
   1.20 
   0.0  0.0  0.7  1.0  1
   1.20

This input contains the information necessary to code up your program,
we start with the first line, which contains the number of atoms,
the number electrons and the total number of basis functions as integer
values.
None of this information is necessary to read the input file, but is
included for convenience, *e.g.* such that you can allocate memory before
starting to read the rest of the file.

Starting from the second line we expect a tuple of the three Cartesian
coordinates in Bohr, the nuclear charges in multiples of electron charge
and the number of basis functions this particular atom.
In the lines after position and identity we find the exponents of our basis 
functions, the number of lines following corresponds to the number of
basis functions for this particular atom.

.. admonition:: Exercise 1

   Before you start coding the input reader for this format, try
   to write with the specifications inputs for the following systems:

   1. A helium atom in a double zeta basis set with exponents 2.5 and 1.0.
   2. A helium-hydrogen cation with a bond distance of 2 Bohr in a minimal
      basis set on both atoms and an  exponent of 1.25 for each atom.

.. admonition:: Solutions 1

   For a single atom the choice of the position is unimportant, so we
   can write something like

   .. code-block:: none
      :caption: he.in
      :linenos:

      1 2 2
      0.0  0.0  0.0  2.0  2
      2.5 
      1.0

   The helium-hydrogen cation looks similar to the dihydrogen, except for
   the changed nuclear charge.

   .. code-block:: none
      :caption: heh+.in
      :linenos:

      2 2 2
      0.0  0.0 -1.0  2.0  1
      1.25
      0.0  0.0  1.0  1.0  1
      1.25

.. admonition:: Exercise 2

   1. Code an input reader that can read all the provided input files.
   2. Make sure the input file is read correctly by printing all data read
      to the terminal.

Classical Contributions
~~~~~~~~~~~~~~~~~~~~~~~

First we start by computing the classical nuclear repulsion energy, *i.e.*
the Coulomb energy between the nuclei.

.. admonition:: Exercise 3

   1. Which data is needed in the computation?
   2. Code up the nuclear repulsion energy in a separate ``subroutine``.
      Write the resulting energy in a meaningful way to the terminal.
   3. Evaluate the Coulomb-law for the dihydrogen molecule at 1.4 Bohr
      distance and compare with your program.
      Can you run your ``subroutine`` multiple times and get the
      same result? If not recheck your code.
   4. Check what happens if calculate the nuclear repulsion energy for
      a single atom. Do you get the expected result?

Classical contributions to the total energy are everything independent from
the density or wavefunction, beside the nuclear repulsion energy
correction terms like dispersion are often calculated along with the
nuclear repulsion energy. It is strongly recommended to perform such
calculations before starting with the self consistent field procedure,
since an error afterwards can ruin an expensive calculation.

Basis set setup
~~~~~~~~~~~~~~~

This Hartree-Fock program will use contracted Gaussian-type orbitals to
expand the molecular orbitals in atomic orbitals.
We will use a STO-6G basis set, *i.e.* we use the best representation of a
Slater-type orbital by six primitive Gaussian-type orbitals.

This is the first time you will use an external library function, therefore
we will clarify to you how to read and use an ``interface``.
In your program you will call a provided ``subroutine`` to perform
the expansion from the Slater orbital to six primitive Gaussian-type orbitals.

The final call in your program might look somewhat similar to this:

.. code-block:: fortran

   call slater_expansion(ng, zeta, exponents, coefficients)

To understand why the ``subroutine slater_expansion`` takes four arguments,
we look up its ``interface``:

.. code-block:: fortran

   interface
   subroutine slater_expansion(ng, zeta, exponents, coefficients, normalize)
   import wp
   integer,  intent(in)  :: ng   !< number of primitive Gaussian functions
   real(wp), intent(in)  :: zeta !< exponent of slater function
   real(wp), intent(out) :: exponents(ng)    !< of primitive Gaussian functions
   real(wp), intent(out) :: coefficients(ng) !< of primitive Gaussian functions
   logical,  intent(in), optional :: normalize  !< default: .true.
   end subroutine slater_expansion
   end interface

An ``interface`` provides the necessary information on how to
invoke a ``subroutine`` or ``function`` without concerning
you with the implementation details.

.. note::

    for programmers coming from C or C++ it is similar to an ``extern``
    declaration in a header file for a function.

Usually you do not have to write an ``interface`` since they
are conveniently created and handled for you by your compiler.

.. admonition:: Exercise 4

   1. Create a ``parameter`` storing the information about the
      number of primitive Gaussian functions you want to expand your Slater
      function in.
   2. What is the optimal layout for saving the exponents and coefficients
      of the primitive Gaussian functions? Which quantities from the input
      do you need to determine the amount of memory to store them?
   3. Allocate enough space to store all the primitive exponents and coefficients
      from the expansion for calculating the integrals later.
   4. Loop over all basis functions, perform the expansion for each and save the
      resulting primitive Gaussian's to the respective arrays.

One-Electron Integrals
~~~~~~~~~~~~~~~~~~~~~~

Note that the basis set we have chosen is very simple, we only allow
spherical basis function (*s*-functions), also the contraction depth of
each function is the same. Usually one would choose more sophisticated
basis sets for quantitative calculations, but the basic principle remains
the same.

Integral calculations can quickly be very obscure depending on the way
a basis set is stored and mainly handle implementation specific details
of the program to perform the integral evaluation in some clever way.
We use a simple basis set here to teach you the basic principle of
integral evaluation.

We start with the simple one-electron integrals, for Hartree-Fock we need
two-center overlap integrals, two-center kinetic energy integrals and
three-center nuclear attraction integrals.
To make things easier we provide the implementation for all three integrals
over contracted Gaussian orbitals, let's checkout the ``interface``:

.. code-block:: fortran

   interface
   !> one electron integrals over spherical Gaussian functions
   subroutine oneint(npa,npb,nat,xyz,chrg,r_a,r_b,alp,bet,ci,cj,sab,tab,vab)
      import wp
      integer, intent(in)  :: npa !< number of primitives on center a
      integer, intent(in)  :: npb !< number of primitives on center b
      integer, intent(in)  :: nat !< number of atoms in the system
      real(wp),intent(in)  :: xyz(3,nat) !< position of all atoms in atomic units
      real(wp),intent(in)  :: chrg(nat) !< nuclear charges
      real(wp),intent(in)  :: r_a(3) !< aufpunkt of orbital a
      real(wp),intent(in)  :: r_b(3) !< aufpunkt of orbital b
      real(wp),intent(in)  :: alp(npa) !< Gaussian exponents of the primitives at a
      real(wp),intent(in)  :: bet(npb) !< Gaussian exponents of the primitives at b
      real(wp),intent(in)  :: ca(npa) !< contraction coeffients of primitives at a
      real(wp),intent(in)  :: cb(npb) !< contraction coeffients of primitives at b
      real(wp),intent(out) :: sab !< overlap integral <a|b>
      real(wp),intent(out) :: tab !< kinetic energy integral <a|T|b>
      real(wp),intent(out) :: vab !< nuclear attraction integrals <a|Σ z/r|b>
   end subroutine oneint
   end interface

The most important information is we need *two* centers for the calculation,
meaning we have to implement it as loop over all atom pairs.

.. admonition:: Exercise 5

   1. Which matrices do can you compute from the one electron integrals.
   2. Allocate space for the necessary matrices.
   3. Loop over all pairs and calculate all the matrix elements.

.. admonition:: Exercise 6

   Symmetric matrices, like the overlap, can be stored in two ways,
   as full *N×N* matrix with ``dimension(n,n)`` or as packed matrix
   in a one-dimensional array with ``dimension(n*(1+n)/2)``, like:

   .. math::

      \begin{pmatrix}
      1 & 2 & 4 & 7 & \cdots \\
        & 3 & 5 & 8 & \\
        &   & 6 & 9 & \\
        &   &   & 10& \\
      \vdots & & & & \ddots \\ 
      \end{pmatrix}
      \Leftrightarrow
      \begin{pmatrix}
      1 \\ 2 \\ 3 \\ 4 \\ \vdots \\
      \end{pmatrix}
      \qquad
      \begin{pmatrix}
      a_{11} & a_{12} & a_{13} & a_{14} & \cdots \\
             & a_{22} & a_{23} & a_{24} & \\
             &        & a_{33} & a_{34} & \\
             &        &        & a_{44} & \\
      \vdots &        &        &        & \ddots \\
      \end{pmatrix}
      \Leftrightarrow
      \begin{pmatrix}
      a_{11} \\ a_{12} \\ a_{22} \\ a_{13} \\ \vdots \\
      \end{pmatrix}

   1. Check if the matrices you have calculated are symmetric.
   2. Pack all symmetric matrices.

   The eigenvalue solver provided can only work with symmetric packed matrices,
   therefore you should have a unpacked to packed conversion routine ready for
   the next exercise.

Symmetric Orthonormalizer
~~~~~~~~~~~~~~~~~~~~~~~~~

The eigenvalue problem we have to solve is a general one given by

.. math::
   \mathbf F \mathbf C = \mathbf S \mathbf C \boldsymbol\varepsilon

where **F** is the Fock matrix, **C** is the matrix of the eigenvectors,
**S** is the overlap matrix and **ε** is a diagonal matrix of the eigenvalues.
While this in principle possible with a more elaborated solver routine,
we want to solve the problem instead:

.. math::
   \mathbf F^\prime \mathbf C^\prime = \mathbf C^\prime \boldsymbol\varepsilon

For this reason we have to find a transformation from **F** to **F'**
and back from **C'** to **C**.
We choose the Loewdin orthonormalization or symmetric orthonormalization
by calculating **X** = **S**:sup:`-1/2`, to invert (or perform any operation
with) a matrix we have to diagonalize it first and perform the operation on the
eigenvalues **s**.

.. math::
   \mathbf X = \mathbf S^{-1/2} = \mathbf U \mathbf s^{-1/2} \mathbf U^\top
   \qquad
   \text{where}
   \quad
   \mathbf s = \mathbf U^\top \mathbf S \mathbf U

.. admonition:: Exercise 7

   1. Use **F'** = **X**:sup:`T` **FX** and **C** = **XC'** to show that the
      general and eigenvalue problem and the transformed one are equivalent.
   2. write a ``subroutine`` to calculate the symmetric orthonormalizer
      **X** from the overlap matrix.
   3. Make sure that **X**:sup:`T` **SX** = **1** and that you are not overwriting
      your overlap matrix in the diagonalization.
   4. Do you see why **X** is called symmetric orthonormalizer?

Initial Guess
~~~~~~~~~~~~~

There are now two possible ways to initialize your density matrix **P**.

1. Provide a guess for the orbitals
2. Provide a guess for the Hamiltonian

If you happen to have converged orbitals around, the first method would be
the most suitable.
Alternatively you can provide a model Hamiltonian, usually a tight-binding
or extended Hückel Hamiltonian is used here.
The simplest possible model Hamiltonian we have readily available is the
core Hamiltonian **H**:sub:`0` = **T** + **V**.

The initial density matrix **P** is obtained from the orbital coefficients by

.. math::
   \mathbf P = \mathbf C\ \mathbf n_\text{occ} \mathbf C^\top

where **n**:sub:`occ` is a diagonal matrix with the occupation numbers of the
orbitals.
For the restricted Hartree-Fock case *n*:sub:`*i*,occ` is two for occupied orbitals
and zero for virtual orbitals.

.. admonition:: Exercise 8

   1. By using **F** = **H**:sub:`0` as initial guess for the Fock matrix we 
      effectively set the density matrix **P** to zero.
      What does this mean from a physical point of view?
   2. Add the initial guess to your program.
   3. Diagonalize the initial Fock matrix (use the symmetric orthonormalizer)
      to obtain a set of guess orbital coefficients **C**.
   4. Calculate the initial density matrix **P** resulting from this orbital
      coefficients.

Hartree-Fock Energy
~~~~~~~~~~~~~~~~~~~

The Hartree-Fock energy is given by

.. math::
    E_\text{HF} = \frac12\mathrm{Tr}\{(\mathbf H + \mathbf F) \mathbf P\}

where Tr denotes the trace.

.. admonition:: Exercise 9

   You should have now an initial Fock matrix **F** and an initial density
   matrix **P**.

   1. Write a ``subroutine`` to calculate the Hartree-Fock energy.
   2. Calculate the initial Hartree-Fock energy.

Two-Electron Integrals
~~~~~~~~~~~~~~~~~~~~~~

We have ignored the two-electron integrals for a while now, up to know
they were not important, but we will now need to calculate them to
perform an self-consistent field procedure.
The four-center two-electron integrals are the most expensive quantity
in any Hartree-Fock calculation and there exist many clever algorithms
to avoid calculating them all together, we will again go the straight-forward
way and calculate them the naive way.

Again we will check the ``interface`` of the ``twoint`` routine
in ``lib/integrals.f90``.

.. admonition:: Exercise 10

   1. Allocate enough space to store the two electron integrals.
   2. Create a (nested) loop to calculate all two electron integrals.

.. admonition:: Exercise 11

   The four-center integrals have a eight-fold symmetry relation we want to use
   when calculating such an expensive integral to speed up the calculation.
   Rewrite your loops to only calculate the unique integrals:

   .. math::
      (\mu\nu|\kappa\lambda) =
      (\nu\mu|\kappa\lambda) =
      (\mu\nu|\lambda\kappa) =
      (\nu\mu|\lambda\kappa) =
      (\kappa\lambda|\mu\nu) =
      (\kappa\lambda|\nu\mu) =
      (\lambda\kappa|\mu\nu) =
      (\lambda\kappa|\nu\mu)

   1. Write down all the indices for the four-center integrals and figure out
      unique relation between the indices (it is similar to packing matrices).
   2. Implement this eight-fold-symmetry in your calculation.
   3. You can also pack the two-electron integrals like you packed your matrices
      (you need to pack them three times, the bra and the ket separately,
      and then the packed bra and ket again).
      Note that this will make it later more difficult to access the values again,
      therefore it is optional.

Self Consistent Field Procedure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now you have everything together to build the self-consistent field loop.

.. admonition:: Exercise 12

   1. First you need to construct a new Fock matrix from the density matrix.
   2. Construct a loop that performs your self consistent field calculation.
   3. Copy or move (whatever you find more appropriate) the necessary steps
      inside the SCF loop.
   4. Define a convergence criterion using a conditional statement (``if``)
      based on the energy change and/or the change in the density matrix
      and ``exit`` the SCF loop.


Properties
----------

HOMO-LUMO Gap
~~~~~~~~~~~~~

Partial Charges
~~~~~~~~~~~~~~~

Charge Density
~~~~~~~~~~~~~~


Geometry Optimization
---------------------

Numerical Derivatives
~~~~~~~~~~~~~~~~~~~~~

Steepest Decent
~~~~~~~~~~~~~~~


Unrestricted Hartree-Fock
-------------------------


Møller-Plesset Perturbation Theory
----------------------------------

