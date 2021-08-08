#TODO we need a better parent implementation
#TODO this doesn't handle multiple trailing slashes?
define strip-trailing-dum
  $(patsubst %/.dum,%,$1)
endef
