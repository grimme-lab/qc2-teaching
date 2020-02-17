.PHONY: all clean
all: $(patsubst %.f90, %, $(sort $(wildcard *.f90))) clean

clean:
	$(RM) *.mod

%: %.f90
	@echo "----- TESTING: $@ -----"
	$(FC) $(FFLAGS) $< -o $@
	@if [ -f $@.txt ]; then ./$@ < $@.txt; else ./$@; fi
	@$(RM) $@
