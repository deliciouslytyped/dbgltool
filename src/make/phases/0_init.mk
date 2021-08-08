# I split the make file into separate phases files because the comments complaining about make quirks were getting too long

### CONVENTIONS ###
#: are `remake` docstrings.
# we use .. .. wrap unwrap escape functions for all variables
# besides the first use of .SECONDEXPANSION in 0_init, we mark places we use it with it
#TODO assert gmake 4.3 for grouped outputs? and otherwise check required features

.SECONDEXPANSION:
#TODO is there any way to only delete things that belong to the failing job??
.DELETE_ON_ERROR:

#TODO vpath %.mk phases
.PHONY: _tests
_tests: show-testid _test-dirs _test-nix-tools _test-inputs _test-outputs

# TODO not sure what the right way to do this (with nix) is
SHELL := $(shell /usr/bin/env which bash)

# found another dumb make quirk 🙄😂😭 https://stackoverflow.com/questions/30573882/set-include-path-for-other-makefiles
# how do people live like this?
#tldr you cant set an include path for make files in the make file, the only solution is a cli argument,
# and vpath could be expanded to handle it, but the issue is open since 2005
# https://savannah.gnu.org/bugs/?func=detailitem&item_id=15224
# an alternative reading is that file relative addressing would be good, like in nix...

#TODO test dependence of phase targets on their phase scripts

#TODO i could try making an include macro that searches include paths
#TODO readdir, assert include order
include phases/1_testid.mk
include phases/2_directories.mk
include phases/3_builddep.mk
include phases/4_inputs.mk
include phases/5_outputs.mk
include phases/6_test.mk
include phases/7_clean.mk

# my VARIABLES
#TODO
defaultbin=hello
defaultlib=glibc

#TODO
testbins=hello lshw fd acpi
#TODO glibc/ldso is special, so are other libc libs i guess, pthreads, etc, how do i handle these?
testlibs=glibc libm
