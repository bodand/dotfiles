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
SUDO      = ${SUDO}

COMPONENTS = python3.mk fuck.mk vim.mk zsh.mk
COMPONENT  = cd ..$/common && $(MAKE) -f "`echo $@ | sed -e "s/-install\|-build//"`.mk" "SEP=$/" "HOME=${HOME}" "LN=${LN}" "COMMON_DIR=${DIR}$/common" `echo $@ | sed -e "s/.*-\(.*\)/\1/"`

## Pseudo-Targets ##
.SILENT:
.PHONY: build install _build_components _install_components

## Default ##
build: _build_components
	echo [linux] nothing to build

## Suffix rules ##

## Phony rules ##
install: build _install_components
	echo [linux] nothing to install

${COMPONENTS:.mk=-build} ${COMPONENTS:.mk=-install}: 
	${COMPONENT}

fuck-install: python3-install

zsh-install: fuck-install

_build_components: ${COMPONENTS:.mk=-build} 

_install_components: ${COMPONENTS:.mk=-install} 

