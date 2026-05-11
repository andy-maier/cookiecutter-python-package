# zhmcclient - A pure Python client library for the IBM Z HMC Web Services API

[![Version on Pypi](https://img.shields.io/pypi/v/zhmcclient.svg)](https://pypi.python.org/pypi/{[ cookiecutter.pypi_package_name ]}/)
[![Test status (main)](https://github.com/{[ cookiecutter.github_org ]}/{[ cookiecutter.github_repo ]}/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/{[ cookiecutter.github_org ]}/{[ cookiecutter.github_repo ]}/actions/workflows/test.yml?query=branch%3Amaster)
{%- if cookiecutter.with_readthedocs == "Yes" %}
[![Docs status (main)](https://readthedocs.org/projects/python-zhmcclient/badge/?version=latest)](https://readthedocs.org/projects/python-zhmcclient/builds/)
{%- endif %}
[![Test coverage (main)](https://coveralls.io/repos/github/{[ cookiecutter.github_org ]}/{[ cookiecutter.github_repo ]}/badge.svg?branch=main)](https://coveralls.io/github/{[ cookiecutter.github_org ]}/{[ cookiecutter.github_repo ]}?branch=main)

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

{%- if cookiecutter.with_readthedocs == "Yes" %}
For more details and alternative ways to install, see
[Installation](https://<readthedocs_name>.readthedocs.io/en/stable/intro.html#installation).

{%- endif %}
# Documentation

{%- if cookiecutter.with_readthedocs == "Yes" %}
* [Documentation](https://<readthedocs_name>.readthedocs.io/en/stable/>)

# Change History

* [Change history](https://<readthedocs_name>.readthedocs.io/en/stable/changes.html)
{%- else %}
TODO: Write short documentation here.
{%- endif %}

{%- if cookiecutter.with_readthedocs == "Yes" %}
# Contributing

For information on how to contribute to the
{[ cookiecutter.project_name ]} project, see
[Contributing](https://<readthedocs_name>.readthedocs.io/en/stable/development.html#contributing).

{%- endif %}
# License

The {[ cookiecutter.project_name ]} project is provided under the
[{[ cookiecutter.license ]}](https://raw.githubusercontent.com/{[ cookiecutter.github_org ]}/{[ cookiecutter.github_repo ]}/main/LICENSE).
