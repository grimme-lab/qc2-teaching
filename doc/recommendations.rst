Recommendations
===============

General Recommendations
-----------------------

Working with this Script
~~~~~~~~~~~~~~~~~~~~~~~~

1. Work on the exercises in the given successive order. In the first exercises you will learn some basic
   routines and procedures which you will need again later but which will not be explained once more.

2. Read the whole exercise before you start working on it. Often technical hints are given at the end.

3. Programs can crash. So check your outputs as soon as possible to make sure your calculations actually did work.
   And sometimes preparing the input and running the program is much faster than finding the right number
   in the output.

4. Prepare an LibreOffice sheet (or similar) with a collection of your results. Checking them this way is much easier for us.

Trouble Shooting
~~~~~~~~~~~~~~~~

Many programs may cause many problems, therefore you should follow some simple guidelines to identify their origins:

- "Crap in, crap out": Always check your input (input structures, file formats, input file, chosen keywords etc.) before you start a calculation.
- If a calculation stops abnormally check the output (*e.g.* orca.out, job.last etc.) and error files first. Always make sure that you pipe all needed output data into files if its not done by default.
- Read your output and error files carefully. Especially check the last lines of the output file for error messages that give a hint what may caused the problem.
- If you identified the problem (maybe you have to start at the first point again), check the program manual for additional options or trouble shooting help, fix the problem and restart your calculation.
- If the calculation still stops abnormally and all other possibilities and options are exhausted, prepare a detailed description of the problem, the output/error messages and contact one of the tutors.


Software Recommendations
------------------------


Logging in to your work machine
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

At the beginning of the course you got a number of the computer you will work on.

First you need access to the intranet. The only way to access any machine in the facility is by tunneling via the ssh-server.
You will receive an account on one of the ssh-servers as well.

.. important::

   The ssh-server is not only used by you, but also by your fellow students and possibly also by members of the institute.
   We expect responsible behaviour from you on the server, because many people depend on those servers running reliably.

   Whatever you do, never copy large files to the ssh-server, it has only very limited disk space.
   Also do not run any resource consuming program on the server (anything that needs a GUI is per definition resource consuming if used on shared resources).

First, we will work with three machines in this tutorial, your local machine (``M-Bot``), the ssh-server instance (``ssh3``) and the CIP computer (``c00``).
``c00`` is an existing machine, you can log in there as well, it is also the least powerful machine, therefore, just do not use this machine for computations, use the one you were assigned.
Your local username might also be different from the one in the facility, we will use ``stahn`` for the user on the local machine as well as for the user at the facility.

.. attention:: 

   When following the steps described afterward, you have to change the respective names (both usernames and hostnames), of course.
   You will *not* be able to use ``ssh3`` to log in the ssh server, but a different machine (most likely ``ssh5``).

   Please read the tutorial and the code snippets carefully, understand what is shown and adapt the commands accordingly.
   *A copy and paste approach on this tutorial will fail!*

We will always show a prompt with username and hostname to illustrate who and where we are.
To setup a similar prompt in your shell set the following in your bashrc (note that you will have several bashrcs, one on each machine).

.. code-block:: bash

   PS1='[\u@\h \W] \$ '

.. admonition:: Note for Windows Users

   Don't worry if you are using WSL under Windows. You can do all the following steps as described.
   Just find the notes when things behave a bit special.

The easy way
^^^^^^^^^^^^

If you log in for the first time you will be asked for confirming the host identity, do so.
The request will be gone if you log in a second time.

.. code-block:: none
   :linenos:
   :emphasize-lines: 4, 6, 10, 12, 19, 22

   stahn@M-Bot:~/.ssh$ ssh -Y stahn@ssh3.thch.uni-bonn.de
   The authenticity of host 'ssh3.thch.uni-bonn.de (131.220.44.130)' can't be established.
   ECDSA key fingerprint is SHA256:eEdQpqyV6oP0Ddra7H2QDI6kC9rX3XQRAlWxX6LfA6U.
   Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
   Warning: Permanently added 'ssh3.thch.uni-bonn.de' (ECDSA) to the list of known hosts.
   Password:
   stahn@ssh3:~> ssh -Y stahn@c00
   The authenticity of host 'c00 (172.17.3.20)' can't be established.
   ECDSA key fingerprint is SHA256:ozq72tQ9gROvzDwv+ZFQ7wc+L/Dmu9Fptbfhf2zfd1M.
   Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
   Warning: Permanently added 'c00,172.17.3.20' (ECDSA) to the list of known hosts.
   Password: 
   Have a lot of fun...
   stahn@c00:~> logout  
   Connection to c00 closed.
   stahn@ssh3:~> logout
   Connection to ssh3.thch.uni-bonn.de closed.
   stahn@M-Bot:~/.ssh$ ssh -Y stahn@ssh3.thch.uni-bonn.de
   Password:
   Last login: Thu Feb 17 16:39:19 2022 from 131.220.44.207
   stahn@ssh3:~> ssh -Y stahn@c00
   Password: 
   Last login: Thu Feb 17 16:39:35 2022 from 131.220.44.130
   Have a lot of fun...
   stahn@c00:~> 


.. note::

   In the following guide we will highlight every line, which requires user input

From here you have everything you need to work on the machines, but it might get somewhat inconvenient because you have to type your password every time.
Also copying files back to your machine is not easily possible, because you shall not copy big files to the ssh-server.

The following guide is a bit lengthy, but you only have to do it once and you can easily work and move files between your local computer and your work machine.


The right way
^^^^^^^^^^^^^

We start on your local machine, we create the ssh directory in your home by

.. code-block:: none
   :linenos:

   stahn@M-Bot:~$ cd ~
   stahn@M-Bot:~$ mkdir .ssh
   stahn@M-Bot:~$ chmod 700 .ssh

The last step ensures that you and only you have access to your ssh keys, never allow anyone else access to this directory!

.. admonition:: Note for Windows Users

   Using WSL, you might have two ``.ssh`` directories. The Linux one is the same as above and found in:
   
   .. code-block:: none

      ~/.ssh

   The Windows one can be found in your Windows home directory (assuming ``stahn`` is your Windows username):

   .. code-block:: none

      /mnt/c/Users/stahn/.ssh

   Don't get confused by that and decide upon one of these directories (*e.g.* the Linux one) for the next steps.
   If something doesn't work, check if there are perhaps doubled files interfering each other.

We enter the ssh directory to create a new ssh-keypair, we recommend using elliptic curve keys because they are short and fast:

.. code-block:: none
   :linenos:
   :emphasize-lines: 3, 4, 5

   stahn@M-Bot:~/.ssh$ ssh-keygen -t ed25519
   Generating public/private ed25519 key pair.
   Enter file in which to save the key (/home/stahn/.ssh/id_ed25519): id_ssh3
   Enter passphrase (empty for no passphrase): 
   Enter same passphrase again: 
   Your identification has been saved in id_ssh3
   Your public key has been saved in id_ssh3.pub
   The key fingerprint is:
   SHA256:bDVv26H9hIx1K21pFRZXF2pqfD8Mw9osb2K5opLeOHU stahn@M-Bot
   The key's randomart image is:
   +--[ED25519 256]--+
   |               o*|
   |              . +|
   |          o  o o |
   |       . ..o+ . .|
   |        S  +o=o o|
   |       o E..=O*++|
   |      o .  o=+=X.|
   |     +o  . +o.+o.|
   |    .ooo. o.+.  .|
   +----[SHA256]-----+



The key-generator will prompt you a to enter a filename, we will name the key
``id_ssh3``, choose any name you find appropriate.

.. tip::

   A very good read on the generation of ssh-keypairs is the `Arch Linux wiki page on ssh-keys <https://wiki.archlinux.org/index.php/SSH_keys#Generating_an_SSH_key_pair>`_.

Now we need to copy the public key to the ssh-server. Since you log in for the first time, you have to provide your password in line 5:

.. code-block:: none
   :linenos:
   :emphasize-lines: 1, 5, 7

   stahn@M-Bot:~/.ssh$ ssh-copy-id -i id_ssh3 stahn@ssh3.thch.uni-bonn.de
   /usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "id_ssh3.pub"
   /usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
   /usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
   Password: 

   Number of key(s) added: 1

   Now try logging into the machine, with:   "ssh 'stahn@ssh3.thch.uni-bonn.de'"
   and check to make sure that only the key(s) you wanted were added.




You can check, if your key was succesfully added by logging into the machine. The ssh-server will probably be unknown to your local machine, therefore, you have to add it to your known hosts list first, type yes when prompted in line 4.


.. code-block:: none
   :linenos:
   :emphasize-lines: 1,4,7

   stahn@M-Bot:~/.ssh$ ssh stahn@ssh3.thch.uni-bonn.de
   The authenticity of host 'ssh3.thch.uni-bonn.de (131.220.44.130)' can't be established.
   ECDSA key fingerprint is SHA256:eEdQpqyV6oP0Ddra7H2QDI6kC9rX3XQRAlWxX6LfA6U.
   Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
   Warning: Permanently added 'ssh3.thch.uni-bonn.de' (ECDSA) to the list of known hosts.
   Last login: Thu Feb 17 13:56:18 2022 from 131.220.44.207
   stahn@ssh3:~> 

We need to register the ssh-server now in our configuration file

.. code-block:: none
   :linenos:

   stahn@M-Bot:~/.ssh$ vim config

We will use ``vim`` here but feel free to edit the file with your preferred editor and add the lines:

.. code-block:: none
   :linenos:

   Host ssh3.thch.uni-bonn.de
      IdentityFile ~/.ssh/id_ssh3

Now we will try again, to see if our connection is correctly established.

.. code-block:: none
   :linenos:

   stahn@M-Bot:~/.ssh$ ssh stahn@ssh3.thch.uni-bonn.de
   stahn@M-Bot:~/.ssh$

If you are prompted for a password your setup is wrong and you have to retry.

.. tip::
   
   You can also optionally add your username to the ssh config file and set up a custom Hostname for the ssh-server.

   .. code-block:: none

      Host ssh3
         Hostname ssh3.thch.uni-bonn.de
         User stahn
         IdentityFile ~/.ssh3/id_ssh3

   This will allow you to easily connect to the ssh-server by just typing:

   .. code-block:: none

      stahn@M-Bot:~/.ssh$ ssh ssh3
      Last login: Thu Feb 17 13:57:03 2022 from 131.220.44.207
      stahn@ssh3:~> 


Now we have to repeat the same steps for the machine at the facility, but first we need to be able to directly connect to it from our local working machine.
We do so by altering the ssh-config and adding the following lines:

.. code-block:: none
   :linenos:

   Host c00
      ProxyJump ssh3
      User stahn

We just told our system, that it needs to use the ssh-server as a proxy for connecting to our remote working machine. 
This enables us to connect to our remote working machine at the facility by a single ssh command:

.. code-block:: none
   :linenos:
   :emphasize-lines: 1,4,6,8

   stahn@M-Bot:~/.ssh$ ssh c00
   The authenticity of host 'c00 (<no hostip for proxy command>)' can't be established.
   ECDSA key fingerprint is SHA256:ozq72tQ9gROvzDwv+ZFQ7wc+L/Dmu9Fptbfhf2zfd1M.
   Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
   Warning: Permanently added 'c00' (ECDSA) to the list of known hosts.
   Password: 
   Have a lot of fun...
   stahn@c00:~> 


.. .. admonition:: Note for Windows Users

..    To make this work via WSL, you have to add the address of ``c00`` in the file in ``/etc/hosts``.
..    Changes to this file won't last long as it is overwritten from the Windows hosts file.
..    You can find the file in your Windows directory:

..    .. code-block:: none

..       /mnt/c/Windows/System32/drivers/etc/hosts

..    Open your shell as administrator, then open this file with some text editor and add the following line *e.g.*
..    at the end (replace ``c00`` by your computer):

..    .. code-block:: none

..       127.0.0.1     c00

..    After closing and opening the terminal again, the file ``/etc/hosts`` should now also contain
..    this line and you can open the above mentioned ssh tunnel.

Now we generate another keypair (always use a new keypair for each connection) and register the connection like before:

.. code-block:: none
   :linenos:
   :emphasize-lines: 1, 3, 4, 5, 22, 26, 28

   stahn@M-Bot:~/.ssh$ ssh-keygen -t ed25519
   Generating public/private ed25519 key pair.
   Enter file in which to save the key (/home/stahn/.ssh/id_ed25519): id_c00
   Enter passphrase (empty for no passphrase): 
   Enter same passphrase again: 
   Your identification has been saved in id_c00
   Your public key has been saved in id_c00.pub
   The key fingerprint is:
   SHA256:mUBCFiGUc6kqbb1fspxwQ0k9V0eT8sg59bV80w7jPTM stahn@M-Bot
   The key's randomart image is:
   +--[ED25519 256]--+
   | .oo*+.     ..+. |
   |  oooo .   ...o..|
   |   +  o o .. *..+|
   |  .  . o =  = +++|
   | o .  o S    o =o|
   |o o ..        .Eo|
   |..  ..+ .       +|
   |    .+ *         |
   |     .=          |
   +----[SHA256]-----+
   stahn@M-Bot:~/.ssh$ ssh-copy-id -i id_c00.pub c00
   /usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "id_c00.pub"
   /usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
   /usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
   Password: 
      
   Number of key(s) added: 1
      
   Now try logging into the machine, with:   "ssh 'c00'"
   and check to make sure that only the key(s) you wanted were added.




Finally we want to include the new ssh-key to our ssh-config by adding the following lines to our ssh-config:

.. code-block:: none
   :linenos:

   Host c00
      ProxyJump ssh3
      User stahn
      IdentityFile ~/.ssh/id_c00

Now try to login to the work machine again (remember to specify the X forwarding).

.. code-block:: none
   :linenos:

   stahn@M-Bot:~/.ssh$ ssh -Y c00
   Last login: Thu Feb 17 15:00:38 2022 from 131.220.44.130
   Have a lot of fun...
   stahn@c00:~> 


Again, if you have to enter your password, the setup was not correct and you have to retry.
From now on, you can also copy files from and to your work machine.

.. code-block:: none
   :linenos:

   stahn@M-Bot:~/.ssh$ scp Lehre/lect3_htm.doc c00:Documents/.
   stahn@M-Bot:~/.ssh$ scp c00:Lehre/QC2.pdf ~/Lehre/QC2/.

As a short recap, you should now be able to log in with a single command.

.. code-block:: none
   :linenos:

   stahn@M-Bot:~/.ssh$ ssh c00
   Last login: Thu Feb 17 15:08:55 2022 from 131.220.44.130
   Have a lot of fun...
   stahn@c00:~> 


Tips and Tricks
^^^^^^^^^^^^^^^

For the three machine setup we had, a configuration file like the following would be appropriate:

.. code-block:: none
   :linenos:

   Host c00
     User stahn
     IdentityFile ~/.ssh/id_c00
     ProxyJump ssh3                                                           

   Host ssh3                                                                   
     Hostname ssh3.thch.uni-bonn.de                                           
     User stahn                                                               
     IdentityFile ~/.ssh/id_ssh3

If you are working remotely over ssh, any process you start with the shell will be terminated as soon as you log out.
Keeping your process alive, requires that you detach the process from your terminal.
You can create a completely detached process by:

.. code-block:: none

   stahn@M-Bot:~/.ssh$ setsid xtb h2o.xyz > xtb.out

However, keep in mind, that you have no control at all over this process after starting it. Normally, setting the process to ignore Hangup Signals and rerouting the output of the process is enough to keep it alive.
You can do so by using nohup.

.. code-block:: none

   stahn@M-Bot:~/.ssh$ nohup xtb h2o.xyz

Any output created by the process will be printed to nohup.out.

.. note::

   ``nohup`` is a useful to run commands on your work machine that should continue even if you log out from the ssh-session.

   More lengthy calculations with quantum chemistry software are a potential target for this approach.
   But think first before adapting the above command, because you probably want to keep the output instead of scrapping it to ``/dev/null``.
   Also, you won't have to kill your program in the end, because it will terminate on its own.


If you like the prompt style and want to use it for your bash as well, there is also a colorful version available.
Just add this lines to your bashrc (if you always want a full path use ``\w`` instead of ``\W``).

.. code-block:: bash
   :linenos:

   if ${use_color} ; then
     if [[ ${EUID} == 0 ]] ; then
       # show a red prompt if we are root
       PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]] \$\[\033[00m\] '
     else
       PS1='\[\033[01;32m\][\u@\h \W] \$\[\033[01;37m\] '
     fi
   else
     if [[ ${EUID} == 0 ]] ; then
       # show root@ when we don't have colors
       PS1='[\u@\h \W] \$ '
     else
       PS1='[\u@\h \W] \$ '
     fi
   fi

.. note:: 

   If you want other colors, play a bit around with the last number in the bracktes (\[\033[01:**31** m\]). If you want your username in different color than your path you can also specify this. Play a bit around with it. 

X-Server or How to make your graphical connection work (optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sometimes it is easier to directly have a look at structures or plots, instead of copying everything to your local computer. Therefore, we recommend an application that enables you to open graphical interfaces on the CIP Pool computers in the Mulliken Center and see the opened windows on your home computer. For everyone, who is interested, just google "X-Server connection windows linux" or some similar combination and try to install this on your own.
For all others: Install `Xming <https://xming.en.softonic.com/>`_, a free Windows stand-alone program, and follow the setup there. Afterwards, always ensure that ``Xming`` is running, when you open a shell and try to open some visualization software. For that, you only have to start ``Xming`` (press the Windows button, type ``Xming`` and press enter), then the ``Xming`` symbol will appear at your taskbar.
Now open a shell and type:

.. code-block:: none

   echo "export DISPLAY=localhost:0.0" >> ~/.bashrc
   source ~/.bashrc

Now you can login as described above (remember to have ``Xming`` running). 

.. _Software for visualization of molecules:

Software for Visualization of Molecules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
A quantum chemical calculation always needs a structure as input (and will often result in a modified structure as output), so you need some kind of visualization program to create the desired molecule or to look at it. We recommend the use of the program `Avogadro <https://avogadro.cc/>`_ to generate and manipulate molecules.
Next, you will need the program `molden <https://ftp.science.ru.nl/Molden/bin/Windows/molden_native_windows_full.rar>`_ for some exercises (we recommend the version ``gmolden``). You can open an input file (*e.g.* ``molden.input`` or a ``*.xyz`` file) by typing:

.. code-block:: none

   gmolden <input>

For Windows users that have unpacked the above linked .rar file, we recommend opening the input file (``molden.input`` or ``*.xyz``) by right-clicking on it and selecting "Open with", then choose the unpacked ``gmolden.exe`` file in the ``molden64\bin`` folder.
You can also use ``gmolden`` for generation and manipulation of molecular structures, but we recommend the use of ``Avogadro``.
Of course you can also use any other visualization software you know. Please remember that for some exercises it is important to keep the atom count during the manipulation of the molecule geometry, which some of the more common programs do not do (``Avogadro`` keeps it).

.. note:: During testing ``gmolden`` with Windows 10, we encountered problems if the path contains blanks or umlauts (*e.g.* C:\Program Files\molden). If you cannot open ``gmolden`` on your windows computer, copy the *molden folder* to you desktop and try again.

.. _Plotting:

Plotting
~~~~~~~~
For some exercises you have to create proper plots. In our group we usually use ``gnuplot`` for this, a powerful program if you can handle it. ``gnuplot`` scripts for any plotting problem you can imagine (and much more) are easy to find on the Internet. In general, you tell the program via a small script in which format you want your final picture, you name your axis and then plot directly from an external file. In the following, you will find a small script called ``plot.gp`` to plot your data points as a line with ``gnuplot``.

.. code-block:: none
   :linenos:

   set terminal pdf color font 'Times-Roman, 30'    # Produce files in pdf format as output, you can also choose jpeg, eps, or whatever you like
   set output 'NAME.pdf'                            # your final file is named "NAME.pdf"
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

Copy this file in your working directory, if you want to plot something with ``gnuplot``. For actually plotting your data, change at least ``file.txt`` to however your file with the data points is called, and then type:

.. code-block:: none

   gnuplot plot.gp

Now you can find your graphic ``NAME.pdf`` in the directory, where you executed your plot script. To look at it, you can either copy the file to your local computer (and use whatever pdf reader you use to open it), or you can open it with e.g. *Okular* (preinstalled on the MCTC computers) by typing:

.. code-block:: none

   okular NAME.pdf

Remember that you need a graphical connection for the latter. If you now want to change something in your plot, you just have to modify the script ``plot.gp`` and plot it again as described above.

Instead of ``gnuplot``, you can also use any other plotting program (Microsoft's *Excel*, LibreOffice's *Calculator*, *SciDavis*, you name it).  In the end, it is only important that the plots follow some simple rules:

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

+------------+--------------+---------------------------------------------------+-----------+
| Program    | local / MCTC | Links (if local installation needed)              | optional? |
+============+==============+===================================================+===========+
| Xming      | local        | `<https://xming.en.softonic.com>`_                | yes       |
+------------+--------------+---------------------------------------------------+-----------+
| avogadro   | local / MCTC | `<https://avogadro.cc/>`_                         | no        |
+------------+--------------+---------------------------------------------------+-----------+
| molden     | local / MCTC | `<https://uni-bonn.sciebo.de/s/XxSEG5DHbzitX7Z>`_ | no        |
+------------+--------------+---------------------------------------------------+-----------+
| gnuplot    | MCTC         | [-]                                               | yes       |
+------------+--------------+---------------------------------------------------+-----------+
