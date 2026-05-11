# Makefile
#
# make command: GNU make
#
# Supported OS platforms:
#     Linux, UNIX, macOS (using the bash shell)
#     Windows with UNIX-like env such as CygWin (using the bash shell)
#     native Windows with CMD.EXE (the Makefile uses 'wsl bash' as a shell)
#     native Windows with WSL (using the bash shell)
#
# The following commands are used:
#     bash internal commands (rm, find, cat, mv, cp, env, sort, ls, if, which, ...)
#     python (can be overridden with PYTHON_CMD env var)
#     pip (can be overridden with PIP_CMD env var)
#     git

# No built-in rules needed:
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

# Determine the OS platform make runs on.
ifeq ($(OS),Windows_NT)
  ifdef PWD
    PLATFORM := Windows_UNIX
    SHELL := $(shell which bash)
  else
    PLATFORM := Windows_native
    SHELL := wsl bash
  endif
  .SHELLFLAGS := -c
else
  # Values: Linux, UNIX, Darwin
  PLATFORM := $(shell uname -s)
  SHELL := $(shell which bash)
  .SHELLFLAGS := -c
endif

# Python / Pip commands
ifndef PYTHON_CMD
  PYTHON_CMD := python
endif
ifndef PIP_CMD
  PIP_CMD := pip
endif

# Package level
ifndef PACKAGE_LEVEL
  PACKAGE_LEVEL := latest
endif
ifeq ($(PACKAGE_LEVEL),minimum)
  pip_level_opts := -c minimum-constraints-develop.txt -c minimum-constraints-install.txt
  pip_level_opts_new :=
else
  ifeq ($(PACKAGE_LEVEL),latest)
    pip_level_opts := --upgrade
    pip_level_opts_new := --upgrade-strategy eager
  else
    $(error Error: Invalid value for PACKAGE_LEVEL variable: $(PACKAGE_LEVEL))
  endif
endif

# Run type (normal, scheduled, release, local)
ifndef RUN_TYPE
  RUN_TYPE := local
endif

# Name of the Pypi distribution package
pypi_package_name := {[ cookiecutter.pypi_package_name ]}

# Name of the Python package used for importing
python_package_name := {[ cookiecutter.python_package_name ]}

# Package directory
package_dir := src/$(python_package_name)

# Package version (e.g. "1.8.0a1.dev10+gd013028e" during development, or "1.8.0"
# when releasing).
# Note: The package version is automatically calculated by setuptools-scm based
# on the most recent tag in the commit history, increasing the least significant
# version indicator by 1.
package_version := $(shell $(PYTHON_CMD) -m setuptools_scm)

# The version file is recreated by setuptools-scm on every build, so it is
# excluded from git, and also from some dependency lists.
version_file := $(package_dir)/_version_scm.py

# Python major and minor version as a short identifier
pymn := $(shell $(PYTHON_CMD) -c "import sys; sys.stdout.write(f'py{sys.version_info[0]}{sys.version_info[1]}')")

# Directory for the generated distribution files
dist_dir := dist

# Distribution archives (as built by 'build' tool)
bdist_file := $(dist_dir)/$(subst .,_,$(subst -,_,$(pypi_package_name)))-$(package_version)-py3-none-any.whl
sdist_file := $(dist_dir)/$(subst -,_,$(pypi_package_name))-$(package_version).tar.gz

# Vendorized files
vendor_dir := $(package_dir)/_vendor
vendor_py_files := \
    $(wildcard $(vendor_dir)/*.py) \
    $(wildcard $(vendor_dir)/*/*.py) \
		$(wildcard $(vendor_dir)/*/*/*.py) \

# Source files in the packages, excluding the $(version_file)
package_py_files := \
    $(filter-out $(version_file), $(wildcard $(package_dir)/*.py)) \
    $(wildcard $(package_dir)/*/*.py) \
    $(wildcard $(package_dir)/*/*/*.py) \

{% if cookiecutter.with_readthedocs == "Yes" %}
# Directory for generated API documentation
doc_build_dir := build_doc

# Directory where Sphinx conf.py is located
doc_conf_dir := docs

# Documentation generator command
doc_cmd := sphinx-build
doc_opts := -v -d $(doc_build_dir)/doctrees -c $(doc_conf_dir) .

# Dependents for Sphinx documentation build
doc_dependent_files := \
    $(doc_conf_dir)/conf.py \
    $(wildcard $(doc_conf_dir)/*.rst) \
{%- if cookiecutter.with_jupyter_notebook == "Yes" %}
    $(wildcard $(doc_conf_dir)/notebooks/*.ipynb) \
{%- endif %}
    $(wildcard $(doc_conf_dir)/images/*.svg) \
    $(wildcard changes/*) \
    $(package_py_files) \
    $(version_file) \

{% endif %}
# Directory with test source files
test_dir := tests

# Source files with test code
test_unit_py_files := \
    $(wildcard $(test_dir)/unit/*.py) \
    $(wildcard $(test_dir)/unit/*/*.py) \
    $(wildcard $(test_dir)/unit/*/*/*.py) \

test_function_py_files := \
    $(wildcard $(test_dir)/function/*.py) \
    $(wildcard $(test_dir)/function/*/*.py) \
		$(wildcard $(test_dir)/function/*/*/*.py) \

{% if cookiecutter.with_end2end_test == "Yes" %}
test_end2end_py_files := \
    $(wildcard $(test_dir)/end2end/*.py) \
    $(wildcard $(test_dir)/end2end/*/*.py) \
    $(wildcard $(test_dir)/end2end/*/*/*.py) \

{% endif %}
# Directory for .done files
done_dir := done

# Flake8 config file
flake8_rc_file := .flake8

# Ruff config file
ruff_rc_file := .ruff.toml

# PyLint config file
pylint_rc_file := .pylintrc

# PyLint additional options
pylint_opts := --disable=fixme

# Safety policy file (for packages needed for installation)
safety_install_policy_file := .safety-policy-install.yml
safety_develop_policy_file := .safety-policy-develop.yml

# Bandit config file
bandit_rc_file := .bandit.toml

# Source files for check (with Flake8, Ruff, PyLint)
check_py_files := \
    $(filter-out $(vendor_py_files), $(package_py_files)) \
    $(test_unit_py_files) \
    $(test_function_py_files) \
{%- if cookiecutter.with_end2end_test == "Yes" %}
    $(test_end2end_py_files) \
{%- endif %}
{%- if cookiecutter.with_readthedocs == "Yes" %}
    $(doc_conf_dir)/conf.py \
{%- endif %}
{%- if cookiecutter.with_jupyter_notebook == "Yes" %}
    $(wildcard docs/notebooks/*.py) \
{%- endif %}

# Packages whose dependencies are checked using pip-missing-reqs
check_reqs_packages := \
    pip_check_reqs \
    virtualenv \
    tox \
    pipdeptree \
    build \
    pytest \
    coverage \
    coveralls \
    flake8 \
    ruff \
    pylint \
    safety \
    bandit \
{%- if cookiecutter.with_jupyter_notebook == "Yes" %}
    jupyter \
    notebook \
{%- endif %}
{%- if cookiecutter.with_readthedocs == "Yes" %}
    sphinx \
{%- endif %}
{%- if cookiecutter.with_changelog == "Yes" and cookiecutter.with_readthedocs == "Yes" %}
    towncrier \
{%- endif %}

# Pytest options
pytest_general_opts := -s --color=yes
ifdef TESTCASES
  pytest_test_opts := $(TESTOPTS) -k '$(TESTCASES)'
else
  pytest_test_opts := $(TESTOPTS)
endif

# Coverage config file
coverage_config_file := .coveragerc

# Files the distribution archives depend upon
dist_dependent_files := \
    pyproject.toml \
    LICENSE \
    README.md \
    AUTHORS.md \
    requirements.txt \
    $(package_py_files) \

.PHONY: help
help:
	@echo "Makefile for $(pypi_package_name) project"
	@echo "Package version will be: $(package_version)"
	@echo ""
	@echo "Make targets:"
	@echo "  install           - Install package in active Python environment (non-editable)"
	@echo "  develop           - Prepare the development environment by installing prerequisites"
	@echo "  flake8            - Run Flake8 on sources"
	@echo "  ruff              - Run Ruff (an alternate lint tool) on sources"
	@echo "  pylint            - Run PyLint on sources"
	@echo "  check_reqs        - Perform missing dependency checks"
	@echo "  safety            - Run safety checker"
	@echo "  bandit            - Run bandit checker"
	@echo "  unittest          - Run unit tests (adds to coverage results)"
	@echo "  functiontest      - Run function tests (adds to coverage results)"
{%- if cookiecutter.with_install_test == "Yes" %}
	@echo "  installtest       - Run install tests"
{%- endif %}
	@echo "  build             - Build the distribution files in: $(dist_dir)"
{%- if cookiecutter.with_readthedocs == "Yes" %}
	@echo "  builddoc          - Build documentation in: $(doc_build_dir)"
	@echo "  doclinkcheck      - Run check for validity of doc links"
{%- endif %}
	@echo "  all               - Combined target: Do all of the above"
	@echo "  test              - Combined target: unittest, functiontest"
	@echo "  check             - Combined target: flake8, ruff, pylint"
{%- if cookiecutter.with_end2end_test == "Yes" %}
	@echo "  end2end           - Run end2end tests (adds to coverage results, checks blanked-out properties in log)"
{%- endif %}
	@echo "  authors           - Generate AUTHORS.md file from git log"
	@echo "  uninstall         - Uninstall package from active Python environment"
	@echo "  release_branch    - Create a release branch when releasing a version (requires VERSION and optionally BRANCH to be set)"
	@echo "  release_publish   - Publish to PyPI when releasing a version (requires VERSION and optionally BRANCH to be set)"
	@echo "  start_branch      - Create a start branch when starting a new version (requires VERSION and optionally BRANCH to be set)"
	@echo "  start_tag         - Create a start tag when starting a new version (requires VERSION and optionally BRANCH to be set)"
	@echo "  clean             - Remove any temporary files"
	@echo "  clobber           - Remove any temporary files and build products"
	@echo "  platform          - Display the information about the platform as seen by make"
	@echo "  env               - Display the environment as seen by make"
	@echo "  pip_list          - Display the installed Python packages as seen by make"
	@echo ""
	@echo "Environment variables:"
	@echo "  TESTCASES=...     - Testcase filter for pytest -k"
	@echo "  TESTOPTS=...      - Options for pytest"
	@echo "  PACKAGE_LEVEL     - Package level to be used for installing dependent Python"
	@echo "      packages in 'install' and 'develop' targets:"
	@echo "        latest        - Latest package versions available on Pypi"
	@echo "        minimum       - Minimum versions as defined in minimum-constraints*.txt"
	@echo "      Optional, defaults to 'latest'."
	@echo "  PYTHON_CMD=...    - Name of python command. Default: python"
	@echo "  PIP_CMD=...       - Name of pip command. Default: pip"
	@echo "  VERSION=...       - M.N.U version to be released or started"
	@echo "  BRANCH=...        - Name of branch to be released or started (default is derived from VERSION)"

.PHONY: _always
_always:

.PHONY: all
all: install develop flake8 ruff pylint check_reqs safety bandit unittest functiontest{%- if cookiecutter.with_install_test == "Yes" %} installtest{%- endif %} build{%- if cookiecutter.with_readthedocs == "Yes" %} builddoc doclinkcheck{%- endif %}
	@echo "Makefile: $@ done."

.PHONY: test
test: unittest functiontest
	@echo "Makefile: $@ done."

.PHONY: check
check: flake8 ruff pylint
	@echo "Makefile: $@ done."

.PHONY: platform
platform:
ifeq ($(PLATFORM),Linux)
	@echo "Makefile: Installing ld to get Linux distributions"
	$(PYTHON_CMD) -m pip -q install ld
endif
	@echo "Makefile: Platform information as seen by make:"
	@echo "Platform detected by Makefile: $(PLATFORM)"
	@$(PYTHON_CMD) -c "import platform; print(f'Platform detected by Python: {platform.platform()}')"
	@$(PYTHON_CMD) -c "import platform; print(f'HW platform detected by Python: {platform.machine()}')"
ifeq ($(PLATFORM),Linux)
	@$(PYTHON_CMD) -c "import ld; d=ld.linux_distribution(); print(f'Linux distro detected by ld: {d[0]} {d[1]}')"
endif
	@echo "Shell used for make commands: $(SHELL)"
	@echo "Shell flags used for make commands: $(.SHELLFLAGS)"
	@echo ""
	@echo "Shell version:"
	$(SHELL) --version
	@echo ""
	@echo "Make version: $(MAKE_VERSION)"
	@echo "Python command name: $(PYTHON_CMD)"
	@echo "Python command location: $(shell which $(PYTHON_CMD))"
	@echo "Python version: $(shell $(PYTHON_CMD) --version)"
	@echo "Pip command name: $(PIP_CMD)"
	@echo "Pip command location: $(shell which $(PIP_CMD))"
	@echo "Pip version: $(shell $(PIP_CMD) --version)"

.PHONY: env
env:
	@echo "Makefile: Environment variables as seen by make:"
	env | sort

.PHONY: pip_list
pip_list:
	@echo "Makefile: Python packages as seen by make:"
	$(PIP_CMD) list

$(done_dir)/base_$(pymn)_$(PACKAGE_LEVEL).done: requirements-base.txt minimum-constraints-develop.txt minimum-constraints-install.txt
	rm -f $@
	@echo "Makefile: Installing/upgrading pip, setuptools and wheel with PACKAGE_LEVEL=$(PACKAGE_LEVEL)"
	$(PYTHON_CMD) -m pip install $(pip_level_opts) -r requirements-base.txt
	echo "done" >$@

.PHONY: install
install: $(done_dir)/install_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: $@ done."

$(done_dir)/install_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/base_$(pymn)_$(PACKAGE_LEVEL).done requirements.txt minimum-constraints-develop.txt minimum-constraints-install.txt $(dist_dependent_files)
	rm -f $@
	@echo "Makefile: Installing $(pypi_package_name) (non-editable) and runtime reqs with PACKAGE_LEVEL=$(PACKAGE_LEVEL)"
	$(PYTHON_CMD) -m pip install $(pip_level_opts) $(pip_level_opts_new) .
	$(PYTHON_CMD) -c "import $(python_package_name); print('ok')"
	echo "done" >$@

.PHONY: develop
develop: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: $@ done."

$(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/base_$(pymn)_$(PACKAGE_LEVEL).done requirements-develop.txt minimum-constraints-develop.txt minimum-constraints-install.txt
	rm -f $@
	@echo "Makefile: Installing development requirements with PACKAGE_LEVEL=$(PACKAGE_LEVEL)"
	$(PYTHON_CMD) -m pip install $(pip_level_opts) $(pip_level_opts_new) -r requirements-develop.txt
	echo "done" >$@
	@echo "Makefile: Done installing development requirements"

.PHONY: flake8
flake8: $(done_dir)/flake8_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: $@ done."

$(done_dir)/flake8_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done $(flake8_rc_file) $(check_py_files)
	@echo "Makefile: Running Flake8"
	rm -f $@
	flake8 $(check_py_files)
	echo "done" >$@
	@echo "Makefile: Done running Flake8"

.PHONY: ruff
ruff: $(done_dir)/ruff_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: $@ done."

$(done_dir)/ruff_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done $(ruff_rc_file) $(check_py_files)
	@echo "Makefile: Running Ruff"
	rm -f $@
	ruff check --unsafe-fixes --config $(ruff_rc_file) $(check_py_files)
	echo "done" >$@
	@echo "Makefile: Done running Ruff"

.PHONY: pylint
pylint: $(done_dir)/pylint_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: $@ done."

$(done_dir)/pylint_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done $(pylint_rc_file) $(check_py_files)
	@echo "Makefile: Running Pylint"
	rm -f $@
	pylint $(pylint_opts) --rcfile=$(pylint_rc_file) --output-format=text $(check_py_files)
	echo "done" >$@
	@echo "Makefile: Done running Pylint"

.PHONY: check_reqs
check_reqs: $(done_dir)/check_reqs_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: $@ done."

$(done_dir)/check_reqs_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done minimum-constraints-develop.txt minimum-constraints-install.txt requirements.txt
	rm -f $@
	@echo "Makefile: Checking missing dependencies of this package"
	pip-missing-reqs $(pypi_package_name) --ignore-module $(python_package_name) --requirements-file=requirements.txt
	pip-missing-reqs $(pypi_package_name) --ignore-module $(python_package_name) --requirements-file=minimum-constraints-install.txt
	@echo "Makefile: Done checking missing dependencies of this package"
ifeq ($(PLATFORM),Windows_native)
# Reason for skipping on Windows is https://github.com/r1chardj0n3s/pip-check-reqs/issues/67
	@echo "Makefile: Warning: Skipping the checking of missing dependencies of site-packages directory on native Windows" >&2
else
	@echo "Makefile: Checking missing dependencies of some development packages in our minimum versions"
	cat minimum-constraints-develop.txt minimum-constraints-install.txt >tmp_minimum-constraints.txt
	@rc=0; for pkg in $(check_reqs_packages); do dir=$$($(PYTHON_CMD) -c "import $${pkg} as m,os; dm=os.path.dirname(m.__file__); d=dm if not dm.endswith('site-packages') else m.__file__; print(d)"); cmd="pip-missing-reqs $${dir} --requirements-file=tmp_minimum-constraints.txt"; echo $${cmd}; $${cmd}; rc=$$(expr $${rc} + $${?}); done; exit $${rc}
	rm -f tmp_minimum-constraints.txt
	@echo "Makefile: Done checking missing dependencies of some development packages in our minimum versions"
endif
	echo "done" >$@

.PHONY: safety
safety: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done $(safety_develop_policy_file) $(safety_install_policy_file) minimum-constraints-develop.txt minimum-constraints-install.txt
	safety check --policy-file $(safety_develop_policy_file) -r minimum-constraints-develop.txt --full-report || test '$(RUN_TYPE)' == 'normal' || test '$(RUN_TYPE)' == 'scheduled' || exit 1
	safety check --policy-file $(safety_install_policy_file) -r minimum-constraints-install.txt --full-report || test '$(RUN_TYPE)' == 'normal' || exit 1
	@echo "Makefile: $@ done."

.PHONY: bandit
bandit: $(done_dir)/bandit_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: $@ done."

$(done_dir)/bandit_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done $(bandit_rc_file) $(check_py_files)
	@echo "Makefile: Running Bandit"
	rm -f $@
	bandit -c $(bandit_rc_file) -l -r $(python_package_name)
	echo "done" >$@
	@echo "Makefile: Done running Bandit"

.PHONY: unittest
unittest: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done $(package_py_files) $(test_unit_py_files) $(coverage_config_file)
	PYTHONPATH=. coverage run --append -m pytest $(pytest_general_opts) $(pytest_test_opts) $(test_dir)/unit
	coverage html
	@echo "Makefile: $@ done."

.PHONY: functiontest
functiontest: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done $(package_py_files) $(test_function_py_files) $(coverage_config_file)
	PYTHONPATH=. coverage run --append -m pytest $(pytest_general_opts) $(pytest_test_opts) $(test_dir)/function
	coverage html
	@echo "Makefile: $@ done."

{% if cookiecutter.with_install_test == "Yes" %}
.PHONY: installtest
installtest: $(bdist_file) $(sdist_file) $(test_dir)/install/test_install.sh
ifeq ($(PLATFORM),Windows_native)
	@echo "Makefile: Warning: Skipping install test on native Windows" >&2
else
	@echo "Makefile: Running install tests"
	$(test_dir)/install/test_install.sh $(bdist_file) $(sdist_file) $(PYTHON_CMD)
	@echo "Makefile: Done running install tests"
endif
	@echo "Makefile: $@ done."

{% endif %}
{% if cookiecutter.with_end2end_test == "Yes" %}
.PHONY:	end2end
end2end: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done $(package_py_files) $(test_end2end_py_files) $(coverage_config_file)
	rm -f end2end.log
	PYTHONPATH=. TESTLOGFILE=end2end.log TESTEND2END_LOAD=true coverage run --append -m pytest -v -m 'not check_hmcs' $(pytest_general_opts) $(pytest_test_opts) $(test_dir)/end2end
	coverage html
	tools/check_blanked.py --accept-null end2end.log
	@echo "Makefile: $@ done."

{% endif %}
.PHONY: build
build: $(bdist_file) $(sdist_file)
	@echo "Makefile: $@ done."

$(sdist_file): $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done $(dist_dependent_files)
	@echo "Makefile: Building the source distribution archive: $(sdist_file)"
	$(PYTHON_CMD) -m build --no-isolation --sdist --outdir $(dist_dir) .
	ls -l $(sdist_file) || ls -l $(dist_dir) && echo package_level=$(package_level) && $(PYTHON_CMD) -m setuptools_scm
	@echo "Makefile: Done building the source distribution archive: $(sdist_file)"

$(bdist_file) $(version_file): $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done $(dist_dependent_files)
	@echo "Makefile: Building the wheel distribution archive: $(bdist_file)"
	$(PYTHON_CMD) -m build --no-isolation --wheel --outdir $(dist_dir) -C--universal .
	ls -l $(bdist_file) $(version_file) || ls -l $(dist_dir) && echo package_level=$(package_level) && $(PYTHON_CMD) -m setuptools_scm
	@echo "Makefile: Done building the wheel distribution archive: $(bdist_file)"

{% if cookiecutter.with_readthedocs == "Yes" %}
.PHONY: builddoc
builddoc: $(doc_build_dir)/html/docs/index.html
	@echo "Makefile: $@ done."

$(doc_build_dir)/html/docs/index.html: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done $(doc_dependent_files)
	@echo "Makefile: Running Sphinx to create HTML pages"
	rm -f $@
	$(doc_cmd) -b html $(doc_opts) $(doc_build_dir)/html
	@echo
	@echo "Makefile: Done running Sphinx to create HTML pages"

.PHONY: doclinkcheck
doclinkcheck: $(doc_dependent_files)
	@echo "Makefile: Running Sphinx to check the doc links"
	$(doc_cmd) -b linkcheck $(doc_opts) $(doc_build_dir)/linkcheck; rc=$$?; if [ $$rc -ne 0 ]; then echo "::notice::doclinkcheck failed (ignored)"; fi
	@echo
	@echo "Makefile: Done running Sphinx to check the doc links"
	@echo "Makefile: Look for any errors in the above output or in: $(doc_build_dir)/linkcheck/output.txt"
	@echo "Makefile: $@ done."

{% endif %}
.PHONY: authors
authors: AUTHORS.md
	@echo "Makefile: $@ done."

# In the logic below, we make sure that the AUTHORS.md file is up to date but
# has the old date when it did not change.
AUTHORS.md: _always
	echo "# Authors of this project" >AUTHORS.md.tmp
	echo "" >>AUTHORS.md.tmp
	echo "Sorted list of authors derived from git commit history:" >>AUTHORS.md.tmp
	echo '```' >>AUTHORS.md.tmp
	git shortlog --summary --email HEAD | cut -f 2 | LC_ALL=C.UTF-8 sort >>AUTHORS.md.tmp
	echo '```' >>AUTHORS.md.tmp
	if ! diff -q AUTHORS.md.tmp AUTHORS.md; then echo 'Updating AUTHORS.md as follows:'; diff AUTHORS.md.tmp AUTHORS.md; mv AUTHORS.md.tmp AUTHORS.md; else echo 'AUTHORS.md was already up to date'; rm AUTHORS.md.tmp; fi

.PHONY: uninstall
uninstall:
	$(PIP_CMD) show $(pypi_package_name) >/dev/null; if [ $$? -eq 0 ]; then $(PIP_CMD) uninstall -y $(pypi_package_name); fi
	@echo "Makefile: $@ done."

.PHONY: clean
clean:
	find . -type f -name '*.pyc' -delete
	find . -type f -name '*.tmp' -delete
	find . -type f -name 'tmp_*' -delete
	find . -type f -name '.DS_Store' -delete
	find . -type d -name '__pycache__' | xargs -n 1 rm -rf
	find . -type d -name '.pytest_cache' | xargs -n 1 rm -rf
	find . -type d -name '.ruff_cache' | xargs -n 1 rm -rf
	rm -f MANIFEST MANIFEST.in AUTHORS ChangeLog .coverage
	rm -rf build .cache $(pypi_package_name).egg-info .eggs
	@echo "Makefile: $@ done."

.PHONY: clobber
clobber: clean
	rm -f $(bdist_file) $(sdist_file)
	find . -type f -name '*.done' -delete
{%- if cookiecutter.with_readthedocs == "Yes" %}
	rm -rf $(doc_build_dir)
{%- endif %}
	rm -rf htmlcov .tox
	@echo "Makefile: $@ done."

.PHONY: release_branch
release_branch:
	@if [ -z "$(VERSION)" ]; then echo ""; echo "Error: VERSION env var is not set"; echo ""; false; fi
	@if [ -n "$$(git status -s)" ]; then echo ""; echo "Error: Local git repo has uncommitted files:"; echo ""; git status; false; fi
	git fetch origin
	@if [ -z "$$(git tag -l $(VERSION)a0)" ]; then echo ""; echo "Error: Release start tag $(VERSION)a0 does not exist (the version has not been started)"; echo ""; false; fi
	@if [ -n "$$(git tag -l $(VERSION))" ]; then echo ""; echo "Error: Release tag $(VERSION) already exists (the version has already been released)"; echo ""; false; fi
	@if [[ -n "$${BRANCH}" ]]; then echo $${BRANCH} >branch.tmp; elif [[ "$${VERSION#*.*.}" == "0" ]]; then echo "master" >branch.tmp; else echo "stable_$${VERSION%.*}" >branch.tmp; fi
	@if [ -z "$$(git branch --contains $(VERSION)a0 $$(cat branch.tmp))" ]; then echo ""; echo "Error: Release start tag $(VERSION)a0 is not in target branch $$(cat branch.tmp), but in:"; echo ""; git branch --contains $(VERSION)a0;. false; fi
	@echo "==> This will start the release of $(pypi_package_name) version $(VERSION) to PyPI using target branch $$(cat branch.tmp)"
	@echo -n '==> Continue? [yN] '
	@read answer; if [ "$$answer" != "y" ]; then echo "Aborted."; false; fi
	git checkout $$(cat branch.tmp)
	git pull
	@if [ -z "$$(git branch -l release_$(VERSION))" ]; then echo "Creating release branch release_$(VERSION)"; git checkout -b release_$(VERSION); fi
	git checkout release_$(VERSION)
	make authors
{%- if cookiecutter.with_changelog == "Yes" and cookiecutter.with_readthedocs == "Yes" %}
	towncrier build --version $(VERSION) --yes
	@if ls changes/*.rst >/dev/null 2>/dev/null; then echo ""; echo "Error: There are incorrectly named change fragment files that towncrier did not use:"; ls -1 changes/*.rst; echo ""; false; fi
{%- endif %}
	git commit -asm "Release $(VERSION)"
	git push --set-upstream origin release_$(VERSION)
	rm -f branch.tmp
	@echo "Makefile: Pushed the release branch to GitHub - now go there and create a PR."
	@echo "Makefile: $@ done."

.PHONY: release_publish
release_publish:
	@if [ -z "$(VERSION)" ]; then echo ""; echo "Error: VERSION env var is not set"; echo ""; false; fi
	@if [ -n "$$(git status -s)" ]; then echo ""; echo "Error: Local git repo has uncommitted files:"; echo ""; git status; false; fi
	git fetch origin
	@if [ -n "$$(git tag -l $(VERSION))" ]; then echo ""; echo "Error: Release tag $(VERSION) already exists (the version has already been released)"; echo ""; false; fi
	@if [[ -n "$${BRANCH}" ]]; then echo $${BRANCH} >branch.tmp; elif [[ "$${VERSION#*.*.}" == "0" ]]; then echo "master" >branch.tmp; else echo "stable_$${VERSION%.*}" >branch.tmp; fi
	@if ! git show-ref --quiet refs/remotes/origin/$$(cat branch.tmp); then echo ""; echo "Error: Branch origin/$$(cat branch.tmp) does not exist. Incorrect VERSION env var?"; echo ""; false; fi
	@if [[ ! $$(git log --format=format:%s origin/$$(cat branch.tmp)~..origin/$$(cat branch.tmp)) =~ ^Release\ $(VERSION) ]]; then echo ""; echo "Error: Release PR for $(VERSION) has not been merged yet"; echo ""; false; fi
	@echo "==> This will publish $(pypi_package_name) version $(VERSION) to PyPI using target branch $$(cat branch.tmp)"
	@echo -n '==> Continue? [yN] '
	@read answer; if [ "$$answer" != "y" ]; then echo "Aborted."; false; fi
	git checkout $$(cat branch.tmp)
	git pull
	git tag -f $(VERSION)
	git push -f --tags
	-git branch -D release_$(VERSION)
	-git branch -D -r origin/release_$(VERSION)
	rm -f branch.tmp
	@echo "Makefile: Triggered the publish workflow - now wait for it to finish and verify the publishing."
	@echo "Makefile: $@ done."

.PHONY: start_branch
start_branch:
	@if [ -z "$(VERSION)" ]; then echo ""; echo "Error: VERSION env var is not set"; echo ""; false; fi
	@if [ -n "$$(git status -s)" ]; then echo ""; echo "Error: Local git repo has uncommitted files:"; echo ""; git status; false; fi
	git fetch origin
	@if [ -n "$$(git tag -l $(VERSION))" ]; then echo ""; echo "Error: Release tag $(VERSION) already exists (the version has already been released)"; echo ""; false; fi
	@if [ -n "$$(git tag -l $(VERSION)a0)" ]; then echo ""; echo "Error: Release start tag $(VERSION)a0 already exists (the new version has alreay been started)"; echo ""; false; fi
	@if [ -n "$$(git branch -l start_$(VERSION))" ]; then echo ""; echo "Error: Start branch start_$(VERSION) already exists (the start of the new version is already underway)"; echo ""; false; fi
	@if [[ -n "$${BRANCH}" ]]; then echo $${BRANCH} >branch.tmp; elif [[ "$${VERSION#*.*.}" == "0" ]]; then echo "master" >branch.tmp; else echo "stable_$${VERSION%.*}" >branch.tmp; fi
	@echo "==> This will start new version $(VERSION) using target branch $$(cat branch.tmp)"
	@echo -n '==> Continue? [yN] '
	@read answer; if [ "$$answer" != "y" ]; then echo "Aborted."; false; fi
	git checkout $$(cat branch.tmp)
	git pull
	git checkout -b start_$(VERSION)
	echo "Dummy change for starting new version $(VERSION)" >changes/noissue.$(VERSION).notshown.rst
	git add changes/noissue.$(VERSION).notshown.rst
	git commit -asm "Start $(VERSION)"
	git push --set-upstream origin start_$(VERSION)
	rm -f branch.tmp
	@echo "Makefile: Pushed the start branch to GitHub - now go there and create a PR."
	@echo "Makefile: $@ done."

.PHONY: start_tag
start_tag:
	@if [ -z "$(VERSION)" ]; then echo ""; echo "Error: VERSION env var is not set"; echo ""; false; fi
	@if [ -n "$$(git status -s)" ]; then echo ""; echo "Error: Local git repo has uncommitted files:"; echo ""; git status; false; fi
	git fetch origin
	@if [ -n "$$(git tag -l $(VERSION)a0)" ]; then echo ""; echo "Error: Release start tag $(VERSION)a0 already exists (the new version has alreay been started)"; echo ""; false; fi
	@if [[ -n "$${BRANCH}" ]]; then echo $${BRANCH} >branch.tmp; elif [[ "$${VERSION#*.*.}" == "0" ]]; then echo "master" >branch.tmp; else echo "stable_$${VERSION%.*}" >branch.tmp; fi
	@if ! git show-ref --quiet refs/remotes/origin/$$(cat branch.tmp); then echo ""; echo "Error: Branch origin/$$(cat branch.tmp) does not exist. Incorrect VERSION env var?"; echo ""; false; fi
	@if [[ ! $$(git log --format=format:%s origin/$$(cat branch.tmp)~..origin/$$(cat branch.tmp)) =~ ^Start\ $(VERSION) ]]; then echo ""; echo "Error: Start PR for $(VERSION) has not been merged yet"; echo ""; false; fi
	@echo "==> This will complete the start of new version $(VERSION) using target branch $$(cat branch.tmp)"
	@echo -n '==> Continue? [yN] '
	@read answer; if [ "$$answer" != "y" ]; then echo "Aborted."; false; fi
	git checkout $$(cat branch.tmp)
	git pull
	git tag -f $(VERSION)a0
	git push -f --tags
	-git branch -D start_$(VERSION)
	-git branch -D -r origin/start_$(VERSION)
	rm -f branch.tmp
	@echo "Makefile: Pushed the release start tag and cleaned up the release start branch."
	@echo "Makefile: $@ done."
