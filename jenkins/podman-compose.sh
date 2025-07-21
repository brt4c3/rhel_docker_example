#!/bin/bash
# WSL-safe podman-compose wrapper for Jenkins
export PATH=$PATH:/usr/bin:/usr/local/bin
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
which podman
podman --version
exec podman-compose "$@"
