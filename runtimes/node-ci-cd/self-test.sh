#!/usr/bin/env bash

set -ueo pipefail

# Check runtime is available
node --version

# Check package manager is available
npm --version

# Try a script in the runtime
node /usr/local/bin/self-test.js
