Building Programs
=================

This is a short and concise introduction into building programs.

.. note::

   For this course you only need to remember that with the ``makefile`` we
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

Make
----

The most well-known and commonly used build system is called ``make``.
It performs actions following rules defined in a configuration file usually
called ``Makefile`` or ``makefile``, which usually leads to compiling a program
from provided source code.

.. tip::

   For an in-depth ``make`` tutorial look up its info page (``info make``).
   Unfortunately, most Linux distributions show the manual page there instead
   of the info page, which is a pity, but there is an online version of the
   `info page`_.

   .. _info page: https://www.gnu.org/software/make/manual/make.html

We will start with the basics from an empty directory. Create and open the
file ``makefile``, we start with a simple rule called *all*:

.. code-block:: make
   :linenos:

   all:
   	echo "$@"

After saving the ``makefile`` run it by executing ``make`` in the same directory.
You should see the following output:

.. code-block:: none

   echo "all"
   all

First we note that ``make`` is substituting ``$@`` for the name of the rule,
second thing to note it that ``make`` is always printing the command it is
running, finally we see the result of running ``echo "all"``.

.. note::

   We call the entry point of our ``makefile`` always *all* by convention,
   but you can choose whatever name you like.

   You should not have noticed it, if your editor is working correctly,
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

The next step is to actually perform some real actions with ``make``, take
a code snippet from the previous chapter, for simplicity we will take your
first Fortran program here:

.. literalinclude:: src/hello.1.f90
   :language: fortran
   :caption: hello.f90
   :linenos:

We add new rules to our ``makefile``:

.. code-block:: make
   :linenos:

   OBJS := hello.o
   PROG := my_prog

   all: $(PROG)

   $(PROG): $(OBJS)
   	gfortran -o $@ $^

   $(OBJS): %.o: %.f90
   	gfortran -c -o $@ $<

We define ``OBJS`` which stands for object files, our program depends on
those ``OBJS`` and for each object file we create rule to make them from
a source file.
The last rule we introduced is a pattern matching rule, ``%`` is the common
pattern between ``hello.o`` and ``hello.f90``, which connects our object file
``hello.o`` to the source file ``hello.f90``.
With this set we run our compiler, here ``gfortran`` and translate the source
file into an object file, we do not create an executable yet due to the ``-c``
flag.
Note the usage of the ``$<`` for the first element of the dependencies here.

After compiling all the object files we attempt to link the program, we do not
use a linker directly, but ``gfortran`` to produce the executable.

Now we run the build script with ``make``:

.. code-block:: none

   gfortran -c -o hello.o hello.f90
   gfortran -o my_prog hello.o

You should find two new files in the directory now.
Run ``my_prog`` to make sure everything works as expected.
Let's run ``make`` again:

.. code-block:: none

   make: Nothing to be done for 'all'.

Using the timestamps of the executable ``make`` was able to determine, that
it is newer than ``hello.o``, which in turn is newer than ``hello.f90``.
Therefore, the program is already up-to-date with the latest code and no
action has to be performed.

In the end, we will have a look on a complete ``makefile``.

.. code-block:: make
   :linenos:

   MAKEFLAGS += --no-builtin-rules --no-builtin-variables
   # configuration
   FC := gfortran
   LD := $(FC)
   RM := rm -f
   # source
   SRCS := hello.f90
   PROG := my_prog

   OBJS := $(addsuffix .o, $(SRCS))

   .PHONY: all clean
   all: $(PROG)

   $(PROG): $(OBJS)
   	$(LD) -o $@ $^

   $(OBJS): %.o: %
   	$(FC) -c -o $@ $<

   clean:
   	$(RM) $(filter %.o, $(OBJS)) $(PROG)

Since you are starting with ``make`` we highly recommend to always include
the first line, like with Fortrans ``implicit none`` we do not want to have
implicit rules messing up our ``makefile`` in surprising and harmful ways.

Next we have a configuration section where we define variables, in case you
want to switch out your compiler, it can be easily done here.
We also introduced the ``SRCS`` variable to hold all source files, which is
more intuitive than specifying object files, we can easily create the object
files by appending a ``.o`` suffix using the function ``addsuffix``.
The ``.PHONY`` is a special rule, which should be used for all entry points
of your ``makefile``, here we define two entry point, we already know *all*,
the new *clean* rule deletes all the build artefacts again such that we indeed
start with a clean directory.

Also we slightly changed the build rule for the object files to account for
appending the ``.o`` suffix instead of substituting it.

Now you know enough about ``make`` to use it for building small projects.

.. important::

   You might have noticed that ``make`` is not particular easy to use and
   it can be from time to time difficult to understand what is actually going
   on under the hood.
   In this guide we avoided and disabled a lot of the commonly used ``make``
   features that can be particular troublesome if not used correctly, we highly
   recommend to stay away from them if you do not feel confident working with
   ``make``.

   While ``make`` is indeed a handy tool to automate short interdependent
   workflows and building small projects, it should *never* be used to build
   larger projects, like quantum chemistry programs.
   In particular modern Fortran programs can hardly be handled by a ``make``
   build system.

Meson
-----

After you have learned the basics ``make``, which we call a low-level build
system, we will introduce ``meson`` a high-level build system.
While you specify in a low-level build system how to build your program,
you can use a high-level build system to specify what to build.
A high-level build system will deal for you with the how and generate
build files for a low level build system.

There are plenty high-level build systems available, but we will focus on
``meson`` because it is constructed to be particular user friendly.
The default low-level build-system of ``meson`` is called ``ninja``.

Let's have a look at a complete ``meson.build`` file:

.. code-block:: meson
   :linenos:

   project('my_proj', 'fortran', meson_version: '>=0.49')
   executable('my_prog', sources: files('hello.f90'))

And we are already done, next step is to configure our low-level build system
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

   [1/2] Compiling Fortran object 'my_prog@exe/hello.f90.o'.
   [2/2] Linking target my_prog.

Find and test your program at ``build/my_prog`` to ensure it works correctly.
We note the steps ``ninja`` performed are the same we would have coded up in a
``makefile``, yet we did not have to specify them, have a look at your
``meson.build`` file again:

.. code-block:: meson
   :linenos:

   project('my_proj', 'fortran', meson_version: '>=0.49')
   executable('my_prog', sources: files('hello.f90'))

We only specified we that we have a Fortran project (which happens to require
a certain version of ``meson`` for the Fortran support) and told ``meson``
to build an executable ``my_prog`` from the file ``hello.f90``.
We had not to tell ``meson`` how to build the project, it figured this out
by itself.

.. note::

   The documentation of ``meson`` can be found at the `meson-build webpage`_.

   .. _meson-build webpage: https://mesonbuild.com/
