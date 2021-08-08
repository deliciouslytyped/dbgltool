#{runCommand, stdenv}: runCommand "dbgltool" { buildInputs = [ stdenv.cc ]; } ''
#  mkdir -p "$out/bin"
#  gcc -Wall -Werror -Wextra ${../src/dbgltool.c} -o "$out/bin/dbgltool"
#  ''
{stdenv}: stdenv.mkDerivation {
  name = "dbgltool";
  src = builtins.filterSource (p: t: (builtins.match ".*/src/make/test/.*" p) == null ) ./..;
  postUnpack = ''sourceRoot="$sourceRoot/src/make"'';
  installFlags = [ "PREFIX=$(out)" ]; #TODO i dont like that we cant do this throuogh bash due to the escaping - are all the other stdenv vars escaped? i dont think so?
  }
