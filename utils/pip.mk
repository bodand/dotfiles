## pip package install ##
# A Make helper script that installs pip
# packages
#
# REQUIRES
#  TARGETS
#    pip-prebuild -- target
#      target for pre build scripts
#    pip-preinstall -- target
#      target for pre install scripts
#  
#  MACROS
#    WHICH_EXE --
#      a unix which compatible executable
#    COMPONENT -- string
#      the name of the component we provide pip install support
#    PIP_PACKAGE -- make array
#      the name of the packages to install
#  
#  ENVIRONMENT
#    pip3 or pip installed with a python
#
# PROVIDES
#   pip-build -- target
#     a target which depends on pip-prebuild and prints
#     "pip: nothing to build"
#   pip-install -- target
#     a target which depends on pip-preinstall and installs
#     the requested pip packages from pip3 or pip

pip-build: pip-prebuild
	echo "[${COMPONENT}] pip: nothing to build"

_PIP_ARGUMENTS = install $$pkg
pip-install: pip-preinstall
	for pkg in ${PIP_PACKAGE} ; do \
		echo "[${COMPONENT}] pip: $$pkg.."; \
		if which pip3 2>&1 > /dev/null; then \
			pip3 show $$pkg || pip3 ${_PIP_ARGUMENTS}; \
		else \
			pip show $$pkg || pip ${_PIP_ARGUMENT}; \
		fi; \
		echo "[${COMPONENT}] pip: installed $$pkg"; \
	done
