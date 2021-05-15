## vim.mk ##
# Installs .vimrc in the home directory
# 
# REQUIRES
#  COMMON_DIR --
#    path to common files
#  HOME --
#    home directory
#  LN --
#    ln that creates a symlink as-is
#  SEP --
#    path separator

/ = ${SEP}

.PHONY: build install

build:
	echo "[vim.mk] nothing to build"

install: ${HOME}$/.vimrc
	echo "[vim.mk] installed"

${HOME}$/.vimrc: ${COMMON_DIR}$/.vimrc
	echo "[common] $@.."
	"${LN}" "${COMMON_DIR}$/.vimrc" "$@"
