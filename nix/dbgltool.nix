{runCommand, stdenv}: runCommand "dbgltool" { buildInputs = [ stdenv.cc ]; } ''
  mkdir -p "$out/bin"
  gcc -Wall -Werror -Wextra ${../src/dbgltool.c} -o "$out/bin/dbgltool"
  ''
