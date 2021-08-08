include phases/0_init.mk

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
