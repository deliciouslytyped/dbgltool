#TODO is there a more compact way i can parametrize everything over whether its built in or separate debug outputs?

#TODO
LIB2REPLACE=glibc

.PHONY: _test-inputs
_test-inputs: $(foreach file,debug-separate $(LIB2REPLACE)-debug-inline-store-link $(LIBSREPLACE)-debug-separate-debug-store-link $(LIB2REPLACE)-debug-separate-lib-store-link srcarchive ,test/$(testid)/in/$(file))

###
### Set up inputs to the test process
###

#TODO this is probably where i need to split sparate debug outputs and nonseparate into different directory names and then 
test/$(testid)/in/$(LIB2REPLACE)-debug-separate-debug-store-link: $(IN_D)
	$(ln) -s $$(nix-build -E "import ../../default.nix {}" -A pkgs.$(LIB2REPLACE).debug --no-out-link) $@
test/$(testid)/in/$(LIB2REPLACE)-debug-separate-lib-store-link: $(IN_D)
	$(ln) -s $$(nix-build -E "import ../../default.nix {}" -A pkgs.$(LIB2REPLACE) --no-out-link) $@

#TODO proper way to do this?
#TODO to confirm this make a target that reads out the debug info in the target lib here
# see separatedebuginfo in  pkgs/stdenv/generic/make-derivation.nix pkgs/build-support/setup-hooks/separate-debug-info.sh
# TODO it enabled debugging, disabling it means we have to enable it - its also what seems to be responsible for compressing debug sections? so if we disable that we dont need to decompress in a separate step
#   TODO the sh script actually seems to be a good resource it has search stuff too
#   TODO also creates original-name.debug files? i need to look into this
#TODO/note we could, but dont, disable building deps with compressed debug sections because (xref objcopy) we want to minimize rebuilding and only patch - for speed
#TODO provide a decent way to override broken expressions 
#TODO
test/$(testid)/in/$(LIB2REPLACE)-debug-inline-store-link: $(IN_D)
	$(ln) -s $$(nix-build -E '(import ../../default.nix {}).pkgs.glibc.overrideAttrs (o: { separateDebugInfo = false; dontStrip = true; NIX_COMPILE_CFLAGS="-ggdb -Og"; })' --no-out-link) $@


test/$(testid)/in/srcarchive: LIBSRCPKG=glibc
test/$(testid)/in/srcarchive: $(IN_D)
	$(ln) -s $$(nix-build -E "import ../../default.nix {}" -A pkgs.$(LIBSRCPKG).src --no-out-link) $@


#TODO decent variable names
# If nixpkgs had better meta infra (or actually iirc it does have a main binary attr, but people just dont set it?)
# We could omit everything other than the package name and query it from nix?
defaultbin=hello
#I's use .SECONDARY but that doesn't currently accept patterns #TODO check if secondary is what you want https://www.gnu.org/software/make/manual/html_node/Chained-Rules.html the manual lists more info on this page than the special targets page...
.PRECIOUS: test/$(testid)/in/bin/%
test/$(testid)/in/bin/%: INPKG=$(defaultbin)
test/$(testid)/in/bin/%: INBIN=$(defaultbin)
test/$(testid)/in/bin/%: $(IN_BIN_D)
	$(ln) -s $$(nix-build -E "import ../../default.nix {}" -A pkgs.$(INPKG) --no-out-link)/bin/$(INBIN) $@
