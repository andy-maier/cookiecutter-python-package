Installation
============

[% if cookiecutter.package_type == 'Library' %]
To install the latest released version of the
[[ cookiecutter.project_name ]] project into your active Python environment:

      $ pip install [[ cookiecutter.pypi_package_name ]]
[% else %][# CLI #]
To install the latest released version of the
[[ cookiecutter.project_name ]] project into your system without having any
virtual Python environment active:

      $ pipx install [[ cookiecutter.pypi_package_name ]]
[% endif %]

This will also install any prerequisite Python packages.

For more details and alternative ways to install, see
[Installation](https://<readthedocs_name>.readthedocs.io/en/stable/intro.html#installation).
