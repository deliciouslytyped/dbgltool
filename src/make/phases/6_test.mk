.PHONY: check nix-check
_test-checks: nix-check

###
### Test (check)
###

#TODO check this works the way you think
# We dont want to delete failed test outputs
.PRECIOUS: test/$(testid)/testresults/%-gdb

#nix-check: test/$(testid)/out/hello

#TODO
# check debug info in separateds and nonseparated inputs
# check debug info in outputs
# check that hello is patched properly and gdb has information
test/$(testid)/testresults/debug-separate: test/$(testid)/in/debug-separate
	$(dwarfdump)
	$(readelf)

test/$(testid)/testresults/debug: test/$(testid)/in/debug
	$(dwarfdump) $< &> $@
	$(readelf)

#TODO parametrize this over the library name
#TODO I cant tell why make deletes bin/% and bin/%-ldso-separate when this is done
.PRECIOUS: test/$(testid)/testresults/%
test/$(testid)/testresults/%-ldso-inline-gdb: test/$(testid)/out/bin/%-ldso-inline $(TESTRESULTS_D) $(ex_gdb)
	script $@ -c '$(ex_gdb) -batch $< \
	   -ex "set style enabled on" \
	   -ex "set breakpoint pending on" \
	   -ex "b dl_main" \
	   -ex "set debug separate-debug-file 1" \
	   -ex run \
	   -ex "set listsize 40" \
	   -ex list \
	   -ex quit'

test/$(testid)/testresults/%-ldso-separate-gdb: test/$(testid)/out/bin/%-ldso-separate $(TESTRESULTS_D) $(ex_gdb)
	script $@ -c '$(ex_gdb) -batch $< \
	   -ex "set style enabled on" \
	   -ex "set breakpoint pending on" \
	   -ex "b dl_main" \
	   -ex "set debug separate-debug-file 1" \
	   -ex run \
	   -ex "set listsize 40" \
	   -ex list \
	   -ex quit'

#TODO rename
#note i want relatively light cli but not tui apps (no real reason, just figure it wont break gdb logging
#or something, didnt test, also tui apps usually dont exit by themselves) with the same binary name as
#the package, for convenience 
_test-end: $(foreach,hello acpi fd lshw ,test/$(testid)/testresults/$(file)-ldso-gdb)

##TEST
#readelf -x .gnu_debuglink $ldso
#gdb -q ./hello -ex "set confirm off" -ex "set breakpoint pending on" -ex "b dl_main" -ex "set debug separate-debug-file 1" -ex run -ex "set listsize 40" -ex list -ex quit
#

#TODO:checks on make files: undefined variables (with db off)
# explain that the testid thing is for error detection (sidenote: prevents incrementalism tho
