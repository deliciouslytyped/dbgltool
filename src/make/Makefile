VPATH = ..
CPPFLAGS = -I .

# Meta
default: dbgltool
all: default check
#TODO check, install?
#check: test-cert
.PHONY: all clean clean-test install

# Build
../dbgltool.c: usage.h ../crc.h
include usage.mk

# Test
include test.mk

# Install / Uninstall
# http://nuclear.mutantstargoat.com/articles/make/
PREFIX = /usr/local

.PHONY: install
install: dbgltool
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp $< $(DESTDIR)$(PREFIX)/bin/


#TODO untested ,/ unused on nixos
#.PHONY: uninstall
#uninstall:
#    rm -f $(DESTDIR)$(PREFIX)/bin/mygame


# Clean
#TODO I don't like these -f, I should be able to filter the missing file error and possibly exit code without a ton of crap...
clean:
	rm -f usage.h dbgltool
