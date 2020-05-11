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
      :linenos:

      ! RHF def2-TZVP TightSCF
      %paras R= 4.0,0.5,35 end

      * xyz 0 1
      H 0 0 0 
      F 0 0 {R}
      *

   Modifications for

   UHF:

   .. code-block:: none
      :linenos:

      ! UHF def2-TZVP TightSCF
      %scf BrokenSym 1,1 end

   MP2:

   .. code-block:: none
      :linenos:

      ! RHF MP2 def2-TZVP TightSCF 

   CCSD(T):

   .. code-block:: none
      :linenos:

      ! RHF CCSD(T) def2-TZVP TightSCF 

   CASSCF (2 active electrons in 2 orbitals):

   .. code-block:: none
      :linenos:

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
      :linenos:

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
      :linenos:

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
      :linenos:

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

Kinetic Isotope Effect
~~~~~~~~~~~~~~~~~~~~~~

.. admonition:: Exercise 3.1

   Calculate the kinetic isotope effect for the reaction
   CH\ :sub:`4` + HO\ |mult| |irarr| |mult|\ CH\ :sub:`3` + H\ :sub:`2`\ O. From transition
   state theory, it is known that

  .. math::

     \frac{k_\text{H}}{k_\text{D}} = e^{-\frac{\Delta H^{\neq}_\text{H}-\Delta H^{\neq}_\text{D}}{RT}}.

  .. figure:: img/ch4_oh.png
     :align: center
     :width: 200px

     Geometry of the transition state.

**Approach**

1. Calculate the geometry of the transition state for the hydrogen transfer.
   In order to do this, create a ``coord`` file with a starting geometry
   that is similar to the one in the picture, with
   :math:`R_{C-H} \approx` 1.2 |angst| and :math:`R_{O-H} \approx` 1.3 |angst|.

   In order to find the transition state, use the following steps:

   (a) Call ``cefine``:

       .. code-block:: none

          cefine -bas def2-TZVP -func b3-lyp -d3

   (b) Consecutively, calculate energy, gradient and hessian:

       .. code-block:: none

          ridft; rdgrad; aoforce

   (c) Verify that there is at least one, relatively large imaginary frequency
       in the output of ``aoforce``. Then, in the control file, change the first line
       after ``$statpt`` to:

       .. code-block:: none
          :linenos:

          itrvec 1
        
       (in general the frequency mode describing the motion of the reaction)
        
   (d) Start the transition state search:
   
       .. code-block:: none

          jobex -trans

2. When the search is successful (``GEO_OPT_CONVERGED`` in the directory),
   calculate the vibrational frequencies of the transition state (``aoforce``)
   and verify that there is only one imaginary frequency. You can have a look
   at that corresponding normal mode by calling:

   .. code-block:: none

      tm2molden; molden molden.input

   The normal modes can be visualized by clicking on "Norm. Mode" on the right side of the menu.
   
3. Call the program ``thermo`` and note down the thermal corrections to enthalpy.

4. In the ``control`` file, change the mass of the 4 hydrogen atoms at the carbon. Example:

   .. code-block:: none
      :linenos:

      h  2-5                             \
        basis =h def2-TZVP               \
        jbas  =h def2-TZVP               \
        mass = 2.014
      h  7                               \
        basis =h def2-TZVP               \
        jbas  =h def2-TZVP

   Be careful: The back slashes indicate that the statement is continued in the next line and
   are essential.

5. Repeat the transition state search with CD\ :sub:`4`.

6. Calculate the energies and thermal corrections for CH\ :sub:`4`, CD\ :sub:`4` and OH.

7. Finally, calculate :math:`k_\text{H}/k_\text{D}`.

..
  Measurements of the 13C and D kinetic isotope effects (KIE) in methane, 13CKIE
  = k(12CH4)/k(13CH4) and DKIE = k(12CH4)/k(12CH3D), in the reactions of these
  atmospherically important methane isotopomers with O(1D) and OH have been
  undertaken using mass spectrometry and tunable diode laser absorption
  spectroscopy to determine isotopic composition. For the carbon kinetic isotope
  effect in the reaction with the OH radical, 13CKIEOH = 1.0039 (±0.0004, 2σ) was
  determined at 296 K, which is significantly smaller than the presently accepted
  value of 1.0054 (±0.0009, 2 σ). For DKIEOH we found 1.294 (± 0.018, 2σ) at 296
  K, consistent with earlier observations. The carbon kinetic isotope effect in
  the reaction with O(1 D) 13CKIEO(1D), was determined to be 1.013, whereas the
  deuterium kinetic isotope effect is given by DKIEO(1D) = 1.06. Both values are
  approximately independent of temperature between 223 and 295 K. The room
  temperature fractionation effect 1000(KIE-1) in the reaction of O(1 D) with
  12CH4 versus CH4 is thus ≈ 13‰, which is an order of magnitude greater than the
  previous value of 1‰. In combination with recent results from our laboratory on
  13CKIE and DKIE for the reaction of CH4 with Cl, these new measurements were
  used to simulate the effective kinetic isotope effect for the stratosphere with
  a two-dimensional, time dependent chemical transport model. The model results
  show reasonable agreement with field observations of the 13CH4/12CH4 ratio in
  the lowermost stratosphere, and also reproduce the observed CH3D/CH4 ratio. 

Solvation
---------

S\ :sub:`N`\ 2-Reaction
~~~~~~~~~~~~~~~~~~~~~~~

.. admonition:: Exercise 4.1

   Calculate the potential energy curve for the S\ :sub:`N`\ 2-reaction of chloromethane
   with a flouride anion in the gas-phase and in methanol (|eps| = 32) between
   :math:`r(\text{C}-\text{F})` = 2.25 and 10.00 Bohr with |eps| being the dielectric constant of the solvent.

**Approach**

1. Calculate the energies of the reactants (one calculation for each reactant)
   in the gas-phase and at |eps| = 32. Use the hybrid functional PW6B95
   with a def2-TZVP basis and D3 dispersion correction. Example cefine call:

   .. code-block:: none

      cefine -bas def2-TZVP -func pw6b95 -chrg -1.0 -cosmo 32.0 -d3

2. To create the potential energy curves, use the shell script ``run-scan`` below.
   The script loops over all distances. For each distance it creates a new directory,
   calls ``cefine``, performs the constrained geometry optimization with ``jobex`` and writes
   the electronic energy (not necessarily your final reaction energy) from the
   ``energy`` file into a file called ``results.dat``.
   Copy the script and the file ``template`` into a new directory and
   create subdirectories (*e.g.* ``scan-vac`` and ``scan-cosmo``) for each potential
   energy curve. You will have to adapt the script to your directory names.

   .. code-block:: none
      :linenos:

      #!/bin/bash

      # Choose directory here
      cd scan_vac
      if [ -f ./results.dat ]
      then
        rm results.dat
      fi
       
      for dist in $(seq 2.25 0.25 10.00)
      do
    
        # Check for existence of folder
        if [ -d $dist ] 
        then
          rm -r $dist
        fi  
        mkdir $dist
        cd $dist
        echo $dist
        sed 's/XXXX/'$dist'/' ../../template > coord
    
        # Choose options for the calculation
        cefine -bas def2-TZVP -func pw6b95 -chrg -1.0 -d3
        jobex -c 50
      
        # Get final energy
        e=$(sdg energy | tail -1 | gawk '{printf $2}')
    
        # Write energy to a file
        echo $dist $e >> ../results.dat
        cd ../ 
      done

   Template for the ``coord`` file:

   .. code-block:: none
      :linenos:

      $coord
        0.00000000      0.00000000      0.00000000  c f
        0.00000000      0.00000000     -3.36989165  cl
        0.00000000      0.00000000      XXXX        f f
       -1.00404366      1.73905464     -0.62462166  h
       -1.00404366     -1.73905464     -0.62462166  h
        2.00808733      0.00000000     -0.62462166  h
      $end

   The ``f`` after the atom specification tells TURBOMOLE to keep the
   coordinates fixed for that atom.

3. Plot the two curves together (normalize the curves reasonably) and discuss the
   results. Estimate the activation barrier for both cases.

**Technical Hints**

- Sometimes ``cefine`` crashes can occur at very large distances. Often limiting the script to distances up to 8.25 Bohr might help solving the problem without loosing significant information.

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
