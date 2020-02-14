Programming
===========

General principles
------------------

Programming is the art of telling a computer what to do, usually to perform
an action or solve a problem which would be too difficult or laborious to do
by hand.
It thus involves the following steps:

 1. Understanding the problem.
 2. Formulating an approach/algorithm to the problem.
 3. Translating the algorithm into a computer--compatible language: *Coding*
 4. Compiling and running the program.
 5. Analyzing the result and improving the program if necessary or desired.

This manual assumes that steps 1 and 2 have already been taken care of in
the Quantum Chemistry I module.
We will thus concern ourselves with the problems of translating an algorithm
or a formula, spelled out on paper, to something the computer understands first.

Compiling and running a program
-------------------------------

Before beginning to write computer code, or *to code* in short, one needs to
choose a programming language.
Many of them exist: some are general, some are specifically designed for a task,
e.g. web site design or piloting a plane, some have simple data structures,
some have very special data structures like census data, some are rather new
and follow very modern principles, some have a long history and thus rely
on time-tested concepts.

In the case of this module, the Fortran language was chosen because it still
is in frequent use in the field of quantum chemistry and scientific computing
in general. It also makes for code that is rather rapidly written. The name
Fortran is derived from Formula Translation
and indicates that the language is designed for the task at hand, translating
scientific equations into computer code.

Let's take a look at a complete Fortran program.

.. code-block:: fortran
   :caption: hello.f90
   :linenos:

   program hello
   write(*,*) "This is probably the simplest Fortran program"
   end program hello

If you were to execute this program, it would simply display its message and
exit.

.. admonition:: Exercise 1

   Open a new file in ``atom`` and save as ``hello.f90`` in a new directory
   in your project directory, you will always create a new directory for
   each exercise.

   Type in the program above. Fortran is case-insensitive, *i.e.* it mostly
   does not care about capitalization. Save the code to a file named
   ``hello.f90``.
   All files written in the Fortran format must have the ``.f90`` extension.

   Next, you will check that the file you created is where you need it,
   translate your program using the compiler ``gfortran`` to machine code.
   The resulting binary file can be executed, thus usually called executable.

   .. code-block:: bash

      gfortran hello.f90 -o helloprog
      ./helloprog
       This is probably the simplest Fortran program.

   Directly after the ``gfortran`` command, you find the input file name.
   The ``-o`` flag allows you to name your program.
   Try to leave out the ``-o helloprog`` part and translate ``hello.f90`` again
   with ``gfortran``. You will find that the default name for your executable
   is ``a.out``. They should produce the same output.

Now that we can translate our program, we should check what it needs
to create an excutable, create an empty file ``empty.f90`` and try to translate
it with ``gfortran``.

.. code-block:: bash
   :emphasize-lines: 3

   gfortran empty.f90
   /usr/bin/ld: /usr/lib/Scrt1.o: in function ``_start':
   (.text+0x24): undefined reference to ``main'
   collect2: error: ld returned 1 exit status

This did not work as expected, ``gfortran`` tells you that your program is
missing a *main* which it was about to *start*. The main program
in Fortran is indicated by the ``program`` statement, which is not present
in the empty file we gave to ``gfortran``.

.. tip:: Important note about errors

   Errors are not necessarily a bad thing, most of the programs you will
   use in this course will return useful error messages that will help
   you to learn about the underlying mechanisms and syntax.

   **Just consider it as an error driven development technique!**

Let us reexamine the code in ``hello.f90``,
The first line is the *declaration section* which starts the main program
and gives it an arbitrary name.
The third line is the *termination section* which stop the execution of
the program again and tells the compiler that we are done.
The name used in this section has to match the *declaration section*.

Everything in between is the *execution section*, each statement in this
section is executed when calling the translated program.
We use the ``write(*,*)`` statement which causes the program to display
whatever is behind it until the end of the line.
The double quotes enclosing the sentence make the program recognize that
the following characters are just that, *i.e.*, a sequence of characters
(called a string) and not programming directives or variables.

Introducing Variables
---------------------

The string we have printed in our program was a character constant,
thus we are not able to manipulate it.
Variables are used to store and manipulate data in our programs,
to *declare* variables we extend the *declaration section* of our program.
We can use variables similar to the ones used in math in that they can have
different values. Within Fortran, they cannot be used as *unknowns* in an
equation; only in an assignment.

In Fortran we need to declare the type of every variable explicitly,
this means that a variable is given a specific and unchanging data type
like ``character``, ``integer`` or ``real``.
For example we could write

.. code-block:: fortran
   :caption: numbers.f90
   :linenos:

   program numbers
   implicit none
   integer :: my_number
   my_number = 42
   write(*,*) "My number is", my_number
   end program numbers

Now the *declaration section* of our program is line 1-3, the second line
declares that we want to declare all our variables explicitly.
Implicit typing is a leftover from the earliest version of Fortran
and should be avoided at all cost, therefore you will but the line
``implicit none`` in every declaration you write from now on.
The third line declares the variable ``my_number`` as type ``integer``.

Line 4 and 5 are the *executable section* of the program, first we assign
a value to ``my_number``, than we are printing it to the screen.

.. admonition:: Exercise 2

   Make a new directory and save create the file ``numbers.f90`` where
   you type in the above program. Than translate it with ``gfortran``
   with

   .. code-block:: bash

      gfortran numbers.f90 -o numbers_prog
      ./numbers_prog
       My number is          42

   Despite being a bit oddly formatted the program correctly returned the
   number we have written in ``numbers.f90``.
   ``numbers_prog`` will now always return the same number, to make
   the program really useful, we have to want to have the program
   *read* in our number.

   Use the ``read(*,*)`` statement to provide the number to the program,
   which works similar to the ``write(*,*)`` statement.

.. admonition:: Solutions 2

   We replace the assignment in line 4 with the ``read(*,*) my_number``
   and than translate it to a program.

   .. code-block:: bash

      gfortran numbers.f90 -o numbers_prog
      ./numbers_prog
      31
       My number is          31

   If you now execute ``numbers_prog`` the shell apparently freezes.
   We are now exactly at the read statement and the ``numbers_prog`` is waiting
   for your action, so go ahead and type a number.

   You might be tempted to type something like ``four``:

   .. code-block:: none
      :emphasize-lines: 4

      ./numbers_prog
      four
      At line 4 of file numbers.f90 (unit = 5, file = 'stdin')
      Fortran runtime error: Bad integer for item 1 in list input

      Error termination. Backtrace:
      #0  0x7efe31de5e1b in read_integer
         at /build/gcc/src/gcc/libgfortran/io/list_read.c:1099
      #1  0x7efe31de8e29 in list_formatted_read_scalar
         at /build/gcc/src/gcc/libgfortran/io/list_read.c:2171
      #2  0x7efe31def535 in wrap_scalar_transfer
         at /build/gcc/src/gcc/libgfortran/io/transfer.c:2369
      #3  0x7efe31def535 in wrap_scalar_transfer
         at /build/gcc/src/gcc/libgfortran/io/transfer.c:2346
      #4  0x56338a59f23b in ???
      #5  0x56338a59f31a in ???
      #6  0x7efe31867ee2 in ???
      #7  0x56338a59f0fd in ???
      #8  0xffffffffffffffff in ???

   So we got an error here, the program is printing a lot cryptic information,
   but the most useful lines are near to our input of ``four``.
   We have produced an error at the runtime of our Fortran program,
   therefore it is called a runtime error, more precise we have given
   a bad integer value for the first item in the list input at line 4
   in ``numbers.f90``.
   That was very verbose, Fortran expected an ``integer``,
   but we passed a ``character`` to our read statement for ``my_number``.

   We could try to make our program more verbose by adding some information
   on what kind of input we expect to avoid this sort of errors.
   A possible solution would look like

   .. code-block:: fortran
      :caption: numbers.f90
      :linenos:

      program numbers
      implicit none
      integer :: my_number
      write(*,*) "Enter an integer value"
      read(*,*) my_number
      write(*,*) "My number is", my_number
      end program numbers

   While this will not prevent wrong input it will make it more unlikely
   by clearly communicating with the user of the program what we are
   expecting.

Performing simple computing tasks
---------------------------------

Next, you will make your program perform simple computational tasks -- in this
case, add two numbers.

So let's examine the following code:

.. code-block:: fortran
   :caption: add.f90
   :linenos:

   program add
     implicit none
     ! declare variables: integers
     integer :: a, b
     integer :: res

     ! get two values to be stored in a and b
     read(*,*) a, b

     res = a + b  ! perform the addition

     write(*,*) "The result is", res
   end program add

Again we declare our program and give it a useful name describing the task at
hand. The second statement is used to explicitly declare all variables and
will be present in any program we write from now on.

The third line is a comment, any text after the exclamation mark is considered
to be a comment in Fortran and is ignored by the compiler.
Since it does not affect the final program we can use comments to remind
ourselves why we choose to do something particular, the intent of the statement
or to describe the what the program is doing.
At the beginning you should comment your code as much as possible such that
you will still understand them in a year from new. It is completely fine
to produce more comment lines than lines of code to keep your program
understandable.
Also notice that Fortran does not care much about leading spaces (indentation)
or empty lines, so we can use them to give our code a visual structure,
which makes it more appealing and easier to read.

The comment states that we will declare our variables as integers,
we have two integer declarations here, once for ``a`` and ``b``, comma-separated
on the same line and on the next line an integer declaration for ``res``.
We could put ``a, b, res`` on one line, but we might want to separate our
input and result variables visually.

The next statement is in line 8 in the *executable section* of the code
and reads values into ``a`` and ``b``. Afterwards we perform the addition ``a + b``
and assign the result to ``res``. Finally we print the result and exit the
program again.

.. admonition:: Excercise 3

    Create the file ``add.f90`` from the manual and modify it to make it do the
    following and check

     1. Display a message to the user of your program (*via* write statements)
        about what kind of input is to be entered by them.

     2. Read values from the console into the variables ``a`` and ``b``,
        which are then *multiplied* and printed out.
        For error checking, print out the values ``a`` and ``b`` in the course
        of your program.

     3. What happens if you provide input like ``3.14``?

     3. Perform a division instead of a multiplication.
        Attempt to obtain a fraction.

.. admonition:: Solutions 3

   As before we add a line like ``write(*,*) "Enter two numbers to add"``
   before the read statement. We can do something similar like in numbers
   for both ``a`` and ``b`` to echo their values, the resulting shell history
   should look similar to this

   .. code-block:: bash

      gfortran add -o add_prog
      ./add_prog
       Enter two numbers to add
      11 31
       The value of a is          11
       The value of b is          31
       The result is          42
      ./add_prog
       Enter two numbers to add
      -8
      298
       The value of a is          -8
       The value of b is         298
       The result is         290

   The input seems to be quite forgiving and we can also add negative numbers.
   While this sounds obvious it is a common pitfall in other languages,
   but in Fortran all integers are signed and there is no unsigned version
   like in C.

   To change the arithmetic operation in our code we have to know the
   operator used in Fortran to perform anything beyond addition.
   We can use ``+`` for addition, ``-`` for subtraction, ``*`` for multiplication,
   ``/`` for division and ``**`` exponentiation.

   We will skip the resulting output of the multiplication, except for one
   interesting case (you should have created a new file and a new program
   for the multiplication, since there is nothing worse than a program called
   ``add_prog`` performing multiplications).

   .. code-block:: bash

      ./multiply_prog
       Enter two numbers to multiply
      1000000 1000000
       The value of a is     1000000
       The value of b is     1000000
       The result is  -727379968

   which is kind of surprising. Take a piece of paper or perform the
   multiplication in your head, you will probably something pretty close
   to 1,000,000,000,000 instead of -727,379,968, but the computer is not
   as smart as you.
   We choose the default kind of the ``integer`` data types
   which uses 32 bits (4 bytes) to represent whole numbers in a range
   from -2,147,483,648 to +2,147,483,648 (2^31^) using two's complement
   arithmetic, since the expected result is clearly to large to be represented
   with only 32 bits (4 bytes), the result is truncated and the sign bit is left
   toggled which results in a large negative number (which is called
   an integer overflow, to understand why that actually makes sense look up
   two's complement arithmetic).

   Usually you do not have to worry about exceeding the 32 bits (4 bytes)
   of precision since we have data types that can represent such large numbers
   in a better way.

   Finally think carefully about the result you expect when performing
   division with integers. Test your hypothesis with your division program.
   Note for yourself what to expect when trying to obtain fractions from
   integers.

Accuracy of Numbers
-------------------

We already noted in the last exercise that we can create number not
representable by integers like very large number or decimal number,
therefore we have to resort to real numbers declared by the
``real`` data type.

Let us consider the following program using ``real`` variables

.. code-block:: fortran
   :caption: accuracy.f90
   :linenos:

   program accuracy
     implicit none

     real :: a, b, c

     a = 1.0
     b = 6.0
     c = a / b

     write(*,*) 'a is', a
     write(*,*) 'b is', b
     write(*,*) 'c is', c

   end program accuracy

We translate ``accuracy.f90`` to an executable and run it to find that
it is not that accurate

.. code-block:: none

   gfortran accuracy.f90 -o accuracy_test
   ./accuracy.test
    a is   1.00000000
    b is   6.00000000
    c is  0.166666672

Similar to our integer arithmetic test, real (floating point) arithmetic has
also limitation. The default representation uses 32 bits (4 bytes) to represent
the floating point number, which results in 6 significant digits, before
the result starts to differ from what we would expect, by doing the calculation
on a piece of paper or in our head.

Now consider the following program

.. code-block:: fortran
   :caption: kinds.f90
   :linenos:

   program kinds
     implicit none
     intrinsic :: selected_real_kind
     integer :: single, double
     single = selected_real_kind(6)
     double = selected_real_kind(15)
     write(*,*) "For 6 significant digits", single, "bytes are required"
     write(*,*) "For 15 significant digits", double, "bytes are required"
   end program kinds

The ``intrinsic :: selected_real_kinds`` declares that we are using
a build-in function from the Fortran compiler. This one returns the kind
of ``real`` we need to represent a floating point number with the
specified significant digits.

.. admonition:: Exercise 4

   1. create a file ``kinds.f90`` and run it to determine the necessary
      kind of your floating point variables.
   2. use the syntax ``real(kind) ::`` to modify ``accuracy.f90``
      to employ what we call double precision floating point numbers.
      Replace kind with the number you determined in ``kinds.f90``.

.. admonition:: Solutions 4

   The output of the second write statement should be ``8`` on most machines.

   But instead of hardcoding our wanted precision we combine ``kinds.f90`` and
   ``accuracy.f90`` in the final program version.

   .. code-block:: fortran
      :caption: accuracy.f90
      :linenos:

      program accuracy
        implicit none

        intrinsic :: selected_real_kind
        ! kind parameter for real variables
        integer, parameter :: wp = selected_real_kind(15)
        real(wp) :: a, b, c

        ! also use the kind parameter here
        a = 1.0_wp
        b = 6.0_wp
        c = a / b

        write(*,*) 'a is', a
        write(*,*) 'b is', b
        write(*,*) 'c is', c

      end program accuracy

   If we now translate ``accuracy.f90`` we find that the output changed,
   we got more digits printed and also a more accurate, but still
   not perfect result

   .. code-block:: none

      gfortran accuracy.f90 -o accuracy_test
      ./accuracy.test
       a is   1.00000000000000
       b is   6.00000000000000
       c is  0.166666666666667

   It is important to notice here that we cannot get the same result
   we would evaulate on a piece of paper, since the precision is still
   limited by the representation of the number.

   Finally we want to highlight line 6 in ``accuracy``, the ``parameter``
   attached to data type (here ``integer``) is used to declare
   variables that are constant and unchangable through the course of our
   program, more important, their value is known (by the compiler) while
   translating the program. This gives us the possibility to assign
   meaningful and easy to remembeer names to important values.

There is one more issue we have to discuss, look at the following
program which does apprently the same calculation as ``accuracy.f90``,
but with different kinds of literals.

.. code-block:: fortran
   :caption: literals.f90
   :linenos:

   program literals
     implicit none

     intrinsic :: selected_real_kind
     ! kind parameter for real variables
     integer, parameter :: wp = selected_real_kind(15)
     real(wp) :: a, b, c

     a = 1.0_wp / 6.0_wp
     b =    1.0 / 6.0
     c =      1 / 6

     write(*,*) 'a is', a
     write(*,*) 'b is', b
     write(*,*) 'c is', c

   end program literals

If we run the program now we find surprisingly that only ``a`` has the expected
value, while all other are off. We can easily explain the result for ``c``,
the actual calculation is happening in integer arithmetic which yields 0
and is than _casted_ into a real number ``0.0``.

.. code-block:: none

   ./literals_prog
    a is  0.16666666666666666
    b is  0.16666667163372040
    c is  0.00000000000000000

But what happens in case of ``b``, we perform the calculation with ``1.0/6.0``,
but those are real number from the default type represented in 32 bits
(4 bytes) and than, as we store the result in ``b``, _casted_ into a
real number represented in 64 bits (8 bytes).

.. important:: **Always specify the kind parameters in floating point literals!**

Here we introduce the concept of _casting_ one data type to another,
whenever a variable is assigned a different data type, the compiler has
to convert it first, which is called _casting_.

.. admonition:: Possible Errors

   You might ask what happens if we leave out the ``parameter``
   attribute in line 6, let's try it out:

   .. code-block:: fortran
      :caption: accuracy.f90
      :linenos:

      program accuracy
        implicit none

        intrinsic :: selected_real_kind
        ! kind parameter for real variables
        integer :: wp = selected_real_kind(15)
        real(wp) :: a, b, c

        ! also use the kind parameter here
        a = 1.0_wp
        b = 6.0_wp
        c = a / b

        write(*,*) 'a is', a
        write(*,*) 'b is', b
        write(*,*) 'c is', c

      end program accuracy

   ``gfortran`` complains about errors in the source code, pointing you at
   line 7, with several errors following, as usual the first error is the
   interesting one:

   .. code-block:: none
      :emphasize-lines: 6

      gfortran accuracy.f90
      accuracy.f90:7:7:

          7 |   real(wp) :: a, b, c
            |       1
      Error: Parameter ‘wp’ at (1) has not been declared or is a variable, which does not reduce to a constant expression
      accuracy.f90:10:12:

         10 |   a = 1.0_wp
            |            1
      Error: Missing kind-parameter at (1)
      ...

   There we find the solution to our problem in plain text, the parameter ``wp``,
   which is not a parameter in our program, is either not declared (it is)
   or it is a variable.
   ``gfortran`` expects a ``parameter`` here, but we passed a variable.
   All other errors result from either the missing ``parameter``
   attribute or that ``gfortran`` could not translate line 7 due to the first
   error.

   Therefore, always check for the first error that occurs.

   You could also ask how important line 4 with ``intrinsic ::`` is for
   our program. In fact you *could* leave it out completly (try it!),
   but we will always declare all the intrinsic functions we are using
   here such that you know they are, indeed, intrinsic functions.

Logical constructs
------------------

Our programs so far had one line of execution.
Logic is very fundamental for controlling the execution flow of a program,
usually you evaluate logical expression directly in the corresponding
``if`` construct to decide which branch to take or save it to
a ``logical`` variable.

Now we want to solve for the roots of the quadratic equation
:math:`x^2 + px + q = 0`, we know that we can easily solve it by

.. math::
   x = -\frac{p}{2} \pm \sqrt{\frac{p^2}{4} - c}

but we have to consider different cases for the number of roots we obtain
from this equation (or we use ``complex`` numbers).
We have to be able to evaluate conditions and create branches dependent
on the conditions for our code to evaluate.
Check out the following program to find roots

.. code-block:: fortran
   :caption: roots.f90
   :linenos:

   program roots
     implicit none
     ! sqrt is the square root and abs is the absolute value
     intrinsic :: selected_real_kind, sqrt, abs
     integer, parameter :: wp = selected_real_kind(15)
     real(wp) :: p, q
     real(wp) :: d

     ! request user input
     write(*,*) "Solving x² + p·x + q = 0, please enter p and q"
     read(*,*) p, q
     d = 0.25_wp * p**2 - q
     ! descriminant is positive, we have two real roots
     if (d > 0.0_wp) then
       write(*,*) "x1 =", -0.5_wp * p + sqrt(d)
       write(*,*) "x2 =", -0.5_wp * p - sqrt(d)
     ! descriminant is negative, we have two complex roots
     else if (d < 0.0_wp) then
       write(*,*) "x1 =", -0.5_wp * p, "+ i ·", sqrt(abs(d))
       write(*,*) "x2 =", -0.5_wp * p, "- i ·", sqrt(abs(d))
     else  ! descriminant is zero, we have only one root
       write(*,*) "x1 = x2 =", -0.5_wp * p
     endif
   end program roots

.. admonition:: Excercise 5

    1. check the conditions for simple cases, start by setting up quadradic
       equations with known roots and compare your results against the
       program.

    2. Extend the program to solve the equation: :math:`ax^2 + bx + c = 0`.

Fortran offers also a ``logical`` data type, the literal logical
values are ``.true.`` and ``.false.`` (notice the dots
enclosing true and false values).

.. note::

    Programmer coming from C or C++ may find it unintuitive that Fortran
    stores a ``logical`` in 32 bits (4 bytes) similar to an
    ``integer`` and that true and false are not literally 1 and 0.

You already saw two operators, greater than ``>`` and lesser than ``<``,
for a complete list of all operators see the following table.
They always come in two version but have the same meaning.

=============  =======   ========  ======================================
Operation      symbol    .op.      example (var is ``integer``)
=============  =======   ========  ======================================
equals         ``==``    ``.eq.``  ``var == 1``,  ``var.eq.1``
not equals     ``/=``    ``.ne.``  ``var /= 5``,  ``var.ne.5``
greater than   ``>``     ``.gt.``  ``var > 0``,   ``var.gt.0``
greater equal  ``>=``    ``.ge.``  ``var >= 10``, ``var.ge.10``
lesser than    ``<``     ``.lt.``  ``var < 3``,   ``var.lt.3``
lesser equal   ``<=``    ``.ge.``  ``var <= 8``,  ``var.le.8``
=============  =======   ========  ======================================

.. note::

   You cannot compare two logical expressions with each other using the operators
   above, but this is usually not necessary.
   If you find yourself comparing two logical expressions with each other,
   rethink the logic in your program first, most of the time is just some
   superfluous constuct.
   If you are sure that it is really necessary, use ``.eqv.`` and ``.neqv.``
   for the task.

To negate a logical expression we use prepend ``.not.`` to the expression
and to test multiple expressions we can use ``.or.`` and ``.and.``
which have the same meaning as their equivalant operators in logic.

.. code-block:: fortran
   :caption: logic.f90
   :linenos:

   program logic
     implicit none
     !! TODO !!
   end program logic

Repeating tasks
---------------

Consider this simple program for summing up its input

.. code-block:: fortran
   :caption: loop.f90
   :linenos:

   program loop
     implicit none
     integer :: i
     integer :: number
     ! initialize
     number = 0
     do
       read(*,*) i
       if (i <= 0) then
         exit
       else
         number = number + i
       end if
     end do
     write(*,*) "Sum of all input", number
   end program loop

Here we introduce a new construct called ``do``-loop.
The content enclosed in the ``do/end do`` block will be repeated until
the ``exit`` statement is reached.
Here we are continue summing up as long as we are getting positive integer
values (coded in its negated form as exit if the user input is lesser than
or equal to zero).

.. admonition:: Exercise 6

    1. there is no reason to limit us to positive values, modify the program
       such that it also takes negative values and breaks at zero.

.. admonition:: Solutions 6

   You might have tried to exchange the condition for ``i = 0``, but since
   the equal sign is reserved for the assignment ``gfortran`` will throw
   an error like this one

   .. code-block:: none
      :emphasize-lines: 6
     
      gfortran loop.f90
      loop.f90:9:10:

          9 |     if (i = 0) then
            |          1
      Error: Syntax error in IF-expression at (1)
      loop.f90:11:8:

         11 |     else
            |        1
      Error: Unexpected ELSE statement at (1)
      loop.f90:13:7:

         13 |     end if
            |       1
      Error: Expecting END DO statement at (1)

   It is a common pitfall in other programming languages to confuse
   the assignment operator with the equal operator, which are fundamentally
   different. While it is syntactically correct in C to use an assignment
   in a conditional statement, the resulting code is often in error.
   In Fortran the assignment does not return a value (unlike in C),
   therefore the code is logically and syntactically wrong.
   We are better off using the correct ``==`` or ``.eq.`` operator here.

.. note::

   Programmers coming from almost any language might find it confusing
   to start counting at 1. It was adopted as default choice because it
   is the natural choice (for non-programmers at least), but Fortran
   does not limit you there, there are scenarios where counting from
   -l to +l is the better choice, *i.e.* for orbital angular momenta.

   You can also start counting from 0, but please keep in mind that
   most people also find it unintuitive to start counting from 0.


Character Constants and Variables
---------------------------------

The ``character`` data type consists of strings of alphanumeric characters.
You have already used *character constants*, which are strings of characters
enclosed in single (``'``) or double (``"``) quotes, like in your very first
Fortran program. The minimum number of characters in a string is 0.

.. code-block:: fortran
   :linenos:

   write(*,*) "This is a valid character constant!"
   write(*,*) '3.1415936' ! not a number
   write(*,*) "{']!=" ! any character can be included, even !

A *character variable* is a variable containing a value of the
``character`` data type:

.. code-block:: fortran
   :linenos:

   character :: single
   character, dimension(20) :: many
   character(len=20) :: fname
   character(len=:), allocatable :: input

- the first variable ``single`` can contain only a single character
- like before one could try to create an array like ``many`` containing many
  characters, but it turns out that this is not really a viable approach
  to deal with characters
- Fortran offers a better way to actually make use of the character data type
  by adding a length to the variable, like its done for ``fname``.
- a more flexible way of declaring your character variables is to use a so
  called *deferred size* character, like ``input``.

To write certain data in a neat way to the screen *format specifiers* can be used,
which are character constants or variables. Consider your addition program from
the beginning of this course:

.. code-block:: fortran
   :linenos:

   program add
     implicit none
     ! declare variables: integers
     integer :: a, b
     integer :: res

     ! assign values
     a = 2
     b = 4

     ! perform calculation
     res = a + b

     write(*,'(a,1x,i0)') 'Program has finished, result is', res
   end program add

Instead of using the asterisk, we now define the *format* for the printout.
The format must always be enclosed in parenthesis and the individual format
specifier must be separated by commas.
Therefore the first format specifier is ``a``, which tells Fortran to print
a character. The second specifier is one space (``1x``), while the last (``i0``)
specifies an integer datatype with automatic width.

The result will look similar to your first run, but now there will only be one
space between the characters and the final result. Of course you can do more:
``/`` is a line break, ``f12.8`` is a 12 characters wide floating point number
printout with 8 decimal places and ``e12.4`` switches to scientific notation
with only 4 decimal places.

Interacting with Files
----------------------

Up to now you only interacted with your Fortran program by standard input and
standard output. For more complex program a complicated input file might be
necessary or the output should be saved for later analysis in a file on disk.
To perform this task you need to open and close your files.

.. code-block:: fortran
   :linenos:

   program files
     implicit none
     integer :: io
     integer :: ndim
     real(8) :: var1, var2
     open(file='name.inp', newunit=io)
     read(io,*) ndim, var1, var2
     close(io)
     ! do some computation
     open(file='name.out', newunit=io)
     write(io,'(i0)') ndim
     write(io,'(2f14.8)') var1, var2
     close(io)
   end program files

You see that you can interact with your files like with the standard input or output, but instead of the asterisk you need to give each file a number.
Fortunately you do not have to keep track on the numbers used, as Fortran will
do this automatically for you. Of course you can check the value of ``io`` after
opening a file and will find that it is just a (negative) number used to identify
the file opened.

