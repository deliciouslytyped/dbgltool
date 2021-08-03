### CONVENTIONS ###
#: are `remake` docstrings.
# we use .. .. wrap unwrap escape functions for all variables

#TODO assert gmake 4.3 for grouped outputs?

###
### Test (check)
###

.PHONY: check nix-check _tests
nix-check: test/$(testid)/out/hello
_tests: show-testid _test-dirs _test-nix-tools _test-inputs _test-outputs

#TODO
# It kind of works even if test/ is missing; it sets testid zero
# TODO Needs to be after test/: but before any usages of $(testid)
#
#TODO my explanation of this before the machine hung was a lot clearer
#TODO Semantcally, this depends on test/:, it would be nice if it could be interposed between the creation of test/
# and its usage as $(testid) in various targets, however there seems to be two issues with this:
# 1) I don't know when setting of variables happens in relation to the make phases, when setting a variable using
# eval in a recipe (probably see https://www.gnu.org/software/make/manual/html_node/Eval-Function.html)
# ? https://stackoverflow.com/a/1909390
# 2) recipes are run in make's build phase, and variables in targets are expanded during the parsing phase;
# I don't know if make has a way to interleave phases in a parse-build-parse-build-... manner (similar to Nix IFD?)
# other than recursively calling make. This seems to be the same as my problem:
# https://stackoverflow.com/questions/50231970/define-a-makefile-target-from-variables-set-with-eval
# Note to self: see your notes file
#testid:=$(shell ls -1 test/ | wc -l)

#TODO probably assert no holes if you want more relibility; it breaks if stuff isnt monotone and including 0
testid:=$(shell ([ -d test ] && ls test ) | wc -l)

#TODO it's hard to invoke make with targets that have changing variables
# Usage: make test/$(make show-testid)/nix-tools/dbgltool
.PHONY:show-testid
show-testid:
	@echo $(testid)

### Setting up directories
.PHONY: _test-dirs
_test-dirs: test/$(testid)/nix-tools/.dum test/$(testid)/in/.dum test/$(testid)/out/.dum

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

# NOTE: we use .dum because of the behaviour described in
# (www.conifersystems.com/whitepapers/gnu-make/ "Creating Output Directories")
# i.e. directory mtime is bumped on subfile (analogous: subdir) creation, resulting in
# targets located in the directory being older than their dependency; the parent dir,
# resulting in unnecessary rebuilds. This is why we use the .dum dummy system.

define mk-as-parent
	mkdir $(dir $@)
	touch $(dir $@)/.dum
endef

define make-dir
$1/.dum: $(not-dir $1)
	mkdir $(dir $@)
	touch $(dir $@)/.dum
endef

$(make-dir test))

test/.dum:
	$(mk-as-parent)

test/$(testid)/.dum: test/.dum
	$(mk-as-parent)

test/$(testid)/nix-tools/.dum: test/$(testid)/.dum
	$(mk-as-parent)

test/$(testid)/in/.dum: test/$(testid)/.dum
	$(mk-as-parent)

test/$(testid)/out/.dum: test/$(testid)/.dum
	$(mk-as-parent)

### Get tool deps in scope
#TODO remove this and just use nix-shell/PATH/etc
.PHONY: _test-nix-tools
_test-nix-tools: test/$(testid)/nix-tools/dbgltool test/$(testid)/nix-tools/debugedit test/$(testid)/nix-tools/patchelf

NIXBIN.ln=ln $$(nix-build --no-out-link -E "import ../../default.nix {}" -A $(NIXPKG))/bin/$(notdir $@) -f -s $@
test/$(testid)/nix-tools/dbgltool: NIXPKG:=dbgltool
test/$(testid)/nix-tools/dbgltool: test/$(testid)/nix-tools/.dum
	$(NIXBIN.ln)

test/$(testid)/nix-tools/debugedit: NIXPKG:=pkgs.debugedit-unstable
test/$(testid)/nix-tools/debugedit: test/$(testid)/nix-tools/.dum
	$(NIXBIN.ln)

test/$(testid)/nix-tools/patchelf: NIXPKG:=pkgs.patchelf
test/$(testid)/nix-tools/patchelf: test/$(testid)/nix-tools/.dum
	$(NIXBIN.ln)

test/$(testid)/nix-tools/objcopy: NIXPKG:=pkgs.binutils
test/$(testid)/nix-tools/objcopy: test/$(testid)/nix-tools/.dum
	$(NIXBIN.ln)

# Extra stuff for debugging and inspection
test/$(testid)/nix-tools/dwarfdump: NIXPKG:=pkgs.dwarfdump
test/$(testid)/nix-tools/dwarfdump: test/$(testid)/nix-tools/.dum
	$(NIXBIN.ln)

### Inputs
.PHONY: _test-inputs
_test-inputs: test/$(testid)/in/debug test/$(testid)/in/srcarchive

test/$(testid)/in/debug: test/$(testid)/in/.dum
	cp -r $$(nix-build -E "import ../../default.nix {}" -A pkgs.glibc.debug --no-out-link) $@
	chmod -R +w $@

test/$(testid)/in/srcarchive: test/$(testid)/in/.dum
	ln -s $$(nix-build -E "import ../../default.nix {}" -A pkgs.glibc.src --no-out-link) $@

### Result
.PHONY: _test-outputs
_test-outputs: test/$(testid)/out/hello test/$(testid)/out/src test/$(testid)/out/debug

test/$(testid)/out/src: test/$(testid)/in/srcarchive
	mkdir $@
	tar axvf $< -C $@

#TODO variableize debugedit etc
#TODO remove this and parametrize
dbgtgt:=/lib/debug/ld-2.33.so
#TODO fix cwd
#TODO these should probably be using .dum? unless they are symlinks
test/$(testid)/out/debug: test/$(testid)/in/debug test/$(testid)/out/src test/$(testid)/nix-tools/debugedit test/$(testid)/nix-tools/objcopy
	$(debugger "wat")
	#TODO probably do this for all viable targets
	test/$(testid)/nix-tools/objcopy --decompress-debug-sections $</$(dbgtgt)
	#TODO use a variable for this instead?
	test/$(testid)/nix-tools/debugedit -b "/build" -d ../../../../../../../../../../../../$(shell realpath $(word 2,$^)) $</$(dbgtgt)
	cp -r $< $@

test/$(testid)/out/hello: test/$(testid)/out/.dum test/$(testid)/in/debug
	touch $@
	
### Clean
clean: clean-test
clean-test:
	rm -fr test


define BOGUS
#TODO
nix-test-cert: test/ nix-dbgltool nix-debugedit nix-libc nix-hello test.sh
        ls --color=always -alh test




#TODO can't use this like this in the nix sandbox so we need to make this have two variants
## instead of ln -f, amke mke take deps properly and do the special remove target thing?
##TODO is this fake phony?

test/$(testid)/in/hello:
        cp -r $(nix-build  -E "import ../../default.nix {}" -A hello --no-out-link)/bin/hello $@
        chmod -R +w $@

#TODO
test/$(testid)/out/hello: test/$(testid)/out/ test/$(testid)/in/hello test/$(testid)/nix-tools/patchelf
	cp %< $@
	patchelf --set-interpreter LDSO $@
        pattch rpath or what?


.PHONY: test-hello-glibc
test-hello-glibc:
	readelf -x .gnu_debuglink $ldso
	gdb -q ./hello -ex "set confirm off" -ex "set breakpoint pending on" -ex "b dl_main" -ex "set debug separate-debug-file 1" -ex run -ex "set listsize 40" -ex list -ex quit


#TODO
##! /usr/bin/env nix-shell
##! nix-shell -p gdb hello patchelf binutils -i bash
##TODO patched binuytils
#set -euo pipefail
#set -x
#target,path = ...
#pushd $(mktemp -t test.XXXXXXXXXX -d)

endef
