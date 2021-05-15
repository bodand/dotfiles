# Windows Makefile
# NMake is cursed not to run from a normal terminal
# so fuck that
# POSIX compatibility
.POSIX:

## Macros ##
# imported
/         = ${DIR_SEP}
HOME      = ${SYS_USR_HOME}
LN        = ${SYMLINKER}
DIR       = ${DIRECTORY}
WHICH_EXE = ${WHICH_EXE}
# ours
AHK         = ahk2exe
STARTUP_DIR = "%APPDATA%$/Microsoft$/Windows$/Start Menu$/Programs$/Startup$/"

SCRIPTS     = alwaysnumlock.ahk
EXECUTABLES = ${SCRIPTS:.ahk=.exe}

COMMONS    = vim
DO_COMMONS = for %%c in (${COMMONS}) do chdir ..$/common && $(MAKE) -f vim.mk "SEP=$/" "HOME=${HOME}" "LN=${LN}" "COMMON_DIR=${DIR}$/common" "$@"

## Pseudo-Targets ##
.SILENT:
.SUFFIXES: .ahk .exe
.PHONY: build build-premsg install

## Default ##
build: build-premsg ${EXECUTABLES}
	echo [MSWin32] built
	${DO_COMMONS}

## Suffix rules ##
.ahk.exe:
	echo compiling ${@F}..
	${AHK} /in "$<" /out "$@"
	echo compiled

## Phony rules ##
install: build
	echo [MSWin32] installing..
	for %%l in (${EXECUTABLES}) do mklink ${STARTUP_DIR}%%l "%cd%$/%%l"
	${DO_COMMONS}
	echo [MSWin32] installed

build-premsg:
	echo [MSWin32] building..

