## fuck.mk ##
# Install The Fuck on the system
# 
# REQUIRES
#   pip installed
#   WHICH_EXE -- in
#   	a which executable

.PHONY: build install pip-prebuild pip-preinstall

COMPONENT = fuck.mk
PIP_PACKAGE = thefuck
pip-prebuild:

pip-preinstall:

build: pip-build

install: pip-install

include ../utils/pip.mk
