# ANS NEP Programmable Sensor Interface (NEP PSI) Utils Module

## Overview

The PSI Utils module is a frozen Python module that gets packaged into the PSI MicroPython firmware. This module contains utility functions and classes specifically designed for PSI applications.

## Module Structure

This directory (`ports/stm32/modules/psiutils/`) contains Python modules that are automatically frozen into the firmware during the build process. All `.py` files placed in this directory become part of the `psiutils` package.

## Build Integration

### Manifest Configuration

The module is defined in the board manifest file:

```python
# File: ports/stm32/boards/PYBD_SF3/manifest.py
package("psiutils", base_path="$(PORT_DIR)/modules")
```

### Important Build Notes

- **Automatic Inclusion**: Any `.py` files placed in `ports/stm32/modules/` are automatically packaged as frozen modules
- **Package Name**: All modules in this directory are accessible under the `psiutils` namespace
- **Build Requirement**: These modules are frozen at compile time, not runtime

## Usage

After flashing the PSI firmware, you can import and use the utilities:

```python
import psiutils
# or
from psiutils import specific_module
```

## Development Guidelines

1. **File Placement**: Place all PSI-specific utility modules in this directory
2. **Naming Convention**: Use descriptive names for module files (e.g., `sensors.py`, `calibration.py`)
3. **Dependencies**: Ensure modules only depend on MicroPython standard library or other frozen modules
4. **Testing**: Test modules on target hardware before including in builds

## Building Firmware

When building the PSI MicroPython firmware, these modules will be automatically included. No additional configuration is required beyond placing the `.py` files in this directory.

For build instructions, refer to the main project documentation.