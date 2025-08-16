# flet-rive

[![pypi](https://img.shields.io/pypi/v/flet-rive.svg)](https://pypi.python.org/pypi/flet-rive)
[![downloads](https://static.pepy.tech/badge/flet-rive/month)](https://pepy.tech/project/flet-rive)
[![license](https://img.shields.io/github/license/flet-dev/flet-rive.svg)](https://github.com/flet-dev/flet-rive/blob/main/LICENSE)

A cross-platform [Flet](https://flet.dev) extension for displaying [Rive](https://rive.app/) animations.

It is based on the [rive](https://pub.dev/packages/rive) Flutter package.

## Platform Support

This package supports the following platforms:

| Platform | Supported |
|----------|:---------:|
| Windows  |     ✅     |
| macOS    |     ✅     |
| Linux    |     ✅     |
| iOS      |     ✅     |
| Android  |     ✅     |
| Web      |     ✅     |

## Usage

### Installation

To install the `flet-rive` package and add it to your project dependencies:

=== "uv"
    ```bash
    uv add flet-rive
    ```

=== "pip"
    ```bash
    pip install flet-rive  # (1)!
    ```

    1. After this, you will have to manually add this package to your `requirements.txt` or `pyproject.toml`.

=== "poetry"
    ```bash
    poetry add flet-rive
    ```


## Example

```python title="main.py"
--8<-- "examples/rive_example/src/main.py"
``` 
