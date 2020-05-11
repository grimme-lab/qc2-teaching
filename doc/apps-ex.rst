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

   .. image:: img/carbenes.png
      :align: center
      :height: 125px

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

Heat of Formation of C\ :sub:`60`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. admonition:: Exercise 2.1

  Calculate the heat of formation :math:`\Delta H_f^0` of the C\ :sub:`60` molecule
  by using different methods.

**Approach**

1. Optimize the geometry of C\ :sub:`60` on the TPSS-D3(BJ)/def2-SVP level in I\ :sub:`h`
   symmetry (D3(BJ) indicates the use of the D3 dispersion correction applying Becke-Johnson
   damping, in the following abbreviated with D3). In order to do so, use the ``coord`` file

   .. code-block:: none

     $coord
       -2.33   0.00    6.31      c
     $end

   with the following call of ``cefine``:

   .. code-block:: none

     cefine -bas def2-SVP -func tpss -sym ih -d3

   Defining the point group will automatically generate symmetry equivalent atoms (``-sym <point group>``, the point group is given with the corresponding Schoenflies symbol, *e.g.* ``c1``, ``c2v`` etc.).

2. Calculate the energy of C\ :sub:`60` on TPSS/def2-SVP level without D3 corrections, use the TPSS-D3/def2-SVP optimized geometry.

3. In order to get the thermal corrections, do a frequency calculation
   of C\ :sub:`60`. Use the program ``aoforce`` to calculate the vibrational frequencies first:

   .. code-block:: none

     aoforce > force.out

4. Then, calculate the thermal corrections to :math:`\Delta H_{298}` with the program
   ``thermo`` (pipe the output into a separate file, *e.g.* ``thermo > thermo.out``).
   ``thermo`` needs a ``.thermorc`` input file from your home directory. Create this
   file using the following content:

   .. code-block:: none

     0.0  298.15  1.0

   The first number is an internal threshold, the second the temperature in Kelvin and the third
   the scaling factor for the vibrational frequencies (1.0 for TPSS).

5. Now, calculate the energy of a single carbon atom on the TPSS/def2-SVP
   level of theory and the thermal corrections to :math:`\Delta H_{298}` (use C\ :sub:`1` symmetry).

6. Calculate :math:`\Delta H_f^0` of C\ :sub:`60` and compare to experimental
   results (599 / 635 kcal/mol). You will need the experimental :math:`\Delta H_f^0`
   of a carbon atom: 170.89 kcal/mol.

7. Calculate singlepoint energies (without dispersion correction) for carbon and C\ :sub:`60` with TPSS and HF
   employing the def2-TZVP and the def2-QZVP basis sets.
   Use the results to calculate the heat of formation. (Use the TPSS-D3/def2-SVP geometries
   and corrections to :math:`\Delta H_{298}` for this purpose.

   .. To do so add ``-novdw`` to your ``cefine`` call, which disables the dispersion correction within the TURBOMOLE input.
   .. (If you run into convergence problems setting the option ``scfconv 8`` in the control file and increasing the number of allowed scf iterations slightly ``scfiter 200`` may help.)

8. Calculate the D3 dispersion correction to the TPSS/def2-QZVP energy and calculate
   :math:`\Delta H_f^0` again. Use the standalone program ``dftd3``:

   .. code-block:: none

     dftd3 coord -func tpss -bj

9. Discuss your results.

Reaction Enthalpies of Gas-Phase Reactions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. admonition:: Exercise 2.2

  For small molecules, highly accurate thermochemical results are
  reachable in quantum chemistry. This means *chemical accuracy*
  with an error of less than 1 kcal/mol. Calculate the reaction enthalpies
  at 298 K for the following, industrially important reactions:

  .. How can I center the following two lines of text?

  .. line-block::
  
    CH\ :sub:`4` + H\ :sub:`2`\ O |eqarr| CO + 3 H\ :sub:`2` (steam reforming of methane)
    N\ :sub:`2` + 3 H\ :sub:`2` |eqarr| 2 NH\ :sub:`3` (Haber-Bosch process)

  The experimental data are:

  +-----------------+--------------------------------------------------------------------+
  | Reaction        | :math:`\Delta H_{r}(298\,\text{K})` / kcal\ |mult|\ mol\ :sup:`-1` |
  +=================+====================================================================+
  | Steam reforming | +49.3                                                              |
  +-----------------+--------------------------------------------------------------------+
  | Haber-Bosch     | -22.5                                                              |
  +-----------------+--------------------------------------------------------------------+

**Approach**

1. Optimize the reactants and products using TPSS-D3/def2-TZVP (to activate the D3 dispersion correction for **DFT** geometry optimizations and energy calculations use the ``-d3`` keyword in cefine).
  
2. Calculate the frequencies (using ``aoforce > force.out``) and thermal corrections from energy to enthalpy at 298 K (``thermo > thermo.out``).

3. Repeat the optimization for the molecules involved in the Haber-Bosch process with MP2/def2-TZVP. Calculate the deviation of these differently
   optimized structures by computing the root mean square deviation of the coordinates:

   .. code-block:: none

     rmsd <tpss-geometry> <mp2-geometry>

4. Calculate singlepoint energies with the hybrid functional B3-LYP-D3/def2-TZVP and with MP2/def2-TZVP.
   Use the TPSS-D3 geometries and thermal corrections to calculate the reaction enthalpies.

5. Calculate singlepoint energies with the double hybrid B2-PLYP-D3/def2-QZVP
   and with CCSD(T)/def2-QZVP. Use the TPSS geometries and thermal corrections to
   calculate the reaction enthalpies.

6. Tabulate your results and compare to the experimental values.

**Technical Hints**

- In order to do a double hybrid calculation, you will need to run ``ridft`` first
  and then ``ricc2`` subsequently. The energy can be found in the output of ``ricc2``.

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
