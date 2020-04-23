Building Programs
=================

This is a short and concise introduction to building programs.

.. note::

   For this course, you only need to remember that with the ``makefile`` we
   provided you have to invoke ``make`` and find everything has been taken care
   for.

   If you start to expand your program you can inspect the ``makefile`` and find
   where to add new source files to the build, which still does not require
   you to read this introduction or understand how ``make`` works.

   You can still read this introduction, but you are better off skipping it now
   and come back later.

This introduction will cover details on compiling and linking programs.
Especially we will outline the usage of build systems to automate this process,
in particular ``make`` and ``meson``.

.. contents::

Compiling and Linking
---------------------

Let's start with a small project, even smaller than your SCF program.
We will have two files, one containing the program and one containing a
module with the actual implementation.

.. code-block:: fortran
   :linenos:
   :caption: main.f90

   program my_prog
      use impl_mod
      implicit none
      call prog
   end program my_prog

.. code-block:: fortran
   :linenos:
   :caption: impl.f90

   module impl_mod
      use, intrinsic :: iso_fortran_env, only : output_unit
      implicit none
   contains
   subroutine prog
      write(output_unit, '(a)') "This is a simple program build from two files"
   end subroutine prog
   end module impl_mod

To build the program we can just use

.. code-block:: none

   gfortran -o my_prog main.f90 impl.f90

.. note::

   We always want to start a new build process from a clean source directory
   in this introduction.
   If you have used the above command, remove the program ``my_prog`` and the
   generated ``impl_mod.mod``.

Now imagine this is a program with several files, maybe even several hundred
files, with a total of several thousand lines, compiling it that way would
take a while, even if we only changed parts of the code.
The reason to separate the code in multiple files in the first place is
to build them separately to save compile time.

After looking up the compiler manual (``man gfortran``) we find that the
``-c`` flag can translate a source file to an object file.
So we try to translate the first file with

.. code-block:: none

   gfortran -c -o main.f90.o main.f90

which results in the following error:

.. code-block:: none

   main.f90:2:7:

       2 |    use impl_mod
         |       1
   Fatal Error: Cannot open module file ‘impl_mod.mod’ for reading at (1): No such file or directory
   compilation terminated

This certainly makes sense, we cannot compile ``main.f90`` before we have
compiled ``impl.f90`` where the module is defined, otherwise it is impossible
to import the module.

So we try again, this time starting with ``impl.f90``:

.. code-block:: none

   gfortran -c -o impl.f90.o impl.f90
   gfortran -c -o main.f90.o main.f90
   gfortran -o my_prog main.f90.o impl.f90.o

The first two steps *compile* our source code to object files, which can be
*linked* to program in the third step. With this separation can selectively
recompile object files when we change a source file and only have to repeat
the linking step, but not the complete compilation process.
Note that we generated *four* files, if you check with ``ls`` you find

.. code-block:: none

   impl.f90  impl.f90.o  impl_mod.mod  main.f90  main.f90.o  my_prog

The ``impl_mod.mod`` contains the module information needed to compile
``main.f90``.
While this works okay for small projects, it quickly becomes cumbersome and
error-prone in larger projects, therefore we will look into a way to
automate such a build process.

.. note:: Remove all the build artifacts from your source directory again
          before continuing.

Make
----

The most well-known and commonly used build system is called ``make``.
It performs actions following rules defined in a configuration file
called ``Makefile`` or ``makefile``, which usually leads to compiling a program
from the provided source code.

.. tip::

   For an in-depth ``make`` tutorial lookup its info page (``info make``).
   Unfortunately, most Linux distributions show the manual page there instead
   of the info page, which is a pity, but there is an online version of the
   `info page`_.

   .. _info page: https://www.gnu.org/software/make/manual/make.html

We will start with the basics from your clean source directory. Create and open
the file ``makefile``, we start with a simple rule called *all*:

.. code-block:: make
   :linenos:

   all:
   	echo "$@"

After saving the ``makefile`` run it by executing ``make`` in the same directory.
You should see the following output:

.. code-block:: none

   echo "all"
   all

First, we note that ``make`` is substituting ``$@`` for the name of the rule,
the second thing to note is that ``make`` is always printing the command it is
running, finally, we see the result of running ``echo "all"``.

.. note::

   We call the entry point of our ``makefile`` always *all* by convention,
   but you can choose whatever name you like.

   You should not have noticed it if your editor is working correctly,
   but you have to indent the content of a rule with a tab character.
   In case you have problems running the above ``makefile`` check
   for the tab character in line two.

Now we want to make our rules more complicated, therefore we add another rule:

.. code-block:: make
   :linenos:

   PROG := my_prog

   all: $(PROG)
   	echo "$@ depends on $^"

   $(PROG):
   	echo "$@"

Note how we declare variables in ``make``, you should always declare your local
variables with ``:=``. To access the content of a variable we use the ``$(...)``,
note that we have to enclose the variable name in parenthesis.
We introduced a dependency of the rule all, namely the content of the variable
``PROG``, also we modified the printout, we want to see all the dependencies
of this rule, which are stored in the variable ``$^``.
Now for the new rule which we name after the value of the variable ``PROG``,
it does the same thing we did before for the rule *all*, note how the value
of ``$@`` is dependent on the rule it is used in.

Again check by running the ``make``, you should see:

.. code-block:: none

   echo "my_prog"
   my_prog
   echo "all depends on my_prog"
   all depends on my_prog

The dependency has been correctly resolved and evaluated before performing
any action on the rule *all*.
Let's run only the second rule: type ``make my_prog`` and you will only find
the first two lines in your terminal.

The next step is to perform some real actions with ``make``, we take
the source code from the previous chapter here and add new rules to our
``makefile``:

.. code-block:: make
   :linenos:

   OBJS := main.o impl.o
   PROG := my_prog

   all: $(PROG)

   $(PROG): $(OBJS)
   	gfortran -o $@ $^

   $(OBJS): %.o: %.f90
   	gfortran -c -o $@ $<

We define ``OBJS`` which stands for object files, our program depends on
those ``OBJS`` and for each object file we create a rule to make them from
a source file.
The last rule we introduced is a pattern matching rule, ``%`` is the common
pattern between ``main.o`` and ``main.f90``, which connects our object file
``main.o`` to the source file ``main.f90``.
With this set, we run our compiler, here ``gfortran`` and translate the source
file into an object file, we do not create an executable yet due to the ``-c``
flag.
Note the usage of the ``$<`` for the first element of the dependencies here.

After compiling all the object files we attempt to link the program, we do not
use a linker directly, but ``gfortran`` to produce the executable.

Now we run the build script with ``make``:

.. code-block:: none

   gfortran -c -o main.o main.f90
   main.f90:2:7:

       2 |    use impl_mod
         |       1
   Fatal Error: Cannot open module file ‘impl_mod.mod’ for reading at (1): No such file or directory
   compilation terminated.
   make: *** [makefile:10: main.f90.o] Error 1

We remember that we have dependencies between our source files, therefore we add
this dependency explicitly to the ``makefile`` with

.. code-block:: make

   main.o: impl.o

Now we can retry and find that the build is working correctly. The output should
look like

.. code-block:: none

   gfortran -c -o impl.o impl.f90
   gfortran -c -o main.o main.f90
   gfortran -o my_prog main.o impl.o

You should find *four* new files in the directory now.
Run ``my_prog`` to make sure everything works as expected.
Let's run ``make`` again:

.. code-block:: none

   make: Nothing to be done for 'all'.

Using the timestamps of the executable ``make`` was able to determine, it is
newer than both ``main.o`` and ``impl.o``, which in turn are newer than
``main.f90`` and ``impl.f90``.
Therefore, the program is already up-to-date with the latest code and no
action has to be performed.

In the end, we will have a look at a complete ``makefile``.

.. code-block:: make
   :linenos:

   MAKEFLAGS += --no-builtin-rules --no-builtin-variables
   # configuration
   FC := gfortran
   LD := $(FC)
   RM := rm -f
   # source
   SRCS := main.f90 impl.f90
   PROG := my_prog

   OBJS := $(addsuffix .o, $(SRCS))

   .PHONY: all clean
   all: $(PROG)

   $(PROG): $(OBJS)
   	$(LD) -o $@ $^

   $(OBJS): %.o: %
   	$(FC) -c -o $@ $<

   main.f90.o: impl.f90.o

   clean:
   	$(RM) $(filter %.o, $(OBJS)) $(wildcard *.mod) $(PROG)

Since you are starting with ``make`` we highly recommend to always include
the first line, like with Fortrans ``implicit none`` we do not want to have
implicit rules messing up our ``makefile`` in surprising and harmful ways.

Next, we have a configuration section where we define variables, in case you
want to switch out your compiler, it can be easily done here.
We also introduced the ``SRCS`` variable to hold all source files, which is
more intuitive than specifying object files, we can easily create the object
files by appending a ``.o`` suffix using the function ``addsuffix``.
The ``.PHONY`` is a special rule, which should be used for all entry points
of your ``makefile``, here we define two entry point, we already know *all*,
the new *clean* rule deletes all the build artifacts again such that we indeed
start with a clean directory.

Also, we slightly changed the build rule for the object files to account for
appending the ``.o`` suffix instead of substituting it.

Now you know enough about ``make`` to use it for building small projects.

.. important::

   You might have noticed that ``make`` is not particularly easy to use and
   it can be from time to time difficult to understand what is going
   on under the hood.
   In this guide, we avoided and disabled a lot of the commonly used ``make``
   features that can be particularly troublesome if not used correctly, we highly
   recommend staying away from them if you do not feel confident working with
   ``make``.

   While ``make`` is indeed a handy tool to automate short interdependent
   workflows and to build small projects, it should *never* be used to build
   larger projects, like quantum chemistry programs.
   In particular modern Fortran programs can hardly be handled by a ``make``
   build system.

Meson
-----

After you have learned the basics of ``make``, which we call a low-level build
system, we will introduce ``meson``, a high-level build system.
While you specify in a low-level build system how to build your program,
you can use a high-level build system to specify what to build.
A high-level build system will deal for you with how and generate
build files for a low-level build system.

There are plenty of high-level build systems available, but we will focus on
``meson`` because it is constructed to be particularly user friendly.
The default low-level build-system of ``meson`` is called ``ninja``.

Let's have a look at a complete ``meson.build`` file:

.. code-block:: meson
   :linenos:

   project('my_proj', 'fortran', meson_version: '>=0.49')
   executable('my_prog', files('main.f90', 'impl.f90'))

And we are already done, the next step is to configure our low-level build system
with ``meson setup build``, you should see output somewhat similar to this

.. code-block:: none

   The Meson build system
   Version: 0.53.2
   Source dir: /home/awvwgk/Lehre/QC2/test
   Build dir: /home/awvwgk/Lehre/QC2/test
   Build type: native build
   Project name: my_proj
   Project version: undefined
   Fortran compiler for the host machine: gfortran (gcc 9.2.1 "GNU Fortran (Arch Linux 9.2.1+20200130-2) 9.2.1 20200130")
   Fortran linker for the host machine: gfortran ld.bfd 2.34
   Host machine cpu family: x86_64
   Host machine cpu: x86_64
   Build targets in project: 1

   Found ninja-1.10.0 at /usr/bin/ninja

The provided information at this point is already more detailed than anything
we could have provided in a ``makefile``, let's run the build with
``ninja -C build``, which should show something like

.. code-block:: none

   [1/4] Compiling Fortran object 'my_prog@exe/impl.f90.o'.
   [2/4] Dep hack
   [3/4] Compiling Fortran object 'my_prog@exe/main.f90.o'.
   [4/4] Linking target my_prog.

Find and test your program at ``build/my_prog`` to ensure it works correctly.
We note the steps ``ninja`` performed are the same we would have coded up in a
``makefile`` (including the dependency), yet we did not have to specify them,
have a look at your ``meson.build`` file again:

.. code-block:: meson
   :linenos:

   project('my_proj', 'fortran', meson_version: '>=0.49')
   executable('my_prog', files('main.f90', 'impl.f90'))

We only specified that we have a Fortran project (which happens to require
a certain version of ``meson`` for the Fortran support) and told ``meson``
to build an executable ``my_prog`` from the files ``main.f90`` and ``impl.f90``.
We had not to tell ``meson`` how to build the project, it figured this out
by itself.

.. note::

   The documentation of ``meson`` can be found at the `meson-build webpage`_.

   .. _meson-build webpage: https://mesonbuild.com/
