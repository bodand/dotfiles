## Universal package manager ##
# Installs a package using the system package manager
#
# Supported package managers: 
#  apt, dnf, pacman, pkg (FreeBSD), pkg_add (OpenBSD)
#
# Already installed packages are updated, if possible.
#
# REQUIRES
#   MACROS
#     WHICH_EXE --
#       a unix compatible which exectuable
#     SUDO --
#       the system command privilige elevator
#     PKG_MK_PATH --
#       relative path to the called pkg.mk script
#     COMPONENT -- string
#       the name of the component pkg.mk is working for
#     PKG_PACKAGE -- array
#       the list of packages to install. Each are checked individually.
#   TARGETS
#     pkg-preinstall --
#       target the install target depends on for pre install configurations
# PROVIDES
#   TARGETS
#     pkg-install --
#       target which installs the required packages
.PHONY: pkg-install

_PKG_SILENCE = >/dev/null 2>/dev/null
pkg-install: pkg-preinstall
	for pkg in ${PKG_PACKAGE} ; do \
		echo "[${COMPONENT}] pkg: $$pkg.."; \
		if "${WHICH_EXE}" apt ${_PKG_SILENCE}; then \
			$(MAKE) -f "${PKG_MK_PATH}" "SUDO=${SUDO}" "_PKG_PACKAGE=$$pkg" _pkg_apt; \
		elif "${WHICH_EXE}" dnf ${_PKG_SILENCE}; then \
			$(MAKE) -f "${PKG_MK_PATH}" "SUDO=${SUDO}" "_PKG_PACKAGE=$$pkg" _pkg_dnf; \
		elif "${WHICH_EXE}" pacman ${_PKG_SILENCE}; then \
			$(MAKE) -f "${PKG_MK_PATH}" "SUDO=${SUDO}" "_PKG_PACKAGE=$$pkg" _pkg_pacman; \
		elif "${WHICH_EXE}" pkg ${_PKG_SILENCE}; then \
			$(MAKE) -f "${PKG_MK_PATH}" "SUDO=${SUDO}" "_PKG_PACKAGE=$$pkg" _pkg_pkg_free; \
		elif "${WHICH_EXE}" pkg ${_PKG_SILENCE}; then \
			$(MAKE) -f "${PKG_MK_PATH}" "SUDO=${SUDO}" "_PKG_PACKAGE=$$pkg" _pkg_pkg_open; \
		else \
			echo "[${COMPONENT}] pkg: unkown package manager. fail" && exit 1; \
		fi; \
		echo "[${COMPONENT}] pkg: installed"; \
	done

## Private targets
.PHONY: _pkg_apt _pkg_dnf _pkg_pacman _pkg_pkg_free _pkg_pkg_open

# rhel/fedora dnf
_pkg_dnf:
	if test -n "`dnf info ${_PKG_PACKAGE} 2>&1 | grep Error`"; then \
	 	${SUDO} dnf install -y ${_PKG_PACKAGE}; \
	else \
	  ${SUDO} dnf update -y ${_PKG_PACKAGE}; \
	fi 

# debian/ubuntu apt
_pkg_apt:
	${SUDO} apt-get install -y ${_PKG_PACKAGE}; \

# freebsd pkg
_pkg_pkg_free:
	if test -n "`pkg info ${_PKG_PACKAGE} 2>&1 | grep -i error`"; then \
		${SUDO} pkg add ${_PKG_PACKAGE}; \
	else \
		${SUDO} pkg upgrade ${_PKG_PACKAGE}; \
	fi

# openbsd pkg_add
_pkg_pkg_open:
	if test -z "`pkg_info ${_PKG_PACKAGE}`"; then \
		${SUDO} pkg_add ${_PKG_PACKAGE}; \
	else
		${SUDO} pkg_add -u ${_PKG_PACKAGE}; \
	fi

# arch pacman
_pkg_pacman:
	${SUDO} pacman -Sy --noconfirm ${_PKG_PACKAGE}
