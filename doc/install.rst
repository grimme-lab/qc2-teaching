Setup Prerequisites
===================

To start with this course, you need the to install necessary programs and
setup your system to allow programming.
Depending on the platform and operating systems you are using the steps
differ but eventually you should be able to use the course material independently
of your platform.

.. contents::

Ubuntu
------

Starting with a fresh version of `Ubuntu 18.04`_ we have to install a few programs
first.
You have to install the packages: ``gfortran``, ``make``, ``atom`` and ``vim``.
We will assume you are working with ``apt`` to install packages, in case you
prefer another package manager, feel free to install the packages listed here
with this one (see `Ubuntu install & remove software`_).

.. _Ubuntu 18.04: http://releases.ubuntu.com/18.04.4/
.. _Ubuntu install & remove software: https://help.ubuntu.com/lts/ubuntu-help/addremove.html

.. code-block:: bash

   sudo apt install gfortran make atom vim

.. note::

   Some packages, especially ``vim`` and ``make`` might already be installed on
   your system, but it does not harm to include them here again.

After having installed the necessary software, you need to download the
`course material`_.
Unzip the ``course-material.zip`` archive to your home directory and
you are setup to start with the next chapter.

.. _course material: https://github.com/grimme-lab/qc2-teaching/releases/latest
