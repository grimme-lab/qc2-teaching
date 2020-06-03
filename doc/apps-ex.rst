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
   HF with the single-reference methods RHF, UHF, MP2, CCSD(T) and CASSCF,
   which is a multi-reference method. Compare the results.

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

      orca <file>.inp > <file>.out

3. Plot the resulting potential energy curves using *e.g.* with ``gnuplot`` (see section
   :ref:`Plotting`). To do so, delete the first line in the files ``<filename>.trj*.dat``
   to read them (find out which file is the right one yourself).

4. Calculate the energies for hydrogen and fluorine atoms for all given methods.
   Which methods will yield the identical energies for the hydrogen atom?

5. Plot the curves relative to the energies of the individual atoms and discuss your results
   (particularly the energies at large distances).

.. hint::
   Have a closer look at the UHF dissociation curve. Does it look as you would expect it? Try to explain the "strange" behavior in terms of symmetry breaking.


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

   You can either create the files by hand or use the program ``Avogadro`` for this purpose
   (see section :ref:`Software for visualization of molecules`). ``Avogadro`` uses
   |angst| as unit, but the unit for the ``coord`` file has to be Bohr (atomic units). To
   convert a \*.xyz file into a coord file you can use the command

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
   The following command line is an example and calls ``cefine`` with the correct
   options for a B3LYP/def2-TZVP calculation of the triplet (= 2 unpaired electrons) state.

   .. code-block:: none

      cefine -bas def2-TZVP -func b3-lyp -uhf 2 -novdw

   | To generate the input for the other calculations, please look at the table provided in section :ref:`Short cefine reference`. Add the ``-opt`` option for setting up the ``-mp2`` calculation.
   | Geometry optimizations (DFT, HF) are done with the program ``jobex``:

   .. code-block:: none

      jobex > jobex.out

   Note that for MP2 geometry optimizations, you have to add the ``-level cc`` option.
   Energies after geometry optimizations can be found in the file ``job.last``. HF and DFT
   energies for each SCF-cycle are additionally written in the file ``energy``.
   In the case of CCSD(T), do not perform a geometry optimization, but do a singlepoint
   calculation on the MP2 optimized geometries. Before performing the actual CCSD(T)
   calculation, you have do run a HF-SCF:

   .. code-block:: none

      ridft > ridft.out
      ccsdf12 > ccsdf12.out

   The energies can then be found in ``ccsdf12.out``.

3. In order to measure the angles of the optimized structures, you can use ``Avogadro``
   or a small TURBOMOLE script called ``bend``:

     .. code-block:: none

        bend i j k

   | with atom numbers ``i``, ``j``, ``k``.
   | Note down the HCH-angle and total energies for each method, as well as the singlet-triplet splitting (:math:`\Delta E_\text{S-T} = E_\text{singlet} - E_\text{triplet}`). The experimental value for the splitting is 9.0 kcal\ |mult|\ mol\ :sup:`-1`. The experimentally found angles are 102.4° for the singlet and 135.5° for the triplet.

4. **p-Benzyne**: Repeat the same calculations for *p*-benzyne. The experimental value
   for the splitting is -4.2 kcal\ |mult|\ mol\ :sup:`-1`.

5. Discuss your findings and compare them to the experiment.

.. hint::

   Method selection in cefine: ``-func b3-lyp/pw6b95/tpss`` (B3LYP/PW6B95/TPSS), ``-hf`` (HF),
   ``-mp2`` (MP2), ``-cc`` (CCSD(T)).


Basis Set Convergence
---------------------

Formic Acid Dimer
~~~~~~~~~~~~~~~~~

.. admonition:: Exercise 2.1

   Investigate the basis set convergence behavior of different methods
   for the formic acid dimer.

**Approach**

1. Create separate directories for the formic acid dimer and monomer and set up geometry
   optimizations on the TPSS-D3/def2-TZVP level of theory. To do so, create structures
   using *e.g.* ``Avogadro`` and convert them to ``coord`` files. Prepare the calculations
   and start the optimizations the same way as in exercise 1.2. Keep in mind the ``-d3``
   option for **DFT** geometry optimizations and energy calculations:

   .. code-block:: none

      cefine -bas def2-TZVP -func tpss -d3
      jobex > jobex.out

2. Calculate the dimerization energy (energy difference of one dimer and two monomers)
   with HF, TPSS-D3 and MP2 employing the cc-pVXZ (X = D, T, Q) basis sets and their
   augmented counterparts (aug-cc-pVXZ). Refer to the table of ``cefine`` options given
   in section :ref:`Short cefine reference`.

3. Tabulate your results and plot the total energies versus the cardinal number
   of the basis set for each method (*e.g.* with ``gnuplot``).

4. Discuss your findings with respect to the basis set superposition error (BSSE) and
   the basis set incompleteness (BSIE). Which methods can be considered as converged
   towards the basis set limit when used with a quadruple-|zeta| basis?

.. hint::

   - The calculations with quadruple-|zeta| basis can be quite time consuming. Be sure
     to use the correct symmetry.

   - Remember that you get HF results for free when doing MP2.


Thermochemistry
---------------

Reaction Enthalpies of Gas-Phase Reactions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. admonition:: Exercise 3.1

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

1. Optimize the reactants and products using TPSS-D3/def2-TZVP (see earlier exercises
   and section :ref:`Short cefine reference`, keep in mind the ``-d3`` option).

2. In order to get the thermal corrections from energy to enthalpy at 298.15 K, do a
   frequency calculation first. Use the program ``aoforce`` to calculate the vibrational
   frequencies in TURBOMOLE:

   .. code-block:: none

      aoforce > aoforce.out

3. Then, calculate the thermal corrections to :math:`\Delta H_{298.15}` with the program
   ``thermo``. It needs a ``.thermorc`` input file from your home directory. Create this
   file by typing:

   .. code-block:: none

      echo "0.0  298.15  1.0" > ~/.thermorc

   The first number is an internal threshold, the second the temperature in Kelvin and
   the third the scaling factor for the vibrational frequencies (1.0 for TPSS). Pipe the
   output into a separate file, *e.g.*:

   .. code-block:: none

      thermo > thermo.out

4. Repeat the optimization for the molecules involved in the Haber-Bosch process with
   MP2/def2-TZVP. Calculate the deviation of these differently optimized structures by
   computing the root mean square deviation of the coordinates:

   .. code-block:: none

      rmsd <tpss-geometry> <mp2-geometry>

5. Calculate singlepoint energies with the hybrid functional B3LYP-D3/def2-TZVP and with
   MP2/def2-TZVP. Use the TPSS-D3 geometries and thermal corrections to calculate the
   reaction enthalpies.

6. Calculate singlepoint energies with the double hybrid B2PLYP-D3/def2-QZVP and with
   CCSD(T)/def2-QZVP. Use the TPSS geometries and thermal corrections to calculate the
   reaction enthalpies. Keep in mind that you have to run an SCF first with ``ridft``.
   Afterwards, use ``ricc2`` for the double-hybrid and ``ccsdf12`` for the coupled cluster
   calculation. The energies can be found in the respective output.

7. Tabulate your results and compare to the experimental values.


Heat of Formation of C\ :sub:`60` (optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. admonition:: Exercise 3.2

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

   Defining the point group will automatically generate symmetry equivalent atoms (the point
   group is given with the corresponding Schoenflies symbol, *e.g.* ``c1``, ``c2v`` etc.).

2. Calculate the energy of C\ :sub:`60` on TPSS/def2-SVP level without D3 corrections, use the
   TPSS-D3/def2-SVP optimized geometry.

3. Calculate the frequencies of C\ :sub:`60` and the thermal corrections the same way as in
   exercise 3.1.

4. Now, calculate the energy of a single carbon atom on the TPSS/def2-SVP
   level of theory and the thermal corrections to :math:`\Delta H_{298.15}` (use C\ :sub:`1` symmetry).

5. Calculate :math:`\Delta H_f^0` of C\ :sub:`60` and compare to experimental
   results (599 / 635 kcal/mol). You will need the experimental :math:`\Delta H_f^0`
   of a carbon atom: 170.89 kcal/mol.

6. Calculate singlepoint energies (without dispersion correction) for carbon and C\ :sub:`60` with TPSS and HF
   employing the def2-TZVP and the def2-QZVP basis sets.
   Use the results to calculate the heat of formation. (Use the TPSS-D3/def2-SVP geometries
   and corrections to :math:`\Delta H_{298.15}` for this purpose.

   .. To do so add ``-novdw`` to your ``cefine`` call, which disables the dispersion correction within the TURBOMOLE input.
   .. (If you run into convergence problems setting the option ``scfconv 8`` in the control file and increasing the number of allowed scf iterations slightly ``scfiter 200`` may help.)

7. Calculate the D3 dispersion correction to the TPSS/def2-QZVP energy and calculate
   :math:`\Delta H_f^0` again. Use the standalone program ``dftd3``:

   .. code-block:: none

      dftd3 coord -func tpss -bj

8. Discuss your results.


Kinetics
--------

Kinetic Isotope Effect
~~~~~~~~~~~~~~~~~~~~~~

.. admonition:: Exercise 4.1

   Calculate the kinetic isotope effect for the reaction
   CH\ :sub:`4` + HO\ |mult| |irarr| |mult|\ CH\ :sub:`3` + H\ :sub:`2`\ O. From transition
   state theory, it is known that

  .. math::

     \frac{k_\text{H}}{k_\text{D}} = e^{-\frac{\Delta H^{\neq}_\text{H}-\Delta H^{\neq}_\text{D}}{RT}}.

.. figure:: img/ch4_oh.png
   :align: center
   :width: 250px

   Geometry of the transition state.

**Approach**

1. Calculate the geometry of the transition state for the hydrogen transfer.
   In order to do this, create a ``coord`` file with a starting geometry
   that is similar to the one in the picture, with
   :math:`R_{C-H} \approx` 1.2 |angst| and :math:`R_{O-H} \approx` 1.3 |angst|.

   In order to find the transition state, use the following steps:

   (a) Prepare the calculation with ``cefine``. Use the B3LYP-D3/def2-TZVP level
       of theory. Look at section :ref:`Short cefine reference` if you are unsure.

   (b) Consecutively, calculate energy, gradient and hessian:

       .. code-block:: none

          ridft > ridft.out
          rdgrad > rdgrad.out
          aoforce > aoforce.out

   (c) Verify that there is at least one, relatively large imaginary frequency
       in the output of ``aoforce`` (it also appears in the ``vibspectrum`` file).
       Then, in the ``control`` file, change the first line after ``$statpt`` to:

       .. code-block:: none
          :linenos:

          itrvec 1

       (in general the frequency mode describing the motion of the reaction)

   (d) Start the transition state search:

       .. code-block:: none

          jobex -trans > jobex.out

2. When the search is successful (a ``GEO_OPT_CONVERGED`` file has been created
   in the directory), calculate the vibrational frequencies of the transition
   state (``aoforce``) and verify that there is only one imaginary frequency.
   You can have a look at that corresponding normal mode by calling:

   .. code-block:: none

      tm2molden

   Choose your desired options in the short interactive experience. You do not need
   to pick a name for the input file or to save the MO data, the latter will make
   the file rather large (but obviously save the frequency data). You can open the
   resulting file (default: ``molden.input``) with ``gmolden``. The normal modes can
   be visualized by clicking on "Norm. Mode" on the right side of the menu.

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

.. admonition:: Exercise 5.1

   Calculate the potential energy curve for the S\ :sub:`N`\ 2-reaction of chloromethane
   with a flouride anion in the gas-phase and in methanol (|eps| = 32) between
   :math:`r(\text{C}-\text{F})` = 2.25 and 10.00 Bohr with |eps| being the dielectric constant of the solvent.

**Approach**

1. Create structures and calculate the energies of the reactants (one calculation
   for each reactant) in the gas-phase and at |eps| = 32 (methanol). Use the hybrid
   functional PW6B95 with a def2-TZVP basis and D3 dispersion correction. Example
   for the preparation:

   .. code-block:: none

      cefine -bas def2-TZVP -func pw6b95 -chrg -1.0 -cosmo 32.0 -d3

2. To create the potential energy curves, use the shell script below. The script
   loops over all distances. For each distance it creates a new directory, calls
   ``cefine``, performs the constrained geometry optimization and writes the electronic
   energy (not necessarily your final reaction energy) into a file called ``results.dat``.
   Create a new directory and copy and paste the script to a file named ``run-scan.sh``.

   .. code-block:: bash
      :linenos:

      #!/usr/bin/env bash

      # Choose directory here
      calc_dir=scan_vac
      # Choose options for the calculation
      options="-bas def2-TZVP -func pw6b95 -chrg -1.0 -d3"

      cd $calc_dir
      if [ -f ./results.dat ]
      then
        rm results.dat
      fi

      read -r -d 'END' template <<-EOF
      \$coord
        0.00000000      0.00000000      0.00000000  c f
        0.00000000      0.00000000     -3.36989165  cl
        0.00000000      0.00000000      DIST        f f
       -1.00404366      1.73905464     -0.62462166  h
       -1.00404366     -1.73905464     -0.62462166  h
        2.00808733      0.00000000     -0.62462166  h
      \$end
      END
      EOF


      for dist in $(seq 2.25 0.25 10.00 | sed s/,/./)
      do

        # Check for existence of folder
        if [ -d $dist ]
        then
          rm -r $dist
        fi
        mkdir $dist
        pushd $dist
        echo "$template" | sed "s/DIST/$dist/" > coord

        cefine $options
        jobex -c 50

        # Get final energy
        e=$(sdg energy | tail -1 | gawk '{printf $2}')

        # Write energy to a file
        echo $dist $e >> ../results.dat
        popd
      done

   Template for the ``coord`` file is given directly inline in the script, we will repeat it here to explain a few details.
   The ``f`` after the atom specification tells TURBOMOLE to keep the coordinates fixed for that atom:

   .. code-block:: none
      :linenos:

      $coord
        0.00000000      0.00000000      0.00000000  c f
        0.00000000      0.00000000     -3.36989165  cl
        0.00000000      0.00000000      DIST        f f
       -1.00404366      1.73905464     -0.62462166  h
       -1.00404366     -1.73905464     -0.62462166  h
        2.00808733      0.00000000     -0.62462166  h
      $end

   In order to use the script, you have to make it executable by typing:

   .. code-block:: none

      chmod +x run-scan.sh

   Create subdirectories (*e.g.* ``scan-vac`` and ``scan-cosmo``) for each potential
   energy curve. You will have to adapt the script to your directory names.
   Execute the script by typing:

   .. code-block:: none

      ./run-scan.sh

3. Plot the two curves together (normalize the curves reasonably) and discuss the
   results. Estimate the activation barrier for both cases.

.. hint::

   Sometimes ``cefine`` crashes can occur at very large distances. Often limiting the script to
   distances up to 8.25 Bohr might help solving the problem without loosing significant information.


Activation Energies
-------------------

Rearrangement and Dimerization Reactions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. admonition:: Exercise 6.1

   Estimate the activation energy for the Claisen rearrangement of allyl-vinyl ether
   and the dimerization of cyclopentadiene (Diels-Alder).

.. Ggf. besser Strukturen hinterlegen, Änderungen auf GFN-xTB?
.. (You can ask the lab assistent for a dimer structure of cyclopentadien.)

**Approach**

1. Construct the geometry of reactant and product for each reaction (*e.g.* using ``Avogadro``).

2. Optimize the geometries using PBEh-3c and C\ :sub:`1` symmetry. Prepare the calculation using:

   .. code-block:: none

      cefine -sym c1

3. Ensure that the sequence of atoms is the same in every pair of reactant and
   product structure.

4. Prepare a reaction path search:

   (a) Create a directory for each reaction.
   (b) Have your reactant and product structure sorted and available in TURBOMOLE
       format (*e.g.* starting structure ``coord``, ending structure ``coord.2``).
   (c) Set up a calculation for the starting strucutre. Employ PBEh-3c as before.
   (d) Merge reactant and product structures files into a file called ``coords``
       *e.g.* by typing:

       .. code-block:: none

          cat coord coord.2 >> coords

       Afterwards, call:

       .. code-block:: none

          woelfling

   (e) Check your initial path. It is available in the ``path.xyz`` file.
   (f) If everything was okay, check the ``control`` file. On the bottom, a block
       appeared that starts with ``$woelfling``.
   (g) Three of the parameters listed there are of importance. ``ninter`` controls
       the number of points on the path, ``maxit`` controls the number of refinement
       iterations and ``thr`` controls the convergence of the path. Modify them to the
       following values:

       .. code-block:: none

          ninter     40
          maxit      40
          thr        5.0E-04

   (h) Start the optimization by typing

       .. code-block:: none

          woelfling-job_xtb > woelfling.out

       Every optimization iteration is saved in a ``path-<n>.xyz`` file. Be aware that
       you are using a modified ``woelfling-job`` file that calculates energies and
       gradients with the semi-empirical tight-binding based GFN-xTB method even if you
       used PBEh-3c to set up your input files. This is a common method to speed up your
       reaction path investigations.

5. Calculate the activation energy for each reaction.

6. How would you proceed further to gain more reliable numbers?

7. How feasible is this approach? Where do you see its limits in applicability and usefulness?

8. Prepare relative energy diagrams for both reactions (relative energy vs. reaction coordinate), depict the molecular
   structures of both transition states and highlight the most important bond distances.

.. hint::

   Preparing good input structures for transition state searches is absolutely essential, often you can easily
   create a product structure from your reactant. Furthermore, this generally eases the sorting of the atoms.


Noncovalent Interactions
------------------------

Noble Gas |mult| |mult| |mult| Methane
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. admonition:: Exercise 7.1

   Calculate potential energy curves of the "weak" interactions between the noble gases Ar or Kr and methane.

.. figure:: img/ng_ch4.png
   :align: center
   :width: 250px

   Geometry of the CH\ :sub:`4` |mult| |mult| |mult| Ar complex.

**Approach**

1. Calculate the potential energy curve at the BLYP-D3/def2-QZVP
   level for Ar |mult| |mult| |mult| HCH\ :sub:`3` by performing a geometry
   optimization with a fixed Ar and H atom.
   Do this for :math:`R_\text{(Ar-H)}` = 4.5 - 15.0 Bohr with a stepsize of 0.25 Bohr.
   Use the following ``template`` file to create the ``coord`` files:

   .. code-block:: none
      :linenos:

      $coord
          0.00000000000000      0.00000000000000      XXXX                  ar f
          0.00000000000000      0.00000000000000      0.00000000000000      h f
          0.00000000000000      0.00000000000000     -2.06945348098289      c
          0.97576020317533      1.69006623336522     -2.75977586481614      h
          0.97576020317533     -1.69006623336522     -2.75977586481614      h
         -1.95152040635065      0.00000000000000     -2.75977586481614      h
      $end

   Use the ``run-scan.sh`` script from exercise 5.1 and adopt it to this task. You also
   have to modify the directory names. Prepare the BLYP-D3/def2-QZVP calculations with
   the following options:

   .. code-block:: none
      :linenos:

      cefine -bas def2-QZVP -func b-lyp -d3 -sym c1

2. Repeat the calculations for BLYP/def2-QZVP and MP2/def2-QZVP. For BLYP, exchange ``-d3``
   by ``-novdw`` and for MP2, use the following calls in the script:

   .. code-block:: none
      :linenos:

      cefine -mp2 -bas def2-QZVP -opt -sym c1
      jobex -level cc2 -c 50

   To get the final MP2 energy for each distance use the following command:

   .. code-block:: none
      :linenos:

      grep "Total Energy" job.last | gawk '{print $4}'

3. Repeat the calculations for Kr |mult| |mult| |mult| HCH\ :sub:`3`
   (substitute Ar with Kr in the ``template`` file) with
   BLYP-D3/def2-QZVP, BLYP/def2-QZVP and MP2/def2-QZVP.

4. Plot the curves (**normalize to the dissociation limit**) and discuss your findings.


Spectroscopy
------------

IR-Spectrum of 1,4-Benzoquinone
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. admonition:: Exercise 8.1

   Calculate the IR-spectrum of 1,4-Benzoquinone using
   DFT and HF, and compare the results to the experimental
   spectrum given below.

**Approach**

1. Create a ``coord`` file for 1,4-Benzoquinone.

2. Optimize the geometry with TURBOMOLE on the HF-D3/def2-SVP level of theory.

3. Calculate the normal modes with ``aoforce``.

4. Call ``tm2molden`` and check the normal modes with ``gmolden`` the same way as
   in exercise 4.1.

5. Assign each dipole-allowed normal mode to an experimental one
   and calculate the scaling factor :math:`f_\text{scal}=\nu_\text{exp}/\nu_\text{calc}`.

6. Repeat everything with TPSS-D3/def2-SVP and discuss your findings.

.. figure:: img/benzoquinone.png
   :align: center
   :width: 800px

   IR spectrum of 1,4-Benzoquinone in KBr.

.. hint::

   If you obtain imaginary frequencies, try to start the geometry optimization from a slightly distorted structure.
   Check if the imaginary frequencies vanish.


The Color of Indigo
~~~~~~~~~~~~~~~~~~~

.. admonition:: Exercise 8.2

   Calculate the color of indigo with three different methods:
   time-dependent Hartree-Fock (TD-HF) and
   time-dependent DFT (TD-DFT) with two different functionals (PBE and PBE0).

**Approach**

1. Create the geometry of indigo (figure below) and optimize it with TURBOMOLE on the
   TPSS-D3/def2-SVP level. Make sure to use the correct symmetry.

   .. figure:: img/indigo.png
      :align: center
      :width: 250px

      Structure of indigo.

2. Do a HF-D3/def2-SVP singlepoint calculation. Use the ``-nori`` option for the preparation
   with ``cefine`` and run:

   .. code-block:: none

      dscf > dscf.out

   In order to do the TD-HF calculation, edit the ``control`` file and add the following lines
   (before ``$end``):

   .. code-block:: none
      :linenos:

      $scfinstab rpas
      $soes
        bu 1

   Then, run:

   .. code-block:: none

      escf > escf.out

3. For the TD-DFT calculations repeat the above procedure with PBE-D3/def2-SVP and
   PBE0-D3/def2-SVP. Use the proper ``cefine`` calls and run

   .. code-block:: none

      ridft > ridft.out
      escf > escf.out

4. Discuss the excitation energies for all three methods; which method
   would predict (at least approximately) the correct color for indigo?
   How do you explain the errors?


NMR Parameters
~~~~~~~~~~~~~~

The computation of NMR parameters can be done with the ORCA program package. A simple input for
the calculation of the NMR chemical shielding of CH\ :sub:`3`\ NH\ :sub:`2` with the PBE
functional and a pcSseg-2 basis set is presented below. The pcSseg-*n* basis sets are special
segmented contracted basis sets otimized for the calculation of NMR shieldings.
(For more information see: Jensen, F., *J. Chem. Theory Comput.* **2015**, *11*, 132 - 138.)

.. code-block:: none
   :linenos:

   !PBE RI pcSseg-2 def2/J NMR

   *xyzfile 0 1 input.xyz

At the end of the ORCA output, a summary of the calculated NMR absolute chemical shieldings can be found.

Exemplary output for CH\ :sub:`3`\ NH\ :sub:`2`:

.. code-block:: none
   :linenos:

   --------------------------
   CHEMICAL SHIELDING SUMMARY (ppm)
   --------------------------


     Nucleus  Element    Isotropic     Anisotropy
     -------  -------  ------------   ------------
         0       C          152.992         46.821
         1       H           29.025          8.165
         2       H           28.567         10.286
         3       N          242.339         43.497
         4       H           29.033          8.176
         5       H           31.095         13.580
         6       H           31.120         13.593

.. admonition:: Exercise 8.3

   Calculate the :sup:`13`\ C-NMR chemical shifts |delta| for a number of organic compounds
   and compare the results to experimental data. In addition,
   investigate the correlation of the |pi|-electron density with |delta|.

.. figure:: img/nmr2018.png
   :align: center
   :width: 500px

   Lewis structures of seven organic compounds **A** -- **G** with their experimentally obtained chemical shift as well as four aromatic compounds **Ar-1** - **Ar-4**.

**Approach**

1. Optimize the geometries of the compounds **A** -- **G** and the reference molecule Si(CH\ :sub:`3`)\ :sub:`4` (TMS)
   on the PBEh-3c level of theory (how to use PBEh-3c is explained in the ORCA manual).

2. Calculate the :sup:`13`\ C-NMR chemical shieldings and shifts |delta| for compounds **A** -- **G** with TMS as reference at PBE/pcSseg-2 level of theory.
   Given the NMR shielding constants :math:`\sigma` of the compound (:math:`\text{c}`) and the reference (:math:`\text{ref.}`), the chemical shift
   :math:`\delta _\text{c,ref.}` is defined as

   .. math::

      \delta _\text{c,ref.} = \sigma _\text{ref.} - \sigma _c .

   .. hint::

      Computational time can be saved by calculating the shieldings only for carbon atoms instead of all atoms.
      How to do so is described in the ORCA manual.

3. Compare your results with the experimental values and calculate the mean deviation (MD) and the mean absolute deviation (MAD).

   .. math::

      \text{MD} = \frac{1}{N} \sum_{i=1}^N (\delta _\text{calc.} - \delta _\text{exp.}) \hspace{1.5cm} \text{MAD} = \frac{1}{N} \sum_{i=1}^N (|\delta _\text{calc.} - \delta _\text{exp.}|)

4. Repeat the calculations for the four aromatic compounds **Ar-1** -- **Ar-4**
   and plot the calculated chemical shift against the formal |pi|-electron
   density (:math:`\rho_\pi = n_{el^\pi}/n_{at^\pi}`). Discuss your results.

5. The experimental :sup:`17`\ O- and :sup:`13`\ C-NMR chemical shifts of the carbonyl function in acetone are shifted by
   75.5 and -18.9 ppm, respectively, if an acetone molecule is transferred from the gas phase to aqueous solution.
   Try to reproduce these values by considering solvation effects by the implicit solvent model CPCM. You can switch on
   the implicit solvent by adding the ``CPCM(<solvent>)`` keyword (example: ``CPCM(toluene)``) to your ORCA input.
   For carbon, the reference is TMS, for oxygen it is water.

6. Try to estimate which effect is larger -- the inclusion of an implicit solvation in the NMR calculation or the
   inclusion of the implicit solvent in the geometry optimization.

   .. hint::

      There are two options (gas/solution) for each calculation, the geometry optimization and the shielding calculation. Compare all possibilities.

7. Calculate the :sup:`1`\ H-NMR chemical shifts for **H** and **I** in the gas-phase at PBE/pcSseg-2 level of theory.
   Discuss your observations regarding the chemical shift of the methine proton in both compounds.
   Give a short explanation of your findings.

   .. figure:: img/nmr2018_2.png
      :align: center
      :width: 500px

      Lewis structures of *in*- (**H**) and *out*- (**I**) [3\ :sup:`4,10`][7]Metacyclophane.

   .. hint::

      The NMR chemical shielding calculations for **H** and **I** may be time consuming, consider to run them over night.

