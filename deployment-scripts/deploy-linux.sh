#!/usr/bin/env bash
set -euo pipefail

# Verify that the script is running on Linux
OS="$(uname -s)"
if [[ "$OS" != "Linux" ]]; then
    echo "This deployment script only supports Linux."
    exit 1
fi

# Check if the rootless setup tool exists
if ! command -v dockerd-rootless-setuptool.sh &> /dev/null; then
    echo "Error: dockerd-rootless-setuptool.sh not found. Please install Docker first."
    exit 1
fi

# Disable the system-wide (rootful) daemon
sudo systemctl disable --now docker.service docker.socket

# Install rootless mode
dockerd-rootless-setuptool.sh install

# Assert that Docker is running in rootless mode
if ! docker info | grep -q rootless; then
    echo "Error: Docker is not running in rootless mode!"
    exit 1
fi

# Build and run the Docker container/s
docker compose up --build