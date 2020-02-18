#!/usr/bin/env bash

# stop on errors
set -eu

# put the name of your program here
program=echo
# unique pattern to find the final energy
pattern='final SCF energy'
# output file for plotting
datafile=plot.dat

# scan distances
start_distance=1.4
last_distance=5.0
step=0.1

read -r -d 'END' input <<EOF
2 2 2
0.0  0.0   0.0  1.0  1
1.20
0.0  0.0  DIST  1.0  1
1.20
END
EOF

tmpinp=temporary.inp
tmpout=temporary.out

# cleanup
[ -f $datafile ] && rm -v $datafile

steps=$(seq $start_distance $step $last_distance | wc -l)
printf "Scanning from %.3f Bohr to %.3f Bohr in %d steps\n" \
   $start_distance $last_distance $steps

for distance in $(seq $start_distance $step $last_distance | sed s/,/./)
do
   # generate the input file
   echo "$input" | sed s/DIST/$distance/ > $tmpinp
   # perform the actual calculation on the input file
   2>&1 $program $tmpinp > $tmpout
   # get the energy from the program output
   energy=$(grep "$pattern" $tmpout | awk '{printf "%f",$(NF)}' | tail -1)
   # if there is no energy to be found, we complain
   if [ -z "$energy" ]
      then
         1>&2 printf "ERROR!\n"
         1>&2 printf "'%s' cannot be found in '%s' output\n" "$pattern" "$program"
         1>&2 printf "please inspect '%s' and '%s'\n" "$tmpinp" "$tmpout"
         exit 1
   fi
   # otherwise we write to the logfile
   printf "Current energy is %.8f Hartree for distance %.3f Bohr\n" \
      $energy $distance
   printf "%8.3f %12.8f\n" $distance $energy >> $datafile
done

# cleanup
[ -f $tmpinp ] && rm $tmpinp
[ -f $tmpout ] && rm $tmpout
