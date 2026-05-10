# zhmcclient - A pure Python client library for the IBM Z HMC Web Services API

[![Version on Pypi](https://img.shields.io/pypi/v/zhmcclient.svg)](https://pypi.python.org/pypi/{[ cookiecutter.pypi_package_name ]}/)
[![Test status (main)](https://github.com/{[ cookiecutter.github_org ]}/{[ cookiecutter.github_repo ]}/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/{[ cookiecutter.github_org ]}/{[ cookiecutter.github_repo ]}/actions/workflows/test.yml?query=branch%3Amaster)
[![Docs status (main)](https://readthedocs.org/projects/python-zhmcclient/badge/?version=latest)](https://readthedocs.org/projects/python-zhmcclient/builds/)
[![Test coverage (main)](https://coveralls.io/repos/github/{[ cookiecutter.github_org ]}/{[ cookiecutter.github_repo ]}/badge.svg?branch=main)](https://coveralls.io/github/{[ cookiecutter.github_org ]}/{[ cookiecutter.github_repo ]}?branch=main)
[![CodeClimate status](https://codeclimate.com/github/{[ cookiecutter.github_org ]}/{[ cookiecutter.github_repo ]}/badges/gpa.svg)](https://codeclimate.com/github/{[ cookiecutter.github_org ]}/{[ cookiecutter.github_repo ]})

# Overview

TODO: Add brief description of the project.

# Installation

{%- if cookiecutter.package_type == 'Library' %}
To install the latest released version of the
{[ cookiecutter.project_name ]} project into your active Python environment:

```
pip install {[ cookiecutter.pypi_package_name ]}
```
{%- else %}{# CLI #}
To install the latest released version of the
{[ cookiecutter.project_name ]} project into your system without having any
virtual Python environment active:

```
pipx install {[ cookiecutter.pypi_package_name ]}
```
{%- endif %}

This will also install any prerequisite Python packages.

For more details and alternative ways to install, see
[Installation](https://<readthedocs_name>.readthedocs.io/en/stable/intro.html#installation).

# Documentation

* [Documentation](https://<readthedocs_name>.readthedocs.io/en/stable/>)

# Change History

* [Change history](https://<readthedocs_name>.readthedocs.io/en/stable/changes.html)

# Contributing

For information on how to contribute to the
{[ cookiecutter.project_name ]} project, see
[Contributing](https://<readthedocs_name>.readthedocs.io/en/stable/development.html#contributing).

# License

The {[ cookiecutter.project_name ]} project is provided under the
[{[ cookiecutter.license ]}](https://raw.githubusercontent.com/{[ cookiecutter.github_org ]}/{[ cookiecutter.github_repo ]}/main/LICENSE).
