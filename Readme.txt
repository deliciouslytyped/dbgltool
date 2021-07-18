Quick usage:
`$(nix-build https://github.com/deliciouslytyped/dbgltool/tarball/master -A dbgltool --no-out-link)/bin/dbgltool`

TODO `$(nix-build https://github.com/deliciouslytyped/dbgltool/tarball/master -A 'substDbgLib { bin = "bin/hello"; drv = pkgs.hello; tgt = withDebugOutput pkgs.glibc; };' --no-out-link)`


This repository contains `dbgltool` which is a tool for generating the content of `.gnu_debuglink` sections,
(Section creaton can be done with `objcopy`.) along with some Nix code for patching binaries and libraries
in the Nix store to support out-of-the-box source availibility when using GDB.

These two mechanisms are implementation-wise, orthogonal but serve a related purpose.

TODO See the `docs` directory for more information.

The `dbgltool` approach is not conformant to the descriptions of `.gnu_debuglink` (though I haven't been able
to find an actual specification*), but it functions and allows a simpler directory structure.

The approach followed by the Nix that uses standard tools (`objcopy`, `readelf`, etc) code is conformant
(through using only standard tools, all based on BFD, which along with GDB, is part of the binutils repository).

I expect the standard approach to be sufficient almost always unless you're trying to do something out of the box,
for which `dbgltool` is provided.

\* https://sourceware.org/gdb/onlinedocs/gdb/Separate-Debug-Files.html starting from "A debug link is a special
section of the executable file named .gnu_debuglink. The section must contain:" declares the format, but it's
unclear if this is the authoritative source, or if the phrasing is coincdental/derived.
