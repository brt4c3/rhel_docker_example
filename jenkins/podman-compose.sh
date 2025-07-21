#!/bin/bash
set -e 

# Make sure podman is found
export PATH=$PATH:/usr/local/bin:/usr/bin

# Set runtime dir for Jenkins user (UID 992 or whatever Jenkins runs as)
export XDG_RUNTIME_DIR="/tmp/xdg-runtime-jenkins"

# Create it if it doesn't exist
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# Optional debugging
echo "Using podman at: $(which podman)"
podman --version

# Run podman-compose
exec podman-compose  -f ./docker-compose.yml up -d --build

