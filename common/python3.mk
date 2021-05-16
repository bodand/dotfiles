## python3.mk ##
# Installs Python3 on the system
# 
# REQUIRES
#  COMMON_DIR -- in
#    path to common files
#  WHICH_EXE --
#  	 executable behaving like unix which
#  HOME -- in
#    home directory
#  LN -- in
#    ln that creates a symlink as-is
#  SEP -- in
#    path separator

/ = ${SEP}

.PHONY: build install pkg-preinstall
build:
	echo "[python3.mk] nothing to build"

install: pkg-install
	echo "[python3.mk] installed"

pkg-preinstall:

COMPONENT = python3.mk
PKG_PACKAGE = python3
PKG_MK_PATH = ../utils/pkg.mk
include ${PKG_MK_PATH}
