include strip-trailing-slash.lib.mk

#TODO need a better implementation probably
define parent
  $(dir $(call strip-trailing-slash,$1))
endef
