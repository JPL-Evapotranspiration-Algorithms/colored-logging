import logging
import colored_logging as cl

# Configure the logger
cl.configure()

# Get logger instance
logger = logging.getLogger(__name__)

# Example 1: Basic info message
logger.info("This is a basic info message")

# Example 2: File path with coloring
logger.info(f"Loading data from {cl.file('/path/to/data.csv')}")

# Example 3: Directory with coloring
logger.info(f"Output directory: {cl.dir('/path/to/output/')}")

# Example 4: Multiple colored elements
logger.info(f"Processing {cl.name('dataset1')} with {cl.val('1000')} records")

# Example 5: Time and place
logger.info(f"Started at {cl.time('2023-12-09 10:30:00')} in {cl.place('New York')}")

# Example 6: URL
logger.info(f"Downloading from {cl.URL('https://example.com/data.json')}")

# Example 7: Complex message with multiple colors
logger.info(
    f"Saved {cl.val('500')} records to {cl.file('output.csv')} "
    f"in {cl.dir('/home/user/results/')} at {cl.time('14:25:30')}"
)

# Example 8: Warning message (automatically colored yellow)
logger.warning("This is a warning message with automatic yellow coloring")

# Example 9: Error message (automatically colored red)
logger.error("This is an error message with automatic red coloring")

# Example 10: Info with names and values
logger.info(
    f"Configuration: {cl.name('batch_size')}={cl.val('32')}, "
    f"{cl.name('learning_rate')}={cl.val('0.001')}"
)
