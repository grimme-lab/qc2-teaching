.. include:: symbols.txt

Exercises
=========

.. contents::

Electron Correlation
--------------------

Multireference Methods
~~~~~~~~~~~~~~~~~~~~~~

.. admonition:: Exercise 1.1

  Electron correlation is very important in dissociation processes
  to get qualitatively and quantitatively correct results.
  Calculate the potential energy curves for the dissociation of
  HF with the singlereference methods RHF, UHF, MP2, CCSD(T) and CASSCF,           
  which is a multireference method. Compare the results.

**Approach**

1. In order to easily calculate potential energy curves, we use ORCA.
   Create the following inputs for the given methods and save them in different directories.
   (*e.g.* ``rhf.inp``, ``uhf.inp``, etc.).

   Input for RHF:

   .. code-block:: none

     ! RHF def2-TZVP TightSCF
     %paras R= 4.0,0.5,35 end

     * xyz 0 1
     H 0 0 0 
     F 0 0 {R}
     *

   Modifications for

   UHF:

   .. code-block:: none

     ! UHF def2-TZVP TightSCF
     %scf BrokenSym 1,1 end

   MP2:

   .. code-block:: none

     ! RHF MP2 def2-TZVP TightSCF 

   CCSD(T):

   .. code-block:: none

     ! RHF CCSD(T) def2-TZVP TightSCF 

   CASSCF (2 active electrons in 2 orbitals):

   .. code-block:: none

     ! RHF def2-TZVP TightSCF Conv
     %casscf nel 2
             norb 2
             switchstep nr
             end

   Calculate the potential energy curve by a CASSCF calculation with 6 electrons (``nel``) in 6 active orbitals (``norb``) as well.

2. Call ORCA with the command
   
   .. code-block:: none

     orca *.inp > *.out

3. Plot the resulting potential energy curves using ``xmgrace`` or ``gnuplot``. To do 
   this, delete the first line in the files ``<filename>.trj*.dat`` and
   read them directly with ``xmgrace`` (find out which file is the right one yourself):

   .. code-block:: none

     xmgrace trj*.dat

4. Calculate the energies for hydrogen and fluorine atoms for all given methods.
   Which methods will yield the identical energies for the hydrogen atom?

5. Plot the curves relative to the energies of the individual atoms and discuss your results
   (particularly the energies at large distances).

Carbenes
~~~~~~~~

All following calculations will be done with TURBOMOLE if not stated otherwise. Also, if not 
specified otherwise we will use the RI approximation throughout.

.. admonition:: Exercise 1.2

  Calculate the singlet-triplet splitting of methylene and *p*-benzyne with HF, MP2,
  DFT and CCSD(T).

**Approach**

1. Create the file ``coord`` with starting geometries for Methylene and *p*-Benzyne.
   
   The syntax is:

   .. code-block:: none

     $coord
     x y z atom1
     x y z atom2
     ...
     ...
     $end

   You can either create the files by hand or use the program ``molden``
   for this purpose. The program ``molden`` uses |angst| as unit, but the unit for the ``coord`` file
   has to be Bohr (atomic units). To convert a \*.xyz file into a coord file you can use the command

   .. code-block:: none

     x2t *.xyz > coord

   This also works the other way round:

   .. code-block:: none

     t2x coord > *.xyz

   .. How do I embed pdf files?
   .. image:: img/carbenes.pdf

2. **Methylene**: Optimize the geometries of the singlet and the triplet state
   with the given methods (HF, TPSS, B3LYP, PW6B95, MP2) and the basis set def2-TZVP.
   Note down the HCH-angle and total energies for each method, as well as the singlet-triplet
   splitting (:math:`\Delta E_{S-T} = E_{singlet} - E_{triplet}`). In the case of CCSD(T), do a singlepoint
   calculation on the MP2 geometries.
   The experimental value for the splitting is 9.0 kcal\ |mult|\ mol\ :sup:`-1`. The experimentally found angles are
   102.4° for the singlet and 135.5° for the triplet.

3. **p-Benzyne**: Repeat the same calculations for *p*-benzyne. The experimental value
   for the splitting is -4.2 kcal\ |mult|\ mol\ :sup:`-1`.

4. Discuss your findings and compare them to the experiment.

**Technical Hints**

- Command line option for a triplet state in cefine: ``-uhf 2`` (``uhf <number of unpaired electrons>``)
- To calculate without a dispersion correction add ``-novdw`` to your ``cefine`` call, which disables the default dispersion correction within the TURBOMOLE input.
- Method selection in cefine: ``-cc`` (CCSD(T)), ``-mp2`` (MP2), ``-hf`` (HF), ``-func b3-lyp/pw6b95/tpss``
  for B3-LYP, PW6B95 or TPSS.
- Geometry optimizations (DFT, HF) are done with the program ``jobex``.
- For MP2 geometry optimizations, set up your calculation with the additional ``cefine`` keyword ``-opt`` and run ``jobex -level cc2``.
- Energies after geometry optimizations can be found in the files ``job.last``. HF and DFT energies
  for each SCF-cycle are additionally written in the file ``energy``.
- For CCSD(T) (singlepoint calculation on MP2 geometries) run first ``ridft > ridft.out`` (for the HF-SCF),
  and then ``ccsdf12 > ccsdf12.out`` (for the correlated calculation).
  The energies can be found in ``ccsdf12.out``.
- In order to measure the angles, use either ``coordgl`` or ``molden``:

  .. code-block:: none

    tm2molden
    molden molden.input

  or with a small TURBOMOLE script called ``bend``:

  .. code-block:: none

    bend i j k

  with atom numbers ``i,j,k``.

Thermochemistry
---------------

under construction

Kinetics
--------

under construction

Solvation
---------

under construction

Actication Energies
-------------------

under construction

Noncovalent Interactions
------------------------

under construction

Spectroscopy
------------

under construction

Basis Set Convergence
---------------------

under construction
