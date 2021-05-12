# POSIX compat
.POSIX:

## Macros ##
/   = ${DIR_SEP}
LN  = ${SYMLINKER} 
CWD = ${PWD}

HOME = ${SYS_USR_HOME}

FINISHED_TARGETS = ${HOME}$/.vimrc

## Pseudo-Targets ##
.SILENT:
.SUFFIXES:
.PHONY: build install

## Default ##
build:
	echo asd

${HOME}$/.vimrc: .vimrc
	${LN} ${CWD}$/.vimrc $@

## Suffix rules ##

## Phony rules ##
install: ${FINISHED_TARGETS}
	echo Installing
