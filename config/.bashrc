# >>> QC2 >>>
# !! Contents within this block is provided by your lab assistents !!

# Make environment modules available
export BASH_ENV=/usr/share/lmod/lmod/init/bash
. ${BASH_ENV} > /dev/null

module use /home/abt-grimme/modulefiles
module load turbomole orca
module load fpm

# Add AKbin and personal bin to PATH (for utility and programs)
export PATH=/home/abt-grimme/AK-bin:$PATH
export PATH=/home/$USER/bin:$PATH

# Settings for shared memory parallelism
export OMP_NUM_THREADS=2
export MKL_NUM_THREADS=2
export OMP_STACKSIZE=500m

# Unlimit the system stack to prevent stackoverflows
ulimit -s unlimited
# <<< QC2 <<<
