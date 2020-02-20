# >>> QC2 >>>
# !! Contents within this block is provided by your lab assistents !!
# Add Turbomole to PATH
TURBODIR=/software/turbomole702
PATH=$PATH:$TURBODIR/bin/$(sysname):$TURBODIR/scripts
# Add Orca to PATH
PATH=$PATH:/home/software/orca-4.0.0
# Add local bin and Grimme workgroup bin
PATH=$HOME/bin:$HOME/.local/bin:$PATH:/home/abt-grimme/AK-bin
export PATH TURBODIR
# unlimit the system stack to prevent stackoverflows
ulimit -s unlimited
# <<< QC2 <<<
