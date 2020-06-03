Recommendations
===============

General Recommendations
-----------------------

Working with this Script
~~~~~~~~~~~~~~~~~~~~~~~~

1. Work on the exercises in the given successive order. In the first exercises you will learn some basic
   routines and procedures which you will need again later but which will not be explained once more.

2. Read the whole exercise before you start to working on it. Often technical hints are given at the end.

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
- If the calculations still stops abnormally and all other possibilities and options are exhausted, prepare a detailed description of the problem, the output/error messages and contact one of the tutors.


Software Recommendations
------------------------


Logging in to your work machine
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

At the beginning of the course you got a number of the computer you will work on.

First you need access to the intranet, the only way to access any machine in the facility is by tunneling via the ssh-server.
You will receive an account on one of the ssh-servers as well.

.. important::

   The ssh-server is not only used by you, but also by your fellow students and possibly also by members of the institute.
   We expect responsible behaviour from you on the server, because many people depend on those servers running reliably.

   Whatever you do, never copy large files to the ssh-server, it has only very limited disk space.
   Also do not run any resource consuming program on the server (anything that needs a GUI is per definition resource consuming if used on shared resources).

First, we will work with three machines in this tutorial, your local machine (``saw2570``), the ssh-server instance (``ssh3``) and the CIP computer (``c00``).
``c00`` is an existing machine, you can log in there as well, it is also the least powerful machine, therefore, just do not use this machine for computations, use the one you were assigned.
Your local username might also be different from the one in the facility, we will use ``awvwgk`` for the user on the local machine and ``ehlert`` for the user at the facility.

.. important:: 

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
   :emphasize-lines: 4, 6, 10, 12, 16, 18

   [awvwgk@saw2570 ~] $ ssh -Y ehlert@ssh3.thch.uni-bonn.de
   The authenticity of host 'ssh3.thch.uni-bonn.de (131.220.44.130)' can't be established.
   ECDSA key fingerprint is SHA256:eEdQpqyV6oP0Ddra7H2QDI6kC9rX3XQRAlWxX6LfA6U.
   Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
   Warning: Permanently added 'ssh3.thch.uni-bonn.de,131.220.44.130' (ECDSA) to the list of known hosts.
   Password:
   [ehlert@ssh3 ~] $ ssh -Y ehlert@c00
   The authenticity of host 'c00 (172.17.3.20)' can't be established.
   ECDSA key fingerprint is 23:66:63:60:8e:17:e0:b3:83:75:03:09:12:39:51:8d [MD5].
   Are you sure you want to continue connecting (yes/no)? yes
   Warning: Permanently added 'c00,172.17.3.20' (ECDSA) to the list of known hosts.
   Password:
   [ehlert@c00 ~] $ logout
   [ehlert@ssh3 ~] $ logout
   [awvwgk@saw2570 ~] $ ssh -Y ehlert@ssh3.thch.uni-bonn.de
   Password:
   [ehlert@ssh3 ~] $ ssh -Y ehlert@c00
   Password:
   [ehlert@c00 ~] $

.. note::

   In the following guide we will highlight every line, which requires user input

From here you have everything you need to work on the machines, but it might get somewhat inconvenient because you have to type your password every time.
Also copying stuff back to your machine is not easily possible, because you shall not copy big files to the ssh-server.

The following guide is a bit lengthy, but you only have to do it once and you can easily work and move files between your local computer and your work machine.


The right way
^^^^^^^^^^^^^

We start on your local machine, we create the ssh directory in your home by

.. code-block:: none
   :linenos:

   [awvwgk@saw2570 ~] $ cd ~
   [awvwgk@saw2570 ~] $ mkdir .ssh
   [awvwgk@saw2570 ~] $ chmod 700 .ssh

The last step ensures that you and only you have access to your ssh keys, never allow anyone else access to this directory!

.. admonition:: Note for Windows Users

   Using WSL, you might have two ``.ssh`` directories. The Linux one is the same as above and found in:
   
   .. code-block:: none

      ~/.ssh

   The Windows one can be found in your Windows home directory (assuming ``awvwgk`` is your Windows username):

   .. code-block:: none

      /mnt/c/Users/awvwgk/.ssh

   Don't get confused by that and decide upon one of these directories (*e.g.* the Linux one) for the next steps.
   If something doesn't work, check if there are perhaps doubled files interfering each other.

We enter the ssh directory to create a new ssh-keypair, we recommend using elliptic curve keys because they are short and fast:

.. code-block:: none
   :linenos:
   :emphasize-lines: 4

   [awvwgk@saw2570 ~] $ cd .ssh
   [awvwgk@saw2570 .ssh] $ ssh-keygen -t ed25519
   Generating public/private ed25519 key pair.
   Enter file in which to save the key (/home/awvwgk/.ssh/id_ed25519): id_ssh3
   Enter passphrase (empty for no passphrase):
   Enter same passphrase again:
   Your identification has been saved in id_ssh3
   Your public key has been saved in id_ssh3.pub
   The key fingerprint is:
   SHA256:ewn6KOiOmALh6wOa9Jo/kda125Wp4w+NmCU//r8f/Pk awvwgk@saw2570
   The key's randomart image is:
   +--[ED25519 256]--+
   |                 |
   |                 |
   |                 |
   |.      .         |
   |..  o ..S.  o    |
   |oo + . o*oo=  .  |
   |=.+.. .o+==.   o |
   |==oo.  +.=o     +|
   |***.... oo+o.oooE|
   +----[SHA256]-----+

The key-generator will prompt you a to enter a filename, we will name the key
``id_ssh3``, choose any name you find appropriate.

.. tip::

   A very good read on the generation of ssh-keypairs is the `Arch Linux wiki page on ssh-keys <https://wiki.archlinux.org/index.php/SSH_keys#Generating_an_SSH_key_pair>`_.

Now we log in at the ssh-server to establish the new connection and setup the keypair.

.. code-block:: none
   :linenos:
   :emphasize-lines: 2, 6, 8

   [awvwgk@saw2570 .ssh] $ ssh ehlert@ssh3.thch.uni-bonn.de <<EOF
   mkdir -p .ssh && chmod 700 .ssh && cd .ssh && echo $(cat id_ssh3.pub) >> authorized_keys
   EOF
   The authenticity of host 'ssh3.thch.uni-bonn.de (131.220.44.130)' can't be established.
   ECDSA key fingerprint is SHA256:eEdQpqyV6oP0Ddra7H2QDI6kC9rX3XQRAlWxX6LfA6U.
   Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
   Warning: Permanently added 'ssh3.thch.uni-bonn.de,131.220.44.130' (ECDSA) to the list of known hosts.
   Password:
   [awvwgk@saw2570 .ssh] $

The ssh-server will probably be unknown to your local machine, therefore, you have to add it to your known hosts list first, type yes when prompted in line 6.
Since you log in for the first time, you have to provide your password in line 8, after line 2 was executed on the ssh-server your keypair has been authorized.
We only executed a command on the ssh-server and ended the session afterwards, you can also log in interactively by

.. code-block:: none
   :linenos:
   :emphasize-lines: 4, 6, 10

   [awvwgk@saw2570 .ssh] $ ssh ehlert@ssh3.thch.uni-bonn.de
   The authenticity of host 'ssh3.thch.uni-bonn.de (131.220.44.130)' can't be established.
   ECDSA key fingerprint is SHA256:eEdQpqyV6oP0Ddra7H2QDI6kC9rX3XQRAlWxX6LfA6U.
   Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
   Warning: Permanently added 'ssh3.thch.uni-bonn.de,131.220.44.130' (ECDSA) to the list of known hosts.
   Password:
   [ehlert@ssh3 ~] $ mkdir .ssh
   [ehlert@ssh3 ~] $ chmod 700 .ssh
   [ehlert@ssh3 ~] $ cd .ssh
   [ehlert@ssh3 .ssh] $ vim authorized_keys
   [ehlert@ssh3 .ssh] $ logout
   Connection to ssh3.thch.uni-bonn.de closed.
   [awvwgk@saw2570 .ssh] $

And paste the content from ``id_ssh3.pub`` into the file (you might need a second terminal now).

.. important::

   Always use the public key of the keypair (the one ending with ``.pub``!), the private key (the one without an extension) stays in relative safety on your machine and **only** your machine!

We need to register the ssh-server now in our configuration file

.. code-block:: none
   :linenos:

   [awvwgk@saw2570 .ssh] $ vim config

We will use ``vim`` here but feel free to edit the file with your preferred editor and add the lines:

.. code-block:: none
   :linenos:

   Host ssh3.thch.uni-bonn.de
      IdentityFile ~/.ssh/id_ssh3

Now we will try again, to see if our connection is correctly established.

.. code-block:: none
   :linenos:

   [awvwgk@saw2570 .ssh] $ ssh ehlert@ssh3.thch.uni-bonn.de
   [ehlert@ssh3 ~] $

If you are prompted for a password your setup is wrong and you have to retry.

Now we have to repeat the same steps for the machine at the facility, but first we want to setup a local forwarding.
We do so by opening a separate terminal and running:

.. code-block:: none
   :linenos:

   [awvwgk@saw2570 ~] $ ssh -L 12345:c00:22 -N ehlert@ssh3.thch.uni-bonn.de &

We created a local port forwarding (a tunnel) to the port 22 of ``c00`` which is now forwarded to your local 12345 port.
Choose any number you like, but try to not use one of the crucial ports from your system (22 and 80 happen to be bad ideas).
You either run this command in a separate terminal and keep it in the foreground (remove the ambersand than) or put the process in the background of your current terminal.
Remember, the process will stop if you close the terminal even if a process is still running in the background and the tunnel will be closed.

.. admonition:: Note for Windows Users

   To make this work via WSL, you have to add the address of ``c00`` in the file in ``/etc/hosts``.
   Changes to this file won't last long as it is overwritten from the Windows hosts file.
   You can find the file in your Windows directory:

   .. code-block:: none

      /mnt/c/Windows/System32/drivers/etc/hosts

   Open your shell as administrator, then open this file with some text editor and add the following line *e.g.*
   at the end (replace ``c00`` by your computer):

   .. code-block:: none

      127.0.0.1     c00

   After closing and opening the terminal again, the file ``/etc/hosts`` should now also contain
   this line and you can open the above mentioned ssh tunnel.

Now we generate another keypair (always use a new keypair for each connection) and register the connection like before:

.. code-block:: none
   :linenos:
   :emphasize-lines: 4, 24, 28, 30

   [awvwgk@saw2570 ~] $ cd .ssh
   [awvwgk@saw2570 .ssh] $ ssh-keygen -t ed25519
   Generating public/private ed25519 key pair.
   Enter file in which to save the key (/home/awvwgk/.ssh/id_ed25519): id_c00
   Enter passphrase (empty for no passphrase):
   Enter same passphrase again:
   Your identification has been saved in id_c00
   Your public key has been saved in id_c00.pub
   The key fingerprint is:
   SHA256:SwLoC0LO9h/pS5wof+2Jn13LJp5d2xpv57kbw3BDNFc awvwgk@saw2570
   The key's randomart image is:
   +--[ED25519 256]--+
   |               oE|
   |   .          . o|
   | .. .          . |
   |+.   .        .  |
   |o+.   . S    . o |
   |o...o oo .    + .|
   | ..o *. .  . o + |
   |  o +.o.+.=.o =.=|
   |   ..=+=.+o+ ooB=|
   +----[SHA256]-----+
   [awvwgk@saw2570 .ssh] $ ssh -p 12345 ehlert@localhost <<EOF
   mkdir -p .ssh && chmod 700 .ssh && cd .ssh && echo $(cat id_c00.pub) >> authorized_keys
   EOF
   The authenticity of host '[localhost]:12345 ([::1]:12345)' can't be established.
   ECDSA key fingerprint is SHA256:ozq72tQ9gROvzDwv+ZFQ7wc+L/Dmu9Fptbfhf2zfd1M.
   Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
   Warning: Permanently added '[localhost]:12345' (ECDSA) to the list of known hosts.
   Password:
   [awvwgk@saw2570 .ssh] $

Finally we want to automate the process a bit more by adding the following lines to our ssh-config:

.. code-block:: none
   :linenos:

   Host c00
      Hostname localhost
      Port 12345
      IdentityFile ~/.ssh/id_c00

Now try to login to the work machine again (remember to specify the X forwarding).

.. code-block:: none
   :linenos:

   [awvwgk@saw2570 .ssh] $ ssh -Y ehlert@c00
   [ehlert@c00 ~] $

Again, if you have to enter your password, the setup was not correct and you have to retry.
From now on, you can also copy files from and to your work machine.

.. code-block:: none
   :linenos:

   [awvwgk@saw2570 ~] $ scp .bashrc ehlert@c00:~/.bashrc
   [awvwgk@saw2570 ~] $ scp ehlert@c00:~/QC2/orca.out QC2/

As a short recap, you should now be able to log in with just to commands.

.. code-block:: none
   :linenos:

   [awvwgk@saw2570 ~] $ ssh -L 12345:c00:22 -N ehlert@ssh3.thch.uni-bonn.de &
   [1] 20640
   [awvwgk@saw2570 ~] $ ssh -Y ehlert@c00
   [ehlert@c00 ~] $

Remember you always have to keep the ssh process alive that provides the tunnel.


Tips and Tricks
^^^^^^^^^^^^^^^

The ssh-config file is quite nice to deal with several use cases, if you do not want to type your user name every time, you can set it in the ssh-config.
For the three machine setup we had a configuration file like the following would be appropriate:

.. code-block:: none
   :linenos:

   Host ssh3.thch.uni-bonn.de
      User ehlert
      IdentityFile ~/.ssh/id_ssh3
      LocalForward 12345 c00:22

   Host c00
      User ehlert
      Hostname localhost
      Port 12345
      IdentityFile ~/.ssh/id_c00

Now logging in to the ssh-server will automatically put in the specified user name and forward port 22 of ``c00`` to the expected local one for you.


If do not to use a separate terminal or a background process for your ssh-tunnel, you can detach the process from your terminal.
You can create a detached process with

.. code-block:: none
   :linenos:

   [awvwgk@saw2570 ~] $ nohup ssh -N ssh3.thch.uni-bonn.de &> /dev/null &
   [1] 20640
   [awvwgk@saw2570 ~] $ exit

To close the tunnel again, you have to kill the process by its process ID.
Usually one does not remember the process ID, but we can easily find it again.

.. code-block:: none
   :linenos:

   [awvwgk@saw2570 ~] $ pgrep -la ssh
   20662 ssh -N ssh3.thch.uni-bonn.de
   [awvwgk@saw2570 ~] $ kill 20662
   [awvwgk@saw2570 ~] $

.. note::

   ``nohup`` is also a useful to run commands on your work machine that should continue even if you log out from the ssh-session.

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
Next, you will need the program `molden <http://cheminf.cmbi.ru.nl/molden/>`_ for some exercises (we recommend the version ``gmolden``). You can open an input file (*e.g.* ``molden.input`` or a ``*.xyz`` file) by typing:

.. code-block:: none

   gmolden <input>

For Windows users that have unpacked the above linked .rar file, we recommend opening the input file (``molden.input`` or ``*.xyz``) by right-clicking on it and selecting "Open with", then choose the unpacked ``gmolden.exe`` file.
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
