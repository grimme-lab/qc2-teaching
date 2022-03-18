.. include:: symbols.txt

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
   
   module use /software/modulefiles
   module load turbomole orca
   alias molden='/software/bin/molden'

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

To run a basic calculation with TURBOMOLE, you will only need the following two files:

- ``coord``: Molecular geometry in atomic units
- ``control``: All data required for the calculation (method, parameters, ... )

For more sophisticated calculation settings, TURBOMOLE provides an interactive input generator
called ``define`` which only needs the ``coord`` file to create the ``control`` file.
Basis set and orbital files, that are also necessary for the calculation, are created
during the calculation or by ``define``, respectively. These are:

- ``basis`` (and ``auxbasis``): Basis set (and auxiliary basis set for RI)
- ``mos`` or ``alpha`` and ``beta``: Orbitals (MO coefficients) for restricted and unrestricted treatment, respectively

In this course, all calculations can be prepared manually by only providing a ``coord``
and a ``control`` file containing all the necessary information.

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
| ``ricc2``            | Module for second-order correlated WF methods (MP2, CC2) |
+----------------------+----------------------------------------------------------+
| ``ccsdf12``          | Module for coupled cluster methods (CCSD, CCSD(T), ...)  |
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
| ``x2t``              | Convert a \*.xyz (in |angst|) file to coord (in bohr)    |
+----------------------+----------------------------------------------------------+
| ``t2x``              | Convert a coord (in bohr) file to \*.xyz (in |angst|)    |
+----------------------+----------------------------------------------------------+
| ``tm2molden``        | Generate a molden input                                  |
+----------------------+----------------------------------------------------------+

.. important:: Each TURBOMOLE calculation needs its own directory.


The ``control`` file
********************

While ``coord`` stores the molecular geometry, the ``control`` file contains all the
specifications and settings for the desired calculation. It contains keywords indicated
with a ``$`` symbol followed by some setting. Related specifications sometimes follow
in the next line and are indented. Every ``control`` file must end with the ``$end``
keyword in the last line. An example input for a simple DFT calculation on the
BLYP/def2-TZVP level of theory can look as follows:

.. code-block:: none
   :linenos:

   $coord file=coord
   $atoms
     basis = def2-TZVP
   $dft
     functional b-lyp
   $end

In the following exercises, some proper TURBOMOLE input will always be given (at
least partially) in the text. Additionally, you can find a short list of all
keywords needed in this course in the :ref:`Keywords in control` section below.


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
   *
   or:
   * xyzfile <charge> <multiplicity> <filename.xyz>

.. important:: Multiplicity = 2S+1 with S being the total spin.

A short reference of ORCA keywords can be found in the section :ref:`Short ORCA reference`.
Further information is accessible from: https://sites.google.com/site/orcainputlibrary/.


.. _Keywords in control:

Keywords in ``control``
-----------------------

The ``control`` file contains all specifications and settings for a calculation with
TURBOMOLE. Keywords start with ``$`` and sub-settings are indented. The last line of
the file must always be ``$end``.
The following table shows the most important keywords that are interesting for this course.

+--------------------------------------+------------------------------------------------------------------------------------------+
| Command                              | Functionality                                                                            |
+======================================+==========================================================================================+
| *essential for all calculations*                                                                                                |
+--------------------------------------+------------------------------------------------------------------------------------------+
| .. code-block:: none                 | Defines the ``coord`` file to be the one containing the molecular structure information. |
|                                      |                                                                                          |
|    $coord file=coord                 |                                                                                          |
+--------------------------------------+------------------------------------------------------------------------------------------+
| .. code-block:: none                 | Defines the basis set for the calculation to be ``<bas>``.                               |
|                                      |                                                                                          |
|    $atoms                            |                                                                                          |
|      basis=<bas>                     |                                                                                          |
+--------------------------------------+------------------------------------------------------------------------------------------+
| *always recommended*                                                                                                            |
+--------------------------------------+------------------------------------------------------------------------------------------+
| .. code-block:: none                 | Defines the charge ``<chrg>`` and the number of unpaired electrons ``<uhf>`` for the     |
|                                      | extended Hückel guess and the entire rest of the calculation.                            |
|    $eht charge=<chrg> unpaired=<uhf> |                                                                                          |
+--------------------------------------+------------------------------------------------------------------------------------------+
| .. code-block:: none                 | Use the symmetry of pointgroup ``<sym>``. If not stated otherwise, in the scope of this  |
|                                      | course it is always recommended to use C\ :sub:`1` symmetry to avoid technical issues    |
|    $symmetry <sym>                   | (choose ``c1``).                                                                         |
+--------------------------------------+------------------------------------------------------------------------------------------+
| .. code-block:: none                 | | Use the resolution of the identity (RI) approximation. Note that you then have to use  |
|                                      |   ``ridft`` for single-point calculations and the ``-ri`` option for ``jobex``.          |
|    $rij                              | | We recommend using the RI approximation for all exercises in this course.              |
+--------------------------------------+------------------------------------------------------------------------------------------+
| .. code-block:: none                 | For geometry optimizations: The energies and gradient of all optimization cycles will be |
|                                      | saved in the files ``energy`` and ``gradient``.                                          |
|    $energy file=energy               |                                                                                          |
|    $grad file=gradient               |                                                                                          |
+--------------------------------------+------------------------------------------------------------------------------------------+
| *DFT calculations*                                                                                                              |
+--------------------------------------+------------------------------------------------------------------------------------------+
| .. code-block:: none                 | | Perform a DFT calculation using the functional ``<func>``. Note that the BYLP, B3YLP   |
|                                      |   and B2PLYP functionals are named ``b-lyp``, ``b3-lyp`` and ``b2-plyp``, respectively.  |
|    $dft                              |   Define the integration grid ``<grid>`` (optional, the default is ``m4``).              |
|      functional <func>               | | For double-hybrid functionals, also include the settings for MP2 calculations          |
|      grid <grid>                     |   listed below (``$ricc2`` and ``$denconv`` blocks).                                     |
+--------------------------------------+------------------------------------------------------------------------------------------+
| .. code-block:: none                 | Use the D3 dispersion correction with Becke-Johnson damping.                             |
|                                      |                                                                                          |
|    $disp3 -bj                        |                                                                                          |
+--------------------------------------+------------------------------------------------------------------------------------------+
| .. note::                                                                                                                       |
|                                                                                                                                 |
|    If the ``$dft`` block is missing, a HF calculation will be performed.                                                        |
+--------------------------------------+------------------------------------------------------------------------------------------+
| *Post HF calculations*                                                                                                          |
+--------------------------------------+------------------------------------------------------------------------------------------+
| .. code-block:: none                 | For MP2 and CC calculations, a well-converged SCF run is needed. Therefore, set the      |
|                                      | convergence threshold of the SCF and the density matrix to :math:`10^{-7}` or less.      |
|    $scfconv 7                        |                                                                                          |
|    $denconv 1.0d-7                   |                                                                                          |
+--------------------------------------+------------------------------------------------------------------------------------------+
| .. code-block:: none                 | | Perform an MP2 single-point calculation.                                               |
|                                      | | The ``geoopt model=mp2`` keyword is only necessary if a geometry optimization on the   |
|    $ricc2                            |   MP2 level is desired.                                                                  |
|      mp2                             |                                                                                          |
|      geoopt model=mp2                |                                                                                          |
+--------------------------------------+------------------------------------------------------------------------------------------+
| .. code-block:: none                 | Perform a CCSD(T) single-point calculation.                                              |
|                                      |                                                                                          |
|    $ricc2                            |                                                                                          |
|      ccsd(t)                         |                                                                                          |
+--------------------------------------+------------------------------------------------------------------------------------------+
| *other settings*                                                                                                                |
+--------------------------------------+------------------------------------------------------------------------------------------+
| .. code-block:: none                 | Use the condctor like screening model COSMO with the dielectric constant ``<epsilon>``   |
|                                      | of the solvent.                                                                          |
|    $cosmo                            |                                                                                          |
|      epsilon=<epsilon>               |                                                                                          |
+--------------------------------------+------------------------------------------------------------------------------------------+
| .. code-block:: none                 | Defines the maximum number of iterations in an SCF calculation (default ``<limit>`` is   |
|                                      | 30). If an SCF did not converge, try increasing this value, *e.g.* to 100.               |
|    $scfiterlimit <limit>             |                                                                                          |
+--------------------------------------+------------------------------------------------------------------------------------------+
| .. code-block:: none                 | Specify the number of imaginary vibrational frequencies ``<imag>`` that shall be         |
|                                      | obtained by a geometry optimization (default is ``itrvec 0`` for minimum structures).    |
|    $statpt                           | Set to ``itrvec 1`` for transition state optimizations.                                  |
|      itrvec <imag>                   |                                                                                          |
+--------------------------------------+------------------------------------------------------------------------------------------+


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
| RI       | Use the resolution of the identity approximation.          |
+----------+------------------------------------------------------------+
| NumFreq  | | Calculate second derivatives (vibrational frequencies).  |
|          | | Also gives an IR spectrum and thermal corrections + ZPE. |
+----------+------------------------------------------------------------+
| NMR      | Calculate nuclear magnetic shielding tensors.              |
+----------+------------------------------------------------------------+
| TightSCF | Increases the convergence criterion for the SCF.           |
+----------+------------------------------------------------------------+
