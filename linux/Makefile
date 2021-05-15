# linux Makefile
# POSIX compatibility
.POSIX:

## Macros ##
# imported
/         = ${DIR_SEP}
HOME      = ${SYS_USR_HOME}
LN        = ${SYMLINKER}
DIR       = ${DIRECTORY}
WHICH_EXE = ${WHICH_EXE}

COMMONS    = fuck vim zsh
DO_COMMONS = for comm in ${COMMONS} ; do cd ..$/common && $(MAKE) -f $$comm.mk "SEP=$/" "HOME=${HOME}" "LN=${LN}" "COMMON_DIR=${DIR}$/common" "$@"; done

## Pseudo-Targets ##
.SILENT:
.PHONY: build install

## Default ##
build:
	echo [linux] nothing to build
	+${DO_COMMONS}

## Suffix rules ##

## Phony rules ##
install: build
	echo [linux] nothing to install
	+${DO_COMMONS}
