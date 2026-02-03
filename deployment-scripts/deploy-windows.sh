#!/usr/bin/env bash
set -euo pipefail

# This script is intended to run inside WSL 2 on Windows.
# Docker Desktop for Windows runs the daemon inside a WSL 2 or Hyper-V VM,
# so it never has root access to the Windows host. No rootless configuration
# is needed.

# Verify that the script is running under WSL
if ! grep -qi microsoft /proc/version 2>/dev/null; then
    echo "Error: This deployment script must be run from within WSL 2 on Windows."
    exit 1
fi

# Verify Docker is available and running
if ! docker info &> /dev/null; then
    echo "Error: Docker is not running. Start Docker Desktop first."
    exit 1
fi

# Build and run the Docker container/s
docker compose up --build
