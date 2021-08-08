### Setting up directories

# Usage:
#.INTERMEDIATE: test/ test/$(testid)/ test/$(testid)/nix-tools/ test/$(testid)/in/ test/$(testid)/out/
# TODO

#TODO CORRECTION ugh, turns out the book does mention order-only prerequisites but the last time i tried searching, for some reason, it failed to find anything....

#TODO tests _test-directories-lib

#TODO add https://make.mad-scientist.net/secondary-expansion/ to supplementary references
# and consider doing "Secondary expansion is undeniably useful, but it’s fairly limited:
# it only allows for modifying the prerequisite lists of existing targets. What if we want
# to create entirely new rules? GNU make has long had a powerful method for this: constructed include files."
# -> http://make.mad-scientist.net/constructed-include-files/

#TODO add make.mad-scientist.net/papers/rules-of-makefiles/
# " It is useful to list directories as order-only prerequisites, however."

#TODO GNU Make Book solution 4/5 is somewhat similar, the difference is that we're trying to add automatic
# recursive deps to the implicit rule (instead of -p on mkdir) and that didnt work? and that were using 
# dirs instead of dummy files?
# However I didn"'t think of their suggestion of using $$(@D) in other prerequisites
# However I dont understand why they are still using dummy files in example 5

#TODO note per the source secondexpansion just seems to set a global flag and isnt file scoped,
# we add it here to make sure we have it

#TODO idk what this snap stuff is but i accidentally found the following comment suggesting eval could
# work for adding new targets?
#/* Remember whether snap_deps has been invoked: we need this to be sure we
#   don't add new rules (via $(eval ...)) afterwards.  In the future it would
#   be nice to support this, but it means we'd need to re-run snap_deps() or
#   at least its functionality... it might mean changing snap_deps() to be run
#   per-file, so we can invoke it after the eval... or remembering which files
#   in the hash have been snapped (a new boolean flag?) and having snap_deps()
#   only work on files which have not yet been snapped. */
#int snapped_deps = 0;

##
# NOTE: The previous solution involving .dum file seems nicer and is more portable, this is less verbose though.
# I having to use INTERMEDIATE and PRECIOUS for this approach also feels dirty. Not having .dum files leaves the
# tree slightly cleaner.
#
# This is a bad solution TBH*. It takes, like, half, of gmake's more obscure features, to get a half decent solution
# for creating directories. - and I'm not even sure the semantics of it are actually correct, because its complicated.
# * 80 lines of documentation for 5 lines of code.
#
# The rationales for the various feature usages here (order-only prerequisites [1], SECONDEXPANSION [2],
# INTERMEDIATE [3], PRECIOUS [3]) is described in the following links:
##
#
# [1] https://www.gnu.org/software/make/manual/html_node/Prerequisite-Types.html
#
#   Order-only prerequisites are suggested as a solution to the directory creation issue in the manual entry.
#   ## TODO: figure out if this has always been a part of gmake or what; the manual usually mentions a feature flag
#   ## but it doesn't in this case, however neither the GNU Make Book nor Managing Projects with GNU Make appear
#   ## to mention the feature - so I'm assuming it was added after 2015.
#  Interestingly, the NEWS file in the make repository shows that order-only prerequisites were added to make in 2002.
#  What I don't understand, is why then, is it not mentioned in either of the Maike b
#     " Version 3.80 (03 Oct 2002)
#     "
#     " * A new feature exists: order-only prerequisites.  These prerequisites
##TODO so this only got added after publication of Managing... but way before GNU Make Book
##     also i need to check if this came from the mailing list
##7595f38f doc/make.texi (Paul Smith         2006-10-01 05:38:38 +0000  2067) directory's timestamp changes.  One way to manage this is with
##7595f38f doc/make.texi (Paul Smith         2006-10-01 05:38:38 +0000  2068) order-only prerequisites: make the directory an order-only
##
##commit 7595f38f62afa7ac3451018d865fb251e3ce91c3
##Author: Paul Smith <psmith@gnu.org>
##Date:   Sun Oct 1 05:38:38 2006 +0000
##
##    Fixed a number of documentation bugs, plus some build/install issues:
##      16304, 16468, 16577, 17701, 17880, 16051, 16652, 16698
##    Plus some from the mailing list.
##    
##    Imported a patch from Eli to allow Cygwin builds to support DOS-style
##    pathnames.
#
# [2] https://stackoverflow.com/questions/9526295/how-to-call-functions-within-order-only-prerequisites
#     https://www.gnu.org/software/make/manual/html_node/Secondary-Expansion.html
#     https://stackoverflow.com/questions/34752044/make-secondexpansion-broken-by-implicit-rule-recursion
#
#   Due to the way the make parser/expansion works, % is expanded after calls and variables, so we have
#   to use SECONDEXPANSION.
#
# [3] https://stackoverflow.com/questions/43341744/gnu-makes-secondexpansion-and-recursion
#     https://savannah.gnu.org/bugs/?30381
#     https://www.gnu.org/software/make/manual/html_node/Implicit-Rule-Search.html
#     https://www.gnu.org/software/make/manual/html_node/Chained-Rules.html (this is mentioned here and in [7])
#
#   These seem very similar to what I want to do here: Ideally we could just have the current recursive implicit rule
#   implementation, but make (IIUC) doesn't allow the implicit rule to recurse - in fact it's stricter than that:
#   it can't even appear twice. Using .INTERMEDIATE somehow fixes this at the cost of explicitly listing the targets -
#   so we are stuck doing that. (See also [6])
#
# [4] https://www.gnu.org/software/make/manual/html_node/Special-Targets.html
#
#   See also [3].
#   INTERMEDIATE and PRECIOUS are described here.
#
# [5] https://www.gnu.org/software/make/manual/html_node/Pattern-Rules.html
#
#   Pattern rules are described here.
#
# [6] https://stackoverflow.com/questions/39188323/makefile-defining-rules-and-prerequisites-in-recipes#comment65726454_39188323
#
#   Regarding the explicit INTERMEDIATE target listsing in [3]: I also tried using eval to dynamically generate the
#   INTERMEDIATE targets in the %/ rule, but this doesn't work because (IIUC) the dependency graph computation must all
#   be finished before evaluation of recipes; see this quote from the above link:
#     " Also FYI, you can use eval to set variables from within recipes, but you can't use it to create new rules.
#     " This is because after make reads in all the makefiles and before it starts to run recipes, it performs
#     " a process that aligns all the makefile data into its internal graph. Once that happens, you can't change
#     " the graph by adding new rules. – MadScientist
#
# [7] https://stackoverflow.com/questions/27090032/why-secondary-does-not-work-with-patterns-while-precious-does
#     https://www.gnu.org/software/make/manual/html_node/Special-Targets.html
#     https://www.gnu.org/software/make/manual/html_node/Chained-Rules.html
#
#   Originally we would have had to redundantly list the directory targets in both .INTERMEDIATE and .PRECIOUS, or used
#   a common variable in both - however, apparently .PRECIOUS allows pattern rules, so in that case we can just use %/.
#
#   If .SECONDARY or .INTERMEDIATE supported pattern rules, we could entirely omit explicit target listings for this
#   use case. According to the above StackOverflow post, they don't, because it hasn't been implemented for years.
#   ### TODO: The Chained Rules documentation suggests .SECONDARY, it's unclear to me if I should be using that instead
#   ### of INTERMEDIATE and PRECIOUS. TLDR: INTERMEDIATE+PRECIOUS vs SECONDARY?
#
#   From the StackOverflow link:
#     " What i found is that it is recorded in TODO.private of make project for 15 years ....
#     "   6) Right now the .PRECIOUS, .INTERMEDIATE, and .SECONDARY
#     "      pseudo-targets have different capabilities.  For example, .PRECIOUS
#     "      can take a "%", the others can't.  Etc.  These should all work the
#     "      same, insofar as that makes sense.
#
# [8] https://stackoverflow.com/questions/47447369/gnu-make-removing-intermediate-files
#
#   RE: the above TODO; this talks a bit about using SECONDARY(, and INTERMEDIATE)
#
##
include parent.lib.mk

.SECONDEXPANSION:
%/: | $$(call parent,%/)
	mkdir $@

# See [7] above.
.PRECIOUS: %/
