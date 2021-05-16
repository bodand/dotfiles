## vim.mk ##
# Installs .vimrc in the home directory
# 
# REQUIRES
#  SUDO --
#    system sudo equivalent
#  COMMON_DIR --
#    path to common files
#  HOME --
#    home directory
#  LN --
#    ln that creates a symlink as-is
#  SEP --
#    path separator

COMPONENT = vim.mk
/ = ${SEP}

.PHONY: build install pkg-preinstall

pkg-preinstall:

build:
	echo "[vim.mk] nothing to build"

install: pkg-install ${HOME}$/.vimrc
	echo "[vim.mk] installed"

${HOME}$/.vimrc: ${COMMON_DIR}$/.vimrc
	echo "[vim.mk] $@.."
	"${LN}" "${COMMON_DIR}$/.vimrc" "$@"

PKG_PACKAGE = vim
PKG_MK_PATH = ../utils/pkg.mk
include ${PKG_MK_PATH}

