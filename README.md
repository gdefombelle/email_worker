PyTune Logger Module

The PyTune Logger is a flexible and powerful logging utility for Python applications, supporting both synchronous and asynchronous logging. It provides colored console output and stores logs in OpenSearch for persistent storage and analysis. Built with structlog, aiohttp, and colorama, this module simplifies logging in Python projects with minimal setup.

Features

Synchronous and Asynchronous Logging: Seamlessly log events in sync or async Python applications.
Console Output: Color-coded logs for easy readability (e.g., green for INFO, red for CRITICAL).
OpenSearch Integration: Logs are stored in OpenSearch with retry logic and exponential backoff for reliability.
Customizable: Supports additional metadata via keyword arguments and configurable log indices.
Global Logger Instances: Avoids duplication by caching logger instances.
Installation

Clone this repository or add the module to your project.
Install the required dependencies:
text
Wrap
Copy
pip install aiohttp structlog colorama opensearch-py python-dotenv
Set up your environment variables in a .env file (see Configuration below).
Quick Start

python
Wrap
Copy
from pytune_logger import get_logger

# Get a logger instance
logger = get_logger(name="my_app", index="my_app_logs")

# Synchronous logging
logger.info("Application started", user="john_doe")

# Asynchronous logging
await logger.log_error("Something went wrong", error_code=500)
Configuration
Create a .env file in your project root with the following variables:

text
Wrap
Copy
OPENSEARCH_HOST=http://localhost:9200
OPENSEARCH_USER=admin
OPENSEARCH_PASSWORD=admin
OPENSEARCH_DEFAULT_LOG_INDEX=pytune_logs
DEFAULT_LOGGER_NAME=pytune
ELASTIC_HANDLER_MAX_RETRIES=3
License
This project is licensed under the MIT License.