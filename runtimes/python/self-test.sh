#!/usr/bin/env bash

set -ueo pipefail

# Check runtime is available
python --version

# Check package manager is available
pip --version

# Try a script in the runtime
python /usr/local/bin/self-test.py
