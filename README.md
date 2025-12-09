# `colored-logging` Python Package

A Python package for enhanced logging with automatic color-coding, semantic highlighting, and flexible configuration. This package provides consistent, visually organized logging output across console and file outputs.

[Gregory H. Halverson](https://github.com/gregory-halverson-jpl) (they/them)<br>
[gregory.h.halverson@jpl.nasa.gov](mailto:gregory.h.halverson@jpl.nasa.gov)<br>
NASA Jet Propulsion Laboratory 329G

## Features

- 🎨 **Automatic Color Coding**: INFO, WARNING, and ERROR messages are automatically color-coded
- 🏷️ **Semantic Highlighting**: Built-in functions to color-code files, directories, URLs, times, places, values, and names
- 📝 **Dual Output**: Simultaneously log to console and file with different formatting rules
- 🔧 **Configurable**: Customize log format, date format, and ANSI escape sequence handling
- 🧹 **ANSI Stripping**: Automatically strip color codes from file output while keeping console colorized
- 🔀 **Stream Separation**: Different log levels directed to appropriate output streams

## Installation

This package is available as a [pip package](https://pypi.org/project/colored-logging/) called `colored-logging` with a dash.

### Using pip

```bash
pip install colored-logging
```

### Using conda

Once published to conda-forge, you can install via:

```bash
conda install -c conda-forge colored-logging
```

## Quick Start

Import this package as `colored_logging` with an underscore:

```python
import logging
import colored_logging as cl

# Configure the logger (optional - uses defaults if not called)
cl.configure()

# Get a logger instance
logger = logging.getLogger(__name__)

# Start logging with automatic color-coding
logger.info("Processing started")
logger.warning("This will appear in yellow")
logger.error("This will appear in red")
```

## Basic Usage

### Simple Logging

```python
import logging
import colored_logging as cl

logger = logging.getLogger(__name__)

# INFO messages appear in standard color
logger.info("Application started successfully")

# WARNING messages automatically appear in yellow
logger.warning("Configuration file not found, using defaults")

# ERROR messages automatically appear in red
logger.error("Failed to connect to database")
```

### Semantic Color Functions

Use semantic color functions to highlight different types of information:

```python
import logging
import colored_logging as cl

logger = logging.getLogger(__name__)

# Highlight file paths
logger.info(f"Loading configuration from {cl.file('config.yaml')}")

# Highlight directories
logger.info(f"Output will be saved to {cl.dir('/data/results/')}")

# Highlight URLs
logger.info(f"Fetching data from {cl.URL('https://api.example.com/data')}")

# Highlight values
logger.info(f"Processing {cl.val('1000')} records")

# Highlight names/keys
logger.info(f"Using model: {cl.name('ResNet50')}")

# Highlight times
logger.info(f"Started at {cl.time('2024-12-09 14:30:00')}")

# Highlight places
logger.info(f"Server location: {cl.place('us-west-2')}")
```

### Complex Messages

Combine multiple semantic colors in a single message:

```python
import logging
import colored_logging as cl

logger = logging.getLogger(__name__)

logger.info(
    f"Saved {cl.val('500')} records to {cl.file('output.csv')} "
    f"in {cl.dir('/home/user/data/')} at {cl.time('14:25:30')}"
)

logger.info(
    f"Configuration: {cl.name('batch_size')}={cl.val('32')}, "
    f"{cl.name('learning_rate')}={cl.val('0.001')}"
)

logger.info(
    f"Downloaded {cl.file('dataset.zip')} from "
    f"{cl.URL('https://storage.example.com/data')} "
    f"to {cl.dir('./downloads/')}"
)
```

## Advanced Configuration

### Basic Configuration

The `configure()` function sets up the logging system with sensible defaults:

```python
import colored_logging as cl

# Use default settings
cl.configure()
```

### Logging to a File

Specify a filename to enable file logging alongside console output:

```python
import colored_logging as cl

# Log to both console and file
cl.configure(filename="application.log")

# Expand home directory in path
cl.configure(filename="~/logs/app.log")
```

### Custom Format Strings

Customize the log message format and date format:

```python
import colored_logging as cl

# Custom format with more details
cl.configure(
    format="[%(asctime)s %(name)s %(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)

# Simpler format
cl.configure(
    format="%(levelname)s: %(message)s",
    datefmt="%H:%M:%S"
)

# Include module and function names
cl.configure(
    format="[%(asctime)s %(name)s:%(funcName)s %(levelname)s] %(message)s"
)
```

### ANSI Escape Sequence Handling

Control whether ANSI color codes are stripped from console and file output:

```python
import colored_logging as cl

# Keep colors in console, strip from file (default)
cl.configure(
    filename="app.log",
    strip_console=False,
    strip_file=True
)

# Strip colors from both console and file
cl.configure(
    filename="app.log",
    strip_console=True,
    strip_file=True
)

# Keep colors in both (useful for logging to colorized terminals)
cl.configure(
    filename="app.log",
    strip_console=False,
    strip_file=False
)
```

### Full Configuration Example

```python
import colored_logging as cl

cl.configure(
    filename="~/logs/myapp.log",
    format="[%(asctime)s %(name)s %(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    strip_console=False,  # Keep colors in console
    strip_file=True       # Remove colors from file
)
```

## API Reference

### Configuration Function

#### `configure(filename=None, format=DEFAULT_FORMAT, datefmt=DEFAULT_DATE_FORMAT, strip_console=False, strip_file=True)`

Configure the logging system.

**Parameters:**
- `filename` (str, optional): Path to log file. If provided, logs to both console and file. Supports `~` expansion.
- `format` (str): Log message format string. Default: `"[%(asctime)s %(levelname)s] %(message)s"`
- `datefmt` (str): Date format string. Default: `"%Y-%m-%d %H:%M:%S"`
- `strip_console` (bool): Strip ANSI codes from console output. Default: `False`
- `strip_file` (bool): Strip ANSI codes from file output. Default: `True`

### Color Functions

All color functions accept any type and convert it to a colored string.

#### `file(text)` → str
Color text as a file path (blue).

#### `dir(text)` → str
Color text as a directory path (blue).

#### `URL(text)` → str
Color text as a URL (blue).

#### `time(text)` → str
Color text as a time value (green).

#### `place(text)` → str
Color text as a place/location (yellow).

#### `val(text)` → str
Color text as a value (cyan).

#### `name(text)` → str
Color text as a name/identifier (yellow).

### Utility Functions

#### `strip(text)` → str
Remove all ANSI escape sequences from text.

```python
import colored_logging as cl

colored_text = cl.file("example.txt")
plain_text = cl.strip(colored_text)
```

## Complete Example

```python
import logging
import colored_logging as cl

# Configure logging
cl.configure(
    filename="~/logs/myapp.log",
    format="[%(asctime)s %(name)s %(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)

# Get logger
logger = logging.getLogger(__name__)

# Application workflow with colored logging
logger.info("Application started")

config_file = "config.yaml"
logger.info(f"Loading configuration from {cl.file(config_file)}")

data_dir = "/data/input/"
file_count = 150
logger.info(f"Found {cl.val(file_count)} files in {cl.dir(data_dir)}")

model_name = "ResNet50"
batch_size = 32
logger.info(
    f"Initializing model {cl.name(model_name)} "
    f"with batch size {cl.val(batch_size)}"
)

output_path = "/data/output/results.csv"
records = 1000
logger.info(f"Saved {cl.val(records)} records to {cl.file(output_path)}")

api_url = "https://api.example.com/submit"
logger.info(f"Uploading results to {cl.URL(api_url)}")

# Warning example
if file_count > 100:
    logger.warning(f"Large number of files ({cl.val(file_count)}) may slow processing")

# Error example
try:
    # Some operation that might fail
    raise ValueError("Invalid configuration")
except ValueError as e:
    logger.error(f"Configuration error: {e}")

logger.info("Application completed successfully")
```

## Color Scheme

Default color assignments:

| Element | Color | Use Case |
|---------|-------|----------|
| Files | Blue | File paths, filenames |
| Directories | Blue | Directory paths, folders |
| URLs | Blue | Web addresses, API endpoints |
| Times | Green | Timestamps, durations |
| Places | Yellow | Locations, regions, zones |
| Values | Cyan | Numbers, counts, measurements |
| Names | Yellow | Identifiers, keys, model names |
| INFO | Default | Standard informational messages |
| WARNING | Yellow | Warnings and cautions |
| ERROR | Red | Errors and critical issues |

## Best Practices

1. **Use semantic functions**: Apply `cl.file()`, `cl.dir()`, `cl.val()`, etc. to make logs more readable
2. **Configure once**: Call `cl.configure()` at the start of your application
3. **Consistent naming**: Use the standard `logger = logging.getLogger(__name__)` pattern
4. **File logging**: Always log to a file in production for troubleshooting
5. **Strip ANSI in files**: Keep `strip_file=True` to ensure clean log files
6. **Descriptive messages**: Combine colored elements with clear descriptions

## Requirements

- Python >= 3.10
- termcolor

## License

Apache License 2.0

## Contributing

Issues and pull requests are welcome at the [GitHub repository](https://github.com/JPL-Evapotranspiration-Algorithms/colored-logging).

## Links

- [PyPI Package](https://pypi.org/project/colored-logging/)
- [GitHub Repository](https://github.com/JPL-Evapotranspiration-Algorithms/colored-logging)
- [Issue Tracker](https://github.com/JPL-Evapotranspiration-Algorithms/colored-logging/issues)
