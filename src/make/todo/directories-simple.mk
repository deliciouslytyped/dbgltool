include directories-simple.lib.mk

$(make-dir test))

test/.dum:
        $(mk-as-parent)

test/$(testid)/.dum: test/.dum
        $(mk-as-parent)

test/$(testid)/nix-tools/.dum: test/$(testid)/.dum
        $(mk-as-parent)

test/$(testid)/in/.dum: test/$(testid)/.dum
        $(mk-as-parent)

test/$(testid)/out/.dum: test/$(testid)/.dum
        $(mk-as-parent)
