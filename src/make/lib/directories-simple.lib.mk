.SECONDEXPANSION:
### Setting up directories

# We use .dum dummy system because of the behaviour described in
# (www.conifersystems.com/whitepapers/gnu-make/ "Creating Output Directories")
# i.e. directory mtime is bumped on subfile (analogous: subdir) creation, resulting in
# targets located in the directory being older than their dependency; the parent dir.
# This results in unnecessary rebuilds. 

#TODO test

# USAGE: TODO
# Note the trailing slash is required for all things you want to be a directory (by
# convention, idk about technical limitations)
# $(make-dir,test/1/lol/)
# 

include parent.lib.mk


#TODO note accidentally replicated part of the GNU Make Book solution 3
define make-dir
.SECONDEXPANSION:
$1/.dum: $$(call parent,$$@)
	mkdir $(dir $@)
	touch $@
endef


define make-dir2
.SECONDEXPANSION:
.PRECIOUS: %/
$1/: $$(call parent,$$@)
	mkdir -p $(dir $@)
	touch $@
endef

define add-dir-dep
$1: | $2
$(call, make-dir2)
endef

.PRECIOUS: %/
%/:
	mkdir $@

%: $$(call parent,$$@)
