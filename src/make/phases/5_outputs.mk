include lib/strip-trailing-dum.lib.mk

#TODO consider a hook macro based strategy to parametrize this

#This is a little complicated, so that we can get vars in the list here at the top of the file
.PHONY: _test-outputs
__test-outputs=$(foreach file,bin/hello src elflist debug,test/$(testid)/out/$(file)) $(elflist)-inline $(elflist)-separate
.SECONDEXPANSION:
_test-outputs: $$(__test-outputs)

###
### Result
###

#TODO translate to use nix and symling #TODO parametrize into nix and non-nix version?
# This is what we want the dwarf debug info to end up pointing at
test/$(testid)/out/src: test/$(testid)/in/srcarchive $(OUT_D)
	$(mkdir) $@
	tar axf $< -C $@

# The expected output is a file full of .so paths, see the source for additional info
#TODO write a test for this / assert these are nonempty
#TODO maaaaybe you could use a double colon rule for this
elflist=test/$(testid)/out/elflist
$(elflist)-inline: test/$(testid)/in/$(LIB2REPLACE)-debug-inline-store-link $(OUT_D)
	./findelves.sh $(realpath $<) > $@

#TODO something is screwy here because some .o files end up in the list? # test/47/nix-tools/objcopy: 'test/47/out/glibc-debug-separate-debug/lib/debug/Mcrt1.o': No such file 
$(elflist)-separate: test/$(testid)/in/$(LIB2REPLACE)-debug-separate-lib-store-link $(OUT_D)
	./findelves.sh $(realpath $<) > $@


# This is the part that rewrites the library to have its debug information point to the source( in the nix store)
# The ../ prepending is a hack to address relative to the root directory
# obviously in a case of sufficient nesting it will break, but really, TODO I should be using the robust solution here #NOTE this todo is wrong because thats wrt which method we use for finding debug info
xargs = xargs
#TODO extracted_src -> extracted_src_link, see above target
extracted_src=test/$(testid)/out/src
abspathhack=../../../../../../../../../../../../../../../../
test/$(testid)/out/$(LIB2REPLACE)-debug-inline: test/$(testid)/in/$(LIB2REPLACE)-debug-inline-store-link $(extracted_src) $(OUT_D) $(ex_objcopy) $(ex_debugedit) $(elflist)-inline
	cp -r $(realpath $<) $@
	chmod -R +w $@
	$(xargs) -a $(elflist)-inline -I '{}' $(ex_objcopy) --decompress-debug-sections $@/{}
	$(xargs) -a $(elflist)-inline -I '{}' $(ex_debugedit) -b "/build" -d $(realpath $(extracted_src)) $@/{}

test/$(testid)/out/$(LIB2REPLACE)-debug-separate-lib: test/$(testid)/out/$(LIB2REPLACE)-debug-separate-debug test/$(testid)/in/$(LIB2REPLACE)-debug-separate-lib-store-link $(extracted_src) $(OUT_D) $(ex_dbgltool) $(ex_objcopy) $(elflist)-separate
	cp -r $(realpath $(word 2,$^)) $@
	chmod -R +w $@
	#TODO these realpath uses dont deal with gc roots
	#TODO path fuckery, basename screwery
	$(xargs) -a <(sed 's|\./lib|\./lib/debug|' $(elflist)-separate) -I '{}' bash -c '$(ex_objcopy) --add-section .gnu_debuglink=<($(ex_dbgltool) d $(abspathhack)$(realpath $<)/lib/debug/$$(basename {}) <($(ex_dbgltool) c $</lib/debug/$$(basename {}) )) $@/$$(sed s%./lib/debug%./lib% <<< {})'
#	mkdir $@/lib/.debug

test/$(testid)/out/$(LIB2REPLACE)-debug-separate-debug: test/$(testid)/in/$(LIB2REPLACE)-debug-separate-debug-store-link $(extracted_src) $(OUT_D) $(ex_objcopy) $(ex_debugedit) $(elflist)-separate
	cp -r $(realpath $<) $@
	chmod -R +w $@
	#TODO basename screwery
	$(xargs) -a $(elflist)-separate -I '{}' bash -c '$(ex_objcopy) --decompress-debug-sections $@/lib/debug/$$(basename {})' || true
	#$(xargs) -a <(comm -1 -2 <(find $@/lib/debug -type f -printf "%f\n" | sort) <(xargs -a $(elflist)-separate -I '{}' basename {} | sort) ) -I '{}' bash -c '$(ex_objcopy) --decompress-debug-sections $@/lib/debug/$$(basename {})'
	#TODO just run on anything in the debug dir?
	#TODO only do existing files
	$(xargs) -a $(elflist)-separate -I '{}' bash -c '$(ex_debugedit) -b "/build" -d $(realpath $(extracted_src)) $@/lib/debug/$$(basename {})' || true
	#$(xargs) -a <(comm -1 -2 <(find $@/lib/debug -type f -printf "%f\n" | sort) <(xargs -a $(elflist)-separate -I '{}' basename {} | sort) ) -I '{}' bash -c '$(ex_debugedit) -b "/build" -d $(realpath $(extracted_src)) $@/lib/debug/$$(basename {})'

#TODO shold just parametrize hello over the -separate prefix or something
#test/$(testid)/out/debug-separate: test/$(testid)/in/debug-separate $(SRCD) test/$(testid)/nix-tools/debugedit test/$(testid)/nix-tools/objcopy

##LDSO patching variant is special (because?)
#ldso=test/$(testid)/out/debug/lib/ld-2.33.so
#test/$(testid)/out/bin/hello: test/$(testid)/in/bin/hello $(OUT_BIN_D) test/$(testid)/out/debug  $(ldso) $(ex_patchelf)
#	cp $< $@
#	chmod +w $@
#	$(ex_patchelf) --set-interpreter $(ldso) $@
#	#$(ex_patchelf) --set-rpath $(patchelf --print-rpath "$out"/${bin} | sed -E 's|(/[^/:]+)+-glibc-([^/:]+)(/[^/:]+)+|${tgt}/lib|')


#test/$(testid)/out/bin/hello-separate: $(OUT_D) test/$(testid)/in/debug
#	#$(ex_patchelf) --set-interpreter $ldso ./hello
#	touch $@
#	

#TODO rebuild target with full debugging from rpath and search path and stuff

#LDSO patching variant is special (because?)

#Id's use .SECONDARY but that doesn't currently accept patterns#TODO check if secondary is what you want https://www.gnu.org/software/make/manual/html_node/Chained-Rules.html the manual lists more info on this page than the special targets page...
.PRECIOUS: test/$(testid)/out/bin/%-ldso-inline
test/$(testid)/out/bin/%-ldso-inline: ldso_root=test/$(testid)/out/$(LIB2REPLACE)-debug-inline
test/$(testid)/out/bin/%-ldso-inline: ldso=$(ldso_root)/lib/ld-2.33.so
#TODO ldso should be a dependency but it messes with make because it correctly reports that we dont have any rules that supply it
test/$(testid)/out/bin/%-ldso-inline: test/$(testid)/in/bin/% $(OUT_BIN_D) test/$(testid)/out/$(LIB2REPLACE)-debug-inline $(ex_patchelf) $(ldso_root)
	cp $< $@
	chmod +w $@
	$(ex_patchelf) --set-interpreter $(ldso) $@
	#$(ex_patchelf) --set-rpath $(patchelf --print-rpath "$out"/${bin} | sed -E 's|(/[^/:]+)+-glibc-([^/:]+)(/[^/:]+)+|${tgt}/lib|')

#TODO
#LDSO patching variant is special (because?)
#TODO ldso should be a dependency but it messes with make because it correctly reports that we dont have any rules that supply it
#Id's use .SECONDARY but that doesn't currently accept patterns
.PRECIOUS: test/$(testid)/out/bin/%-ldso-separate
test/$(testid)/out/bin/%-ldso-separate: ldso_root=test/$(testid)/out/$(LIB2REPLACE)-debug-separate-lib
test/$(testid)/out/bin/%-ldso-separate: ldso=$(ldso_root)/lib/ld-2.33.so
test/$(testid)/out/bin/%-ldso-separate: test/$(testid)/in/bin/% $(OUT_BIN_D) test/$(testid)/out/$(LIB2REPLACE)-debug-separate-lib $(ex_patchelf) $(ldso_root)
	cp $< $@
	chmod +w $@
	$(ex_patchelf) --set-interpreter $(ldso) $@
	#$(ex_patchelf) --set-rpath $(patchelf --print-rpath "$out"/${bin} | sed -E 's|(/[^/:]+)+-glibc-([^/:]+)(/[^/:]+)+|${tgt}/lib|')
