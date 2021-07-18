{ pkgs ? (import (import ./nix/sources.nix).nixpkgs {})
, binutils-unwrapped ? pkgs.binutils-unwrapped
, mkShell ? pkgs.mkShell
, callPackage ? pkgs.callPackage
, debugedit-unstable ? pkgs.debugedit-unstable
, niv ? pkgs.niv
}:
let
  dbgltool = callPackage ./nix/dbgltool.nix {};
  binutils-patched = binutils-unwrapped.overrideAttrs (o: {
    patches = (o.patches or []) ++ [ ./patches/bfd-remove-basename-restriction.patch ];
    });

  packages = {
    inherit dbgltool binutils-patched debugedit-unstable;
    };

  shell = mkShell { buildInputs = builtins.attrValues packages; };
  devShell = mkShell { buildInputs = [ niv ]; };
in {
  inherit shell devShell;
  } // packages
