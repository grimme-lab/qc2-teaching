!> This is the actual main program, we provide a wrapper around the code you
!  are writing here, so you can skip parts of the necessary IO.
program main_prog
    !> Include standard Fortran environment for IO
    use iso_fortran_env, only : input_unit, error_unit
    !> We use our own read_argument function to obtain a command line arguments
    use io_tools, only : read_argument
    !> Import the student program
    use scf_main, only : scf_prog

    !> Always declare everything explicitly
    implicit none

    !> Name of the input file
    character(len=:),allocatable :: input_file

    !> Does the provided input file exist
    logical :: exist

    !> Unit for reading the input from
    integer :: io_unit

    !> This code snippet optionally opens a file or allows reading from STDIN
    !> In case of no command line arguments, you read from the STDIN
    if (command_argument_count() == 0) then
        io_unit = input_unit
    else
        !> In case there are command line arguments we obtain the first one
        call read_argument(1, input_file)
        !> Check if the argument corresponds to an existing file
        inquire(file=input_file, exist=exist)
        !> The file does not exist, we will return with a meaningful error message
        if (.not.exist) then
            write(error_unit, '("ERROR:", 1x, a)') &
                & "The input file '"//input_file//"' does not exist"
            error stop 1
        end if
        !> If the file exist, we open it to a new unit an pass it to the scf
        open(file=input_file, newunit=io_unit)
    end if

    !> This is the entry point for the student program
    call scf_prog(io_unit)

    !> If we have opened a file, we have to cleanup now, so we close it again
    if (io_unit /= input_unit) then
        close(io_unit)
    end if

end program main_prog
