Recommendations
===============

General Recommendations
-----------------------

Working with this script
~~~~~~~~~~~~~~~~~~~~~~~~

1. Work on the exercises in the given successive order. In the first exercises you will learn some basic
   routines and procedures which you will need again later but which will not be explained once more.
        
2. Read the whole exercise before you start to working on it. Often technical hints are given at the end.
  
3. Programs can crash. So check your outputs as soon as possible to make sure your calculations actually did work.
   And sometimes preparing the input and running the program is much faster than finding the right number
   in the output. 
        
4. Prepare an LibreOffice sheet (or similar) with a collection of your results. Checking them this way is much easier for us.
        
Trouble shooting
~~~~~~~~~~~~~~~~

Many programs may cause many problems, therefore you should follow some simple guidelines to identify their origins:

- "Crap in, crap out": Always check your input (input structures, file formats, input file, chosen keywords etc.) before you start a calculation.
- If a calculation stops abnormally check the output (*e.g.* orca.out, job.last etc.) and error files first. Always make sure that you pipe all needed output data into files if its not done by default.
- Read your output and error files carefully. Especially check the last lines of the output file for error messages that give a hint what may caused the problem.
- If you identified the problem (maybe you have to start at the first point again), check the program manual for additional options or trouble shooting help, fix the problem and restart your calculation.
- If the calculations still stops abnormally and all other possibilities and options are exhausted, prepare a detailed description of the problem, the output/error messages and contact one of the tutors.

.. _Short cefine reference:

Software Recommendations
------------------------

X-Server or How to make your graphical connection work (optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sometimes it is easier to directly have a look at strucutres or plots, instead of copying everything to your local computer. Therefore, we recommend an application that enables you to open graphical interfaces on the CIP Pool computers in the Mulliken Center and see the opened windows on your home computer. For anyone, who is interested, just google "X-Server connection windows linux" or some similar combination and try to install this on your own. 
For all others: Install `Xming <https://xming.en.softonic.com/>`_, a free Windows stand-alone program, and follow the setup there. Afterward, always ensure, that ``Xming`` is running, when you open a shell and try to open some visualization software. For that, you only have to start ``Xming`` (press the Windows button, type ``Xming`` and press enter), then the ``Xming`` symbol will appear at your taskbar. 
Now open a shell and type:

.. code-block:: none

   echo "export DISPLAY=localhost:0.0" >> ~/.bashrc
   source ~/.bashrc

If you now want to login to a computer at the Mulliken Center, you have to enable the graphical connection (remember to run ``Xming``!):

.. code-block:: none

   ssh -Y $user@ssh5.thch.uni-bonn.de
   ssh -Y /path/to/MCTC/computer

Without the *-Y*, the graphical connection will not work. 

.. _Software for visualization of molecules:

Software for visualization of molecules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
A quantum chemical calculation always needs a structure as input (and will often result in a modified structure as output), so you need some kind of visualization program to create the desired molecule or to look at it. We recommend the use of the program `Avogadro <https://avogadro.cc/>`_ to generate and manipulate molecules. 
Next, you will need the program `molden <http://cheminf.cmbi.ru.nl/molden/>`_ for some exercises (we recommend the version ``gmolden``). You can open an input file (*e.g.* ``molden.input`` or a ``*.xyz`` file) by typing:

.. code-block:: none

   gmolden <input>

For Windows users that have unpacked the linked .rar file, we recommend open the input file by right-clicking on it and selecting "Open with", then choose the unpacked ``gmolden.exe`` file.
You can also use ``gmolden`` for generation and manipulation of molecules, but we recommend the use of ``Avogadro``. 
Of course you can also use any other visualization software you know. Please remember that for some exercises it is important to keep the atom count during the manipulation of the molecule geometry, which some of the more common programs do not do (``Avogadro`` keeps it). 

.. _Plotting:

Plotting
~~~~~~~~
For some exercises you have to create proper plots. In our group we usually use ``gnuplot`` for this, a powerful program if you can handle it. ``gnuplot`` scripts for any plotting problem you can imagine (and much more) are easy to find on the Internet. In general, you tell the program via a small script in which format you want your final picture, you name your axis and then plot directly from an extern file. In the following, you will find a small script called plot.gp to plot your data points as a line with ``gnuplot``.

.. code-block:: none
   :linenos:

   set terminal pdf color font 'Times-Roman, 30'    # Produce files in pdf format as output, you can also choose jpeg, eps, or whatever you like
   set output 'NAME.pdf'                            # your final file is named "Name.pdf"
   set encoding iso_8859_1                          # Sometimes needed for e.g. the "angstrom" symbol

   set key font "Times-Roman, 20"                   # Sets a legend for your plot. 

   set xlabel "X-AXIS" font",20"                    # Sets name for the X-axis (don't forget the unit!)
   set xtics nomirror                               # Tells gnuplot, that the scale is only shown on one side
   set xtics font 'Times-Roman, 20'                 # Sets font for the x-scale 
   set xzeroaxis                                    # Draws a line at y=0 
   set ylabel "Y-AXIS" font",20"                    # Same as for the X-axis, just for the y-axis
   set ytics nomirror
   set ytics font 'Times-Roman, 20'

   plot \                                           # Finally the plot command. The "\" tells gnuplot to also plot the next line. Remove the out-commented description before plotting, as it can cause errors. 
   'file.txt' u 1:2 w l lw 2, \                     # "file.txt" is the File which will be plotted. "u 1:2" means literally "use column 1 and 2", "w l" = with lines ("w lp" = with line points, prints a line with points at the respective data points), "lw 2" = linewidth 2. You can do many more things here, these are just some exemplary points. Remove this comment before plotting. 

Copy this file in your working directory, if you want to plot something with ``gnuplot``. For actually plotting your data, change at least *file.txt* to however your file with the data points is called, and then type: 

.. code-block:: none

   gnuplot plot.gp

Now you can find your graphic *Name.pdf* in the directory, where you executed your plot script. To look at it, you can either copy the file to your local computer (and use whatever pdf reader you use to open it), or you can open it with e.g. *okular* (preinstalled on the MCTC computers) by typing: 

.. code-block:: none

   okular Name.pdf

Remember, that you need a graphical connection for the latter. If you now want to change something in your plot, you just have to modify the script *plot.gp* and plot it again as described above. 

Instead of ``gnuplot``, you can also use any other plotting program (Microsoft's ``Excel``, LibreOffice's ``Calculator``, ``SciDavis``, you name it).  In the end, it is only important that the plots follow some simple rules:

1. Axes are labeled with the correct expression and unit (e.g. **time / h**).

2. Axes are divided with markings/tics and numbers. 

3. All lines in a plot should look different. Different colors are one possibility, which breaks down by printing the protocols in black and white. You can, of course, use colors, but if you are plotting more than one line, you must also make sure that each line is distinguishable without color (e.g. by using different markers). 

4. Remember: the first thing you usually look at in publications are pictures. Writing protocols prepares you for writing scientific papers, so it is also important to learn how to create nice figures. Every letter (title, axes, etc.) and also the lines should be printed in a size that we can see them at a glance without a magnifier. Avoid similar colors and markings if possible. Name your curves with meaningful expressions. 


All figures in your final report must have captions that adequately describe the illustration. Captions should describe the contents of a figure in as few words as possible. 

.. hint::

   If you do not immediately understand your own plot after two days, it is probably bad. Rethink.

Summary
~~~~~~~

Check the ``.bashrc`` of your local Linux distribution and add ``export DISPLAY=localhost:0.0``, if you want to use a graphical interface to the MCTC computers. 

+------------+--------------+--------------------------------------------+-----------+
| Program    | local / MCTC | Links (if local installation needed)       | optional? |
+============+==============+============================================+===========+
| Xming      | local        | `<https://xming.en.softonic.com>`_         | yes       |
+------------+--------------+--------------------------------------------+-----------+
| avogadro   | local / MCTC | `<https://avogadro.cc/>`_                  | no        |
+------------+--------------+--------------------------------------------+-----------+
| molden     | local / MCTC | `<http://cheminf.cmbi.ru.nl/molden/>`_     | no        |
+------------+--------------+--------------------------------------------+-----------+
| gnuplot    | MCTC         | [-]                                        | yes       |
+------------+--------------+--------------------------------------------+-----------+
