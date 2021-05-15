## vim.mk ##
# Installs .vimrc in the home directory
# 
# REQUIRES
#  COMMON_DIR -- in
#    path to common files
#  HOME -- in
#    home directory
#  LN -- in
#    ln that creates a symlink as-is
#  SEP -- in
#    path separator

/ = ${SEP}

INSTALL_FILES = ${HOME}$/.zshrc ${HOME}$/.p10k.zsh ${HOME}$/.zgen$/zgen.zsh

build:
	echo "[zsh.mk] nothing to build"

install: ${INSTALL_FILES}
	echo "[zsh.mk] installed"

${HOME}$/.zshrc: ${COMMON_DIR}$/.zshrc ${HOME}$/.p10k.zsh
	echo "[zsh.mk] $@.."
	"${LN}" "${COMMON_DIR}$/.zshrc" "$@"

${HOME}$/.p10k.zsh: ${COMMON_DIR}$/.p10k.zsh
	echo "[zsh.mk] $@.."
	"${LN}" "${COMMON_DIR}$/.p10k.zsh" "$@"

${HOME}$/.zgen$/zgen.zsh: 
	echo "[zsh.mk] $@.."
	if test ! -f "$@" ; then git clone https://github.com/tarjoilija/zgen.git "${@D}" ; else cd "${@D}" && git pull --ff-only ; fi

