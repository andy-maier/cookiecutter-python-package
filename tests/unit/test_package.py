"""
Test import and versioning of the package.
"""


def test_import():
    """
    Test import of the package.
    """
    import [[ cookiecutter.python_package_name ]]  # noqa: F401 pylint: disable=import-outside-toplevel
    assert [[ cookiecutter.python_package_name ]]


def test_versioning():
    """
    Test import of the package version.
    """
    import [[ cookiecutter.python_package_name ]]  # noqa: F401 pylint: disable=import-outside-toplevel
    assert [[ cookiecutter.python_package_name ]].__version__
