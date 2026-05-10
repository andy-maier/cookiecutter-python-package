"""
Test version of the package.
"""


def test_version():
    """
    Test obtaining the version of the package.
    """
    import {[ cookiecutter.python_package_name ]}  # noqa: F401 pylint: disable=import-outside-toplevel
    assert {[ cookiecutter.python_package_name ]}.__version__
