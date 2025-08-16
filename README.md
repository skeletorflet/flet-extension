# flet-extension

[![pypi](https://img.shields.io/pypi/v/flet-extension.svg)](https://pypi.python.org/pypi/flet-extension)
[![downloads](https://static.pepy.tech/badge/flet-extension/month)](https://pepy.tech/project/flet-extension)
[![license](https://img.shields.io/github/license/flet-dev/flet-extension.svg)](https://github.com/flet-dev/flet-extension/blob/main/LICENSE)

A comprehensive [Flet](https://flet.dev) extension demonstrating advanced widget and service capabilities for building custom Flet controls.

This extension showcases:
- **Custom Widget Controls**: Interactive widgets with advanced styling and event handling
- **Service Extensions**: Background services with lifecycle management, configuration, and event triggering
- **Cross-platform Support**: Works seamlessly across all Flet-supported platforms
- **Best Practices**: Production-ready code with comprehensive documentation and error handling

## Documentation

Detailed documentation to this package can be found [here](https://flet-dev.github.io/flet-extension/).

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

## Features

### Custom Widget Extension
- Interactive widget with customizable styling
- Event handling for user interactions
- Property binding and state management
- Responsive design support

### Service Extension
- Background service with start/stop/pause functionality
- Configurable timer intervals and maximum counts
- Real-time status updates and counter tracking
- Custom event triggering and error handling
- Comprehensive lifecycle management

## Installation

To install the `flet-extension` package and add it to your project dependencies:

- Using `uv`:
    ```bash
    uv add flet-extension
    ```

- Using `pip`:
    ```bash
    pip install flet-extension
    ```
    After this, you will have to manually add this package to your `requirements.txt` or `pyproject.toml`.

- Using `poetry`:
    ```bash
    poetry add flet-extension
    ```

## Quick Start

```python
import flet as ft
from flet_extension import FletExtension, FletServiceExtension

def main(page: ft.Page):
    page.title = "Flet Extension Demo"
    
    # Add custom widget
    widget = FletExtension(
        text="Hello from Extension!",
        color="blue",
        on_click=lambda e: print("Widget clicked!")
    )
    
    # Add service extension
    service = FletServiceExtension(
        interval=1000,  # 1 second
        max_count=10,
        on_status_change=lambda e: print(f"Status: {e.data}"),
        on_counter_update=lambda e: print(f"Counter: {e.data}")
    )
    
    page.add(widget, service)

ft.app(target=main)
```
