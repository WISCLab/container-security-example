#!/usr/bin/env bash
set -euo pipefail

# Docker Desktop for Mac runs the daemon inside a lightweight Linux VM,
# so it never has root access to the macOS host. No rootless configuration
# is needed.

# Verify that the script is running on macOS
OS="$(uname -s)"
if [[ "$OS" != "Darwin" ]]; then
    echo "This deployment script only supports macOS."
    exit 1
fi

# Docker Desktop on macOS already runs unprivileged
if ! docker info &> /dev/null; then
    echo "Error: Docker is not running. Start Docker Desktop first."
    exit 1
fi

# Build and run the Docker container/s
docker compose up --build