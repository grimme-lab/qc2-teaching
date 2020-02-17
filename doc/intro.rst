Working on Linux
================

As you participate in this lab exercise, you must have at
least a basic knowledge of working with a Linux computer.
This chapter shows you the basic commands to get along with your computational
environment.
First of all, you will be provided with a **username** and a **password**.
This represents your user account for the whole lab course and all the data you
produce is available with this information.

Login
-----

The first thing you will see after booting the computer is the *login-screen*.


Dependent on the Linux version you are using this screen may look slightly
different. After you typed in your username and password you press the
``<Return>`` key and the graphical desktop will be loaded. All further
actions will take place in this environment. The next and certainly most
important thing is to access the Linux command line. This is usually
done by starting a terminal-emulator, which is called
**shell** or **terminal**. On the machines you are using there should be a
quick start icon directly on the desktop. By clicking on this icon, a window is
opened which allows you to communicate with the PC in a command-line mode.

Shell in a nutshell
-------------------

After executing the terminal-emulator you will end up with a window, which
looks similar to the following image:

.. code:: none

   ehlert@c01:~> pwd
   /home/ehlert
   ehlert@c01:~> ls
   Desktop     Music      QCII
   Documents   Pictures   Templates
   Downloads   Public     Videos
   ehlert@c01:~> cd QCII
   ehlert@c01:~/QCII>

On the left, you can see the so-called **prompt**. Depending on the default
settings of your system it provides you with various information. In a
standard configuration, it will show: ``username@hostname:~>``,
where ``username`` is your username, ``hostname`` is the name of the
computer and the tilde (``~``) shows that you are currently located in
your **home directory** (``/home/username``).
The Linux file structure follows the *Filesystem Hierarchy Standard*,
which ensures a similar file structure on every version of Linux you can get.
As you work with the system you will rapidly gain experience with the different
directories and their purposes. For now, you should know that you are in your
home directory which is located at ``/home/username`` and is abbreviated by ``~``.

With your user account you have the power to create, edit, and delete files in
your home directory at will. But with great power comes great responsibility.
You have to be careful with the commands you execute when you delete or
overwrite a file it is gone for good.
With that in mind, we can now start with the first couple of commands.
To see exactly which directory you are in,
type ``pwd`` (print working directory) and press ``<Return>``.
Since you are in your home directory, this will print the path to that home
directory to the screen.
Note that all input in the terminal is case-sensitive.

.. code:: none

   ehlert@c01:~> pwd
   /home/ehlert

A standard set of commands is shown in the following table:

+-----------------------+----------------------------------------------+
|  command              | description                                  |
+=======================+==============================================+
| ``pwd``               | print the working directory                  |
+-----------------------+----------------------------------------------+
| ``ls``                | lists the files in the current directory     |
+-----------------------+----------------------------------------------+
| ``cd <name>``         | change to the directory with ``<name>``      |
+-----------------------+----------------------------------------------+
| ``cd ..``             | change to the parent directory               |
+-----------------------+----------------------------------------------+
| ``cp <old> <new>``    | copy file ``<old>`` to ``<new>``             |
+-----------------------+----------------------------------------------+
| ``cp -r <old> <new>`` | copy directory ``<old>`` to ``<new>``        |
+-----------------------+----------------------------------------------+
| ``mv <old> <new>``    | move (rename) file/directory                 |
+-----------------------+----------------------------------------------+
| ``rm <name>``         | remove file with ``<name>``                  |
+-----------------------+----------------------------------------------+
| ``rm -r <name>``      | remove directory recursively (caution!)      |
+-----------------------+----------------------------------------------+
| ``mkdir <name>``      | make a new directory with ``<name>``         |
+-----------------------+----------------------------------------------+
| ``rmdir <name>``      | remove (empty) directory with ``<name>``     |
+-----------------------+----------------------------------------------+

This is only a very basic list of commands available and some of them have a
huge variety of options that can not be listed here, and will hardly concern you.
For all options the program can be started with ``<command> --help`` and
a complete summary can be found in its manual page by ``man <command>``.

.. admonition:: Exercise 1

   To get familiar with the shell try to achieve the following task

   1. change to the ``QCII`` directory
   2. find the ``tutorial`` directory in ``QCII``
   3. rename the ``tutorial`` directory to ``shell tutorial``
   4. change to the newly created directory

.. admonition:: Solutions 1
   :class: tip

   A sequence of this command would achieve the wished results.

   .. code:: none

      username@hostname:~> cd QCII
      username@hostname:~/QCII> ls tutorial
      tutorial
      username@hostname:~/QCII> mv tutorial shell tutorial
      mv: cannot move 'tutorial' to a subdirectory of itself, 'tutorial/tutorial'
      mv: cannot stat 'shell': No such file or directory
      username@hostname:~/QCII> mv tutorial 'shell tutorial'
      username@hostname:~/QCII> cd shell\ tutorial
      username@hostname:~/QCII/shell tutorial>

   Note that you have to escape the space in ``shell tutorial`` in some way.

Editors
-------

To access and edit any text file in Linux you will need an editor. A huge variety
of editors exist and your difficult task is to pick the one you are most
comfortable with. We introduce the most common ones in this chapter but feel
free to work with the editor that fits you the best.

Atom
~~~~

``atom`` is a rather heavyweight but easy-to-use editor, which is built on-top
of the ``electron`` framework and has comparable capabilities to a web browser.
Since we are dealing here with electrons and atoms the choice of programs
could not have been better, unfortunately, they do not know much about quantum
chemistry.
For you can work entirely in ``atom``, but you need some extension which
might already be installed with your version of ``atom``.
If not install ``language-fortran``, ``build``, ``build-make`` and ``terminal-tab``
at the setting menu ``<ctrl>-<,>`` under *install*.
``atom`` can be easily extended to a complete integrated development environment,
but we will assume you are working with a vanilla version including the four
additional packages here.

Start ``atom`` by using ``<alt>-<F2>`` and typing atom in the quick launch bar
or searching the start menu for ``atom``.

.. image:: img/atom-new.png
   :alt: New atom instance

Having started a new instance of ``atom`` you either have already an empty
file opened or you can open a new file by ``<ctrl>-<n>``, save the file
with ``<ctrl>-<s>`` by creating a new directory and giving the file a name there,
if you name the file ``hello.f90`` it will be automatically identified as
Fortran source code.

.. image:: img/atom-new-folder.png
   :alt: Always save your files

You can start a shell by hitting ``<ctrl>-<shft>-<p>`` and typing ``terminal``
in the quick launcher of ``atom`` the shell can be used for all commands you
previously learned.

.. image:: img/atom-terminal.png
   :alt: Quicklaunch terminal

Later you can use it to compile and execute your programs without leaving
your editor. For example, we write a simple Fortran program to print a line
to the screen, save it and compile it using ``gfortran`` in our shell inside
``atom``.

.. image:: img/atom-run.png
   :alt: Running gfortran from atom

Vim
~~~

We usually prefer to use ``vim`` which is a very powerful and lightweight editor
once you have mastered the initial steep learning curve.
It has the advantage of being installed by default on almost any Linux
machine and is even fully usable without a graphical user interface.

However, getting past the initial learning curve can take the better part of a
month, but having truly mastered ``vim`` usually results in a huge performance
gain when developing. We encourage you to pick up ``vim`` instead of ``atom``.

To get started with ``vim`` open a new terminal (type ``<alt>-<F2>`` for the
quick launch menu, then type ``konsole`` or search for it in the menu) and
type ``vimtutor``.
This will launch an instance of ``vim`` with an extensive introduction for using
it, follow the instructions until you feel confident navigating and editing files
with ``vim``.

.. attention::
   Don't read past this note without finishing ``vimtutor``!

To make working with ``vim`` easier for you, we changed some of the default
settings for you. Type ``vim ~/.vimrc`` to look into our setup, if you are
not happy with something we put in here, feel free to modify or replace it,
you can also add new configurations if you like.

After you have covered the basics, there are some tricks you might find useful.

.. tip::

   We recommend working with a *single* instance of ``vim`` in *one* terminal,
   if used right ``vim`` can provide all functions from your file navigator
   and terminal.

1. Open your current working directories with ``vim .`` and you will find yourself
   in the ``netrw`` file navigator.
2. Navigate to a file you would like to open and hit ``<Enter>``, it will be opened
   in the same ``vim`` instance, to get back type ``:E`` in normal mode and find
   yourself back in ``netrw``.
3. To open a new window type ``<ctrl>-w n``, you can close the window again
   with ``<ctrl>-w q`` or by typing ``:q`` as usual.
4. To open a second window you can split your ``vim`` window by using ``<ctrl>-w v``
   (for vertical splitting) or ``<ctrl>-w s`` (for horizontal splitting) to have
   to windows with the same file which can be used independently.

.. tip::

   If your ``vim`` instance freeze, you hit ``<ctrl>-s`` by accident, which
   tells the hosting terminal to freeze, unfreeze it with ``<ctrl>-q``.

5. If you have your mouse enabled for ``vim`` you can jump between windows
   by clicking into another window, the faster way is to use ``<ctrl>-w w``
   to go to the next window.

Make yourself familiar with navigation between multiple windows by creating,
closing and jumping between multiple windows.
You can yank and paste content between the windows that way, which allows
seamless transfer between different files.

6. Now go in one of the windows back to ``netrw``, we want to create a new
   directory without using ``:!mkdir ...``, type ``d`` in normal mode in your
   ``netrw`` instance and you should be prompted to provide a name.
7. You can delete it again with ``D``, do so by moving your cursor over the file
   or directory and press ``D``, then accept your choice in the prompt.
8. Now we want a new file, the easiest way would be ``:e ...``, but this path
   has to be relative from the working directory we started our ``vim`` instance
   in, so we use ``netrw`` instead and type ``%`` which prompts as to provide
   a name and opens the new file afterward in a new ``vim`` window.

Let's open a new file ``hello.f90`` and enter

.. code-block:: fortran
   :linenos:

   program hello
      implicit none
      write(*, '(a)') "My first Fortran program"
   end program hello

.. tip::

   In case the syntax highlighting looks strange, ``vim`` is trying to use
   Fortran 77 highlighting, add ``let fortran_free_source=1`` to your ``.vimrc``
   to get the correct Fortran 90 highlighting and restart ``vim`` for it to
   take effect.

After saving the file, compile and run it by typing ``:!gfortran % && ./a.out``,
you should see something like this printout in your terminal:

.. code-block:: none

   My first Fortran program

   Press ENTER or type command to continue

The first line is from your program, the second one is produced by ``vim``.

.. note::

   To switch between your terminal and ``vim`` use ``<ctrl>-z`` to stop ``vim``
   and get it back from the terminal by using the command ``fg``.

At this point, you should be ready to use ``vim`` in production, happy coding.
