Quantum Chemistry Software
==========================

This section will give a short introduction and an overview of the Quantum
Chemistry programs that will be used in this practical course.

.. contents::


Setting up the Software
-----------------------

In order to gain access to the needed software packages, you need to
make some changes to your system. The ``.bashrc`` file located
in your home directory is sourced every time you open a new shell.
While you can directly execute any program by giving the full path,
it is more convenient to tell the system where to look for the
binaries by saving the location in the ``$PATH`` variable.
Additionally, some programs need global variables. All those
are usually set in the ``.bashrc``. In order to gain access to all the
needed software, add the following lines to your ``.bashrc``:

.. code-block:: none
   :linenos:

   # AKbin
   export PATH=/home/abt-grimme/AK-bin:$PATH
   export PATH=/home/$USER/bin:$PATH

   # TURBOMOLE
   export TURBODIR=/software/turbomole702
   export PATH=$TURBODIR/scripts:$PATH
   export PATH=$TURBODIR/bin/`sysname`:$PATH

   # ORCA
   ORCABINPATH=/home/software/orca-4.0.0
   PATH=$ORCABINPATH:$PATH

   # XTB
   export OMP_NUM_THREADS=2
   export MKL_NUM_THREADS=2
   export OMP_STACKSIZE=500m
   ulimit -s unlimited

Be sure to create a directory called ``bin`` in your home directory by typing:

.. code-block:: none

   mkdir ~/bin
.. export TURBODIR=/home/abt-grimme/TURBOMOLE.7.0.2

.. important:: All changes apply to shells opened afterwards.

If you want to apply the changes to your current shell, you
need to run:

.. code-block:: none

   source ~/.bashrc


Program Packages
----------------

TURBOMOLE
~~~~~~~~~

To run a calculation with TURBOMOLE, you will need the following files:

- ``coord``: Molecular geometry in atomic units
- ``control``: All data required for the calculation (method, parameters, ... )
- ``basis`` (and ``auxbasis``): Basis set (and auxiliary basis set for RI)
- ``mos`` or ``alpha`` and ``beta``: Orbitals (MO-coefficients) for restricted and unrestricted treatment, respectively

To manually prepare a calculation, use ``define``. However, in this course,
we will employ a tool that automatically runs ``define`` with the proper
input: ``cefine``.

TURBOMOLE has different binaries and scripts for different jobs.
While they do not need an explicit input file when called, you should **always**
pipe the output into a file, *e.g.*:

.. code-block:: none

   ridft > ridft.out &

The most important scripts that come along with the TURBOMOLE program package are listed
in the following table.

+----------------------+----------------------------------------------------------+
| TURBOMOLE script     | Functionality                                            |
+======================+==========================================================+
| *Most important scripts for calculations*                                       |
+----------------------+----------------------------------------------------------+
| ``ridft``            | DFT and HF SCF calculations with the RI-approximation    |
+----------------------+----------------------------------------------------------+
| ``dscf``             | DFT and HF SCF calculations without the RI-approximation |
+----------------------+----------------------------------------------------------+
| ``ricc2``            | Module for correlated WF methods (MP2, CCSD(T), ...)     |
+----------------------+----------------------------------------------------------+
| ``rdgrad``, ``grad`` | Calculate gradients (with and without RI)                |
+----------------------+----------------------------------------------------------+
| ``aoforce``          | Calculate analytical vibrational frequencies             |
+----------------------+----------------------------------------------------------+
| ``statpt``           | Coordinate/Hessian update for stationary point searches  |
+----------------------+----------------------------------------------------------+
| ``jobex``            | Script for geometry optimizations                        |
+----------------------+----------------------------------------------------------+
| *Scripts for visualization purposes*                                            |
+----------------------+----------------------------------------------------------+
| ``eiger``            | Show the orbital energies and the HOMO-LUMO gap          |
+----------------------+----------------------------------------------------------+
| ``x2t``              | Convert a \*.xyz file to coord                           |
+----------------------+----------------------------------------------------------+
| ``t2x``              | Convert a coord file to \*.xyz                           |
+----------------------+----------------------------------------------------------+
| ``tm2molden``        | Generate a molden input                                  |
+----------------------+----------------------------------------------------------+

.. important:: Each TURBOMOLE calculation needs its own directory.


cefine
~~~~~~

.. important::

   In this course, we will only use the current version of the below mentioned program
   called ``cefine_current``, but we will call it ``cefine`` in the following text.
   You can either type ``cefine_current`` instead everytime ``cefine`` is mentioned or
   (the recommended procedure) set up a symbolic link via typing the following line:

   .. code-block:: none

      ln -s /home/abt-grimme/AK-bin/cefine_current ~/bin/cefine

   Now you can type the lines given in this script as they appear.

``cefine`` is a command line tool that prepares the necessary input files
for TURBOMOLE. By default, it reads the ``coord`` file (the only file you have to
provide) in the directory where it is called. The basic command is:

.. code-block:: none

   cefine -<method> -bas <basis>

where ``<method>`` defines the type of calculation and ``<basis>``
the desired basis set.
To get an overview over the most important command line options, use

.. code-block:: none

   cefine -h

In the following exercises, the proper options will always be given
in the text. Additionally, you can find a short list of the options
in the section :ref:`Short cefine reference`.


ORCA
~~~~

ORCA needs an input file (*e.g.* ``myinput.inp``) to run. A typical call to perform a calculation with ORCA would be

.. code-block:: none

   orca myinput.inp > myinput.out &

The input file is generally structured as follows:

.. code-block:: none
   :linenos:

   # Comment lines are marked with an '#' and are possible everywhere
   ! Method Basis and further options

   # Input is organized in blocks which start with '%'
   # e.g.
   %scf
           MaxIter 150 #maximum number of iteration steps in the scf,
                       #default = 50
   end
   # definition of input geometry
   * xyz <charge> <multiplicity>
           cartesian coordinates (Angstroms)
   *
   or:
   * int <charge> <multiplicity>
           Z-Matrix
   or:
   * xyzfile <charge> <multiplicity> <filename.xyz>
   *

.. important:: Multiplicity = 2S+1 with S being the total spin.

A short reference of ORCA keywords can be found in the section :ref:`Short ORCA reference`.
Further information is accessible from: https://sites.google.com/site/orcainputlibrary/.


.. _Short cefine reference:

Short ``cefine`` Reference
--------------------------

In general, you can list all desired options for ``cefine`` after the program command:

.. code-block:: none

   cefine <option1> <option2> ...

You can always call a complete list of options with the ``-h`` option:

.. code-block:: none

   cefine -h

The following table lists the most important ``cefine`` options that are interesting for this course.

+------------------------+---------------------------------------------------------------------------------------+
| Command                | Functionality                                                                         |
+========================+=======================================================================================+
| *Computational Methods*                                                                                        |
+------------------------+---------------------------------------------------------------------------------------+
| ``-func <fname>``      | | DFT calculation with the ``<fname>`` functional. Note that the BYLP, B3YLP and      |
|                        | | B2PLYP functionals are named ``b-lyp``, ``b3-lyp`` and ``b2-plyp``, respectively.   |
+------------------------+---------------------------------------------------------------------------------------+
| ``-hf``                | HF calculation                                                                        |
+------------------------+---------------------------------------------------------------------------------------+
| ``-mp2``               | MP2 calculation (also sets up HF calculation)                                         |
+------------------------+---------------------------------------------------------------------------------------+
| ``-cc``                | CCSD(T) calculation (also sets up HF calculation)                                     |
+------------------------+---------------------------------------------------------------------------------------+
| ``-d3``                | DFT-D3 calculation (DFT with added dispersion)                                        |
+------------------------+---------------------------------------------------------------------------------------+
| ``-novdw``             | Disables the dispersion contribution.                                                 |
+------------------------+---------------------------------------------------------------------------------------+
| ``-cosmo <epsilon>``   | COSMO continuum solvation with a given dielectric constant ``<epsilon>``              |
+------------------------+---------------------------------------------------------------------------------------+
| *Basis Set and RI Approximation*                                                                               |
+------------------------+---------------------------------------------------------------------------------------+
| ``-bas <bname>``       | Use the ``<bname>`` basis set.                                                        |
+------------------------+---------------------------------------------------------------------------------------+
| ``-ri`` / ``-nori``    | | Use RI approximation (program ``ridft``, default) / use no RI approximation         |
|                        | | (program dscf).                                                                     |
+------------------------+---------------------------------------------------------------------------------------+
| *Symmetry, Optimization, Convergence*                                                                          |
+------------------------+---------------------------------------------------------------------------------------+
| ``-sym <pointgroup>``  | | Use ``<pointgroup>`` symmetry (if the symmetry is not found, it will be created     |
|                        | | by adding images of the input coordinates). Normally, ``cefine`` finds the symmetry |
|                        | | by itself and this is not needed.                                                   |
+------------------------+---------------------------------------------------------------------------------------+
| ``-noopt``             | | Special options for single point calculations. Does not call the definition of      |
|                        | | internal redundant coordinates (which can cause problems *e.g.* for linear          |
|                        | | molecules).                                                                         |
+------------------------+---------------------------------------------------------------------------------------+
| ``-abel``              | Reduce the symmetry used to an abelian symmetry (max. D\ :sub:`2h`)                   |
+------------------------+---------------------------------------------------------------------------------------+
| ``-opt``               | Used to set up an MP2-optimization.                                                   |
+------------------------+---------------------------------------------------------------------------------------+
| ``-ts``                | Sets up an transition state search.                                                   |
+------------------------+---------------------------------------------------------------------------------------+
| ``-scfconv <integer>`` | Sets SCF energy convergence criterion to :math:`10^{-{\tt <integer>}}`.               |
+------------------------+---------------------------------------------------------------------------------------+
| ``-grid <griddef>``    | Sets the DFT integration grid to ``<griddef>``.                                       |
+------------------------+---------------------------------------------------------------------------------------+
| *Electronic Information*                                                                                       |
+------------------------+---------------------------------------------------------------------------------------+
| ``-uhf <integer>``     | Open shell calculation with ``<integer>`` unpaired electrons.                         |
+------------------------+---------------------------------------------------------------------------------------+
| ``-chrg <integer>``    | Used to define the molecular charge as ``<integer>``.                                 |
+------------------------+---------------------------------------------------------------------------------------+


.. _Short ORCA Reference:

Short ORCA Reference
--------------------

You can find a rough summary of the most important ORCA keywords in the following table.
For a complete reference, consult the manual at https://orcaforum.kofo.mpg.de/.

+----------+------------------------------------------------------------+
| Keyword  | Explanation                                                |
+==========+============================================================+
| RHF      | Restricted  Hartree-Fock                                   |
+----------+------------------------------------------------------------+
| UHF      | Unrestricted Hartree-Fock                                  |
+----------+------------------------------------------------------------+
| TPSS     | DFT with the functional TPSS (can be any valid functional) |
+----------+------------------------------------------------------------+
| MP2      | Do an MP2 calculation.                                     |
+----------+------------------------------------------------------------+
| CCSD(T)  | Do a CCSD(T) calculation.                                  |
+----------+------------------------------------------------------------+
| TZVP     | Use a TZVP basis. Can be any valid basis set definition    |
+----------+------------------------------------------------------------+
| Opt      | Do a geometry optimization.                                |
+----------+------------------------------------------------------------+
| NumFreq  | | Calculate second derivatives (vibrational frequencies).  |
|          | | Also gives an IR spectrum and thermal corrections + ZPE. |
+----------+------------------------------------------------------------+
| TightSCF | Increases the convergence criterion for the SCF.           |
+----------+------------------------------------------------------------+
