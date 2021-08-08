#! /usr/bin/env bash

# Usage:
# The script takes one argument, which should be a nix store derivation output root.
# It outputs a list of ELF (library or otherwise) paths relative to said root.

# We steal this ELF checking code from pkgs/stdenv/generic/setup.sh
# Return success if the specified file is an ELF object.
isELF() {
    local fn="$1"
    local fd
    local magic
    exec {fd}< "$fn"
    read -r -n 4 -u "$fd" magic
    exec {fd}<&-
    if [ "$magic" = $'\177ELF' ]; then return 0; else return 1; fi
}

# We steal this search code from pkgs/build-support/setup-hooks/separate-debug-info.sh
findFiles() {
    # Find executables and dynamic libraries.
    local i
    while IFS= read -r -d $'\0' i; do
        if ! isELF "$i"; then continue; fi
        # Output paths relative to the store path root
        echo "$i" | sed -E "s|/nix/store/[^/]+/|./|"
    done < <(find "$1" -type f -print0)
    }

findFiles "$1"
