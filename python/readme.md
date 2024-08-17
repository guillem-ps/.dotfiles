# Personal Ruff Formatter for Python Code

This repository contains a personal configuration for the Ruff formatter, which is used to format and lint Python code. Ruff is a fast and highly configurable linter and formatter that supports various Python code style guides and linting rules.

## Ruff Configuration

The Ruff configuration file (`ruff.toml`) in this repository is tailored to enforce specific coding standards and formatting rules. Below is an overview of the configuration settings used:

### General Settings

- **fix**: `true` - Automatically fix issues where possible.
- **indent-width**: `4` - Use 4 spaces for indentation.
- **line-length**: `120` - Set the maximum line length to 120 characters.
- **target-version**: `'py311'` - Target Python version 3.11.

### Formatting Settings

- **docstring-code-format**: `true` - Format code within docstrings.
- **docstring-code-line-length**: `120` - Set the maximum line length for code within docstrings to 120 characters.
- **indent-style**: `'space'` - Use spaces for indentation.
- **quote-style**: `'single'` - Use single quotes for strings.
- **skip-magic-trailing-comma**: `false` - Do not skip the magic trailing comma.

### Linting Settings

- **select**: A list of linting rules to enable, including:
  - `F` (pyflakes)
  - `E` and `W` (pycodestyle)
  - `D` (pydocstyle)
  - `C90` (mccabe)
  - `I` (isort)
  - `N` (pep8-naming)
  - `UP` (pyupgrade)
  - `B` (flake8-bugbear)
  - `C4` (flake8-comprehensions)
  - `DTZ` (flake8-datetimez)
  - `S` (flake8-bandit)
  - `SIM` (flake8-simplify)
  - `RUF` (ruff)

- **ignore**: A list of linting rules to ignore, including:
  - `E111`, `E114`, `E117`, `W191` (indentation issues)
  - `D200`, `D205`, `D206`, `D212`, `D401`, `D300` (docstring issues)

- **per-file-ignores**: Specific rules to ignore for certain files:
  - `__init__.py`: `F401`, `D104`
  - `database.py`: `F401`
  - `**test**.py`: `S101`

- **mccabe**: Set the maximum complexity to 10.
- **pydocstyle**: Use the `pep257` convention and specify property decorators.
- **pep8-naming**: Specify class method decorators.
- **flake8-bugbear**: Extend immutable calls for FastAPI.
- **isort**: Configure import sorting settings.

## What is Ruff?

Ruff is a fast and highly configurable linter and formatter for Python code. It supports various Python code style guides and linting rules, making it a versatile tool for maintaining code quality and consistency.

### Official Website and Repository

- [Ruff Marketplace](https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff)
- [Ruff Vscode GitHub Repository](https://github.com/astral-sh/ruff-vscodef)

For more information, please refer to the official documentation and repository.

## Usage

To use the Ruff formatter with the provided configuration, ensure that you have Ruff installed and run the following command:

```sh
ruff check .