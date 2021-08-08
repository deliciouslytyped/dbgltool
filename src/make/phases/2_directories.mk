#This is a little complicated, so that we can get vars in the list here at the top of the file
.PHONY: _test-dirs touch-dums
__test-dirs=$(TEST_D) $(TESTID_D) $(NIXTOOLS_D) $(IN_D) $(OUT_D) $(OUT_BIN_D)
.SECONDEXPANSION:
_test-dirs:show-testid $$(__test-dirs)

#TODO figure out why rebuilds are always forced
#touch-dums:
#	touch $(__test-dirs)

#TODO this doesnt really work right
#$ make testid=$(make show-last-testid) test/$(make show-last-testid)/testresults/hello-gdb                                
#mkdir test/
#mkdir: cannot create directory ‘test/’: File exists
#make: *** [phases/2_directories.mk:59: test/.dum] Error 1
#this_phase:=phases/2_directories.mk
this_phase:=

###
### Setting up directories
###

# TODO http://www.conifersystems.com/whitepapers/gnu-make/ says this directory dependence technique won't work proper
#  TODO does make recognize directories ?
# TODO indeed:
# ```
# $ make -r -d testid=3 _test-nix-tools | less
# ...
# Updating goal targets....
# Considering target file '_test-nix-tools'.
#  File '_test-nix-tools' does not exist.
#   Considering target file 'test/3/nix-tools/dbgltool'.
#     Considering target file 'test/3/nix-tools/'.
#       Considering target file 'test/3/'.
#         Considering target file 'test/'.
#          Finished prerequisites of target file 'test/'.
#         No need to remake target 'test/'.
#        Finished prerequisites of target file 'test/3/'.
#        Prerequisite 'test/' is newer than target 'test/3/'.
#       Must remake target 'test/3/'.
# ...
# ```

include lib/strip-trailing-slash.lib.mk

mkdir=mkdir
define mk-as-parent
       $(mkdir) $(dir $@)
       touch $(call strip-trailing-slash,$(dir $@))/.dum
endef

#TODO generate tree code

#TODO remove these after the directory stuff has stabilized
TEST_D := test/.dum
TESTID_D := test/$(testid)/.dum
NIXTOOLS_D := test/$(testid)/nix-tools/.dum
IN_D := test/$(testid)/in/.dum
IN_BIN_D := test/$(testid)/in/bin/.dum
OUT_D := test/$(testid)/out/.dum
OUT_BIN_D := test/$(testid)/out/bin/.dum
TESTRESULTS_D := test/$(testid)/testresults/.dum

$(TEST_D): $(this_phase)
	$(mk-as-parent)

$(TESTID_D): $(TEST_D) $(this_phase)
	$(mk-as-parent)

$(NIXTOOLS_D): $(TESTID_D) $(this_phase)
	$(mk-as-parent)

$(IN_D): $(TESTID_D) $(this_phase)
	$(mk-as-parent)

$(IN_BIN_D): $(IN_D) $(this_phase)
	$(mk-as-parent)

$(OUT_D): $(TESTID_D) $(this_phase)
	$(mk-as-parent)

$(OUT_BIN_D): $(OUT_D) $(this_phase)
	$(mk-as-parent)

$(TESTRESULTS_D): $(TESTID_D) $(this_phase)
	$(mk-as-parent)


## See the documentation in directories.mk
#.INTERMEDIATE: test/ test/$(testid)/ test/$(testid)/nix-tools/ test/$(testid)/in/ test/$(testid)/out/
