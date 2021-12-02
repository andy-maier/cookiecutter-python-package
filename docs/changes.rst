
.. _`Change log`:

Change log
==========


{{ cookiecutter.package_name }} 0.1.0
-------------------------------------

Released: not yet

**Incompatible changes:**

**Deprecations:**

**Bug fixes:**

* Fixed a dependency error that caused importlib-metadata to be installed on
  Python 3.8, while it is included in the Python base.

* Fixed TypeError when running Sphinx due to using docutils 0.18 on Python 2.7.

* Fixed error when installing virtualenv in install test on Python 2.7.

**Enhancements:**

* Support for Python 3.10: Added Python 3.10 in GitHub Actions tests, and in
  package metadata.

**Cleanup:**

**Known issues:**

* See `list of open issues`_.

.. _`list of open issues`: https://github.com/{{ cookiecutter.github_org }}/{{ cookiecutter.github_repo }}/issues
