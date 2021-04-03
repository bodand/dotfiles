# Windows Makefile
# NMake is cursed not to run from a normal terminal
# so fuck that
# POSIX compatibility
.POSIX:

## Macros ##
/ 		  	  = \\
AHK 			  = ahk2exe
LN 					= "..$/compat$/ln"
CP 					= XCOPY
STARTUP_DIR = "%APPDATA%$/Microsoft$/Windows$/Start Menu$/Programs$/Startup$/"

SCRIPTS 		= alwaysnumlock.ahk
EXECUTABLES = ${SCRIPTS:.ahk=.exe}

## Pseudo-Targets ##
.SILENT:
.SUFFIXES: .ahk .exe
.PHONY: build install

## Default ##
build: ${EXECUTABLES}

## Suffix rules ##
.ahk.exe:
	echo Compiling ${@F}
	${AHK} /in "$<" /out "$@"

## Phony rules ##
install: install.bat
	echo Installing
	for %%l in (${EXECUTABLES}) do mklink ${STARTUP_DIR}%%l "%cd%$/%%l"

