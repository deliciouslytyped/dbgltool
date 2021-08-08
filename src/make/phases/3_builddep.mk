#TODO remove this and just use nix-shell/PATH/etc
.PHONY: _test-nix-tools
_test-nix-tools: $(foreach file,dbgltool debugedit patchelf objcopy dwarfdump gdb,test/$(testid)/nix-tools/$(file))

#TODO this doesnt really work right
#this_phase:=phases/3_builddep.mk
this_phase:=

###
### Get tool deps in scope
###

ln=ln
NIXBIN.ln=$(ln) $$(nix-build --no-out-link -E "import ../../default.nix {}" -A $(NIXPKG))/bin/$(notdir $@) -f -s $@

ex_dbgltool := test/$(testid)/nix-tools/dbgltool
test/$(testid)/nix-tools/dbgltool: NIXPKG:=dbgltool
test/$(testid)/nix-tools/dbgltool: $(NIXTOOLS_D) $(this_phase)
	$(NIXBIN.ln)

ex_debugedit := test/$(testid)/nix-tools/debugedit
test/$(testid)/nix-tools/debugedit: NIXPKG:=pkgs.debugedit-unstable
test/$(testid)/nix-tools/debugedit: $(NIXTOOLS_D) $(this_phase)
	$(NIXBIN.ln)

ex_patchelf := test/$(testid)/nix-tools/patchelf
test/$(testid)/nix-tools/patchelf: NIXPKG:=pkgs.patchelf
test/$(testid)/nix-tools/patchelf: $(NIXTOOLS_D) $(this_phase)
	$(NIXBIN.ln)

ex_objcopy := test/$(testid)/nix-tools/objcopy
test/$(testid)/nix-tools/objcopy: NIXPKG:=pkgs.binutils-unwrapped
test/$(testid)/nix-tools/objcopy: $(NIXTOOLS_D) $(this_phase)
	$(NIXBIN.ln)

# Extra stuff for debugging and inspection
ex_dwarfdump := test/$(testid)/nix-tools/dwarfdump
test/$(testid)/nix-tools/dwarfdump: NIXPKG:=pkgs.dwarfdump
test/$(testid)/nix-tools/dwarfdump: $(NIXTOOLS_D) $(this_phase)
	$(NIXBIN.ln)


ex_readelf := test/$(testid)/nix-tools/readelf
test/$(testid)/nix-tools/readelf: NIXPKG:=pkgs.binutils-unwrapped
test/$(testid)/nix-tools/readelf: $(NIXTOOLS_D) $(this_phase)
	$(NIXBIN.ln)

ex_gdb := test/$(testid)/nix-tools/gdb
test/$(testid)/nix-tools/gdb: NIXPKG:=pkgs.gdb
test/$(testid)/nix-tools/gdb: $(NIXTOOLS_D) $(this_phase)
	$(NIXBIN.ln)
