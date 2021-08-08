#TODO
# It kind of works even if test/ is missing; it sets testid zero
# TODO Needs to be after test/: but before any usages of $(testid)
#
#TODO my explanation of this before the machine hung was a lot clearer
#TODO Semantcally, this depends on test/:, it would be nice if it could be interposed between the creation of test/
# and its usage as $(testid) in various targets, however there seems to be two issues with this:
# 1) I don't know when setting of variables happens in relation to the make phases, when setting a variable using
# eval in a recipe (probably see https://www.gnu.org/software/make/manual/html_node/Eval-Function.html)
# ? https://stackoverflow.com/a/1909390
# 2) recipes are run in make's build phase, and variables in targets are expanded during the parsing phase;
# I don't know if make has a way to interleave phases in a parse-build-parse-build-... manner (similar to Nix IFD?)
# other than recursively calling make. This seems to be the same as my problem:
# https://stackoverflow.com/questions/50231970/define-a-makefile-target-from-variables-set-with-eval
# Note to self: see your notes file
#testid:=$(shell ls -1 test/ | wc -l)

#TODO probably assert no holes if you want more relibility; it breaks if stuff isnt monotone and including 0
testid:=$(shell ([ -d test ] && ls test ) | wc -l)

#TODO it's hard to invoke make with targets that have changing variables
# Usage: make test/$(make show-testid)/nix-tools/dbgltool
.PHONY:show-testid show-last-testid
show-testid:
	@echo $(testid)

#TODO doesnt handle yero or whatever properly
# so you can do stuff like nano test/$(($(remake show-last-testid)-1))/out/elflist-separate
show-last-testid:
	@echo $$(($(testid)-1))
