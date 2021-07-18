#! /usr/bin/env nix-shell
#! nix-shell -p gdb hello patchelf binutils -i bash
#TODO patched binuytils
set -euo pipefail
set -x

dbgltool=$(nix-build --no-out-link -E "with import <nixpkgs> {}; callPackage ./default.nix {}")/bin/dbgltool
debugedit=$(nix-build --no-out-link -E "(import /bakery7/oven7/ephemeral/nixpkgs/debugedit {}).debugedit-unstable")/bin/debugedit

pushd $(mktemp -t test.XXXXXXXXXX -d)

target=$(cp -r $(nix-build "<nixpkgs>" -A glibc.debug) ./debug; chmod -R +w ./debug; pwd)/debug/lib/debug/ld-2.32.so
path=../../../../../../../../$target
src=$(set +x; tmpd=$(mktemp -t test.XXXXXXXXXX -d); { pushd $tmpd; tar axvf $(nix-build --no-out-link "<nixpkgs>" -A glibc.src); } 2>&1 >/dev/null; echo $tmpd)

ldso=$(pwd)/glibc/lib/ld-2.32.so

pwd
cp $(which hello) .
chmod +w hello
cp -r $(nix-build "<nixpkgs>" -A glibc --no-out-link) ./glibc
chmod -R +w glibc
patchelf --set-interpreter $ldso ./hello
objcopy --remove-section .gnu_debuglink $ldso #idempotency
# NOTE: I keep foretting about the decompression part...
objcopy --decompress-debug-sections $target
$debugedit -b "/build" -d "$src" $target
objcopy --add-section .gnu_debuglink=<($dbgltool d $path <($dbgltool c $target)) $ldso
readelf -x .gnu_debuglink $ldso
gdb -q ./hello -ex "set confirm off" -ex "set breakpoint pending on" -ex "b dl_main" -ex "set debug separate-debug-file 1" -ex run -ex "set listsize 40" -ex list -ex quit
