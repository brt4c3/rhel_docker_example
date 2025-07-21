#!/bin/bash

set -e

echo "============================================"
echo " Fedora Jenkins + Podman + Ansible Installer"
echo "============================================"

# Update the package list
echo "[1/9] Updating package list..."
sudo dnf update -y

# Install Java (Jenkins requires Java 11, 17, or 21)
echo "[2/9] Installing OpenJDK 17..."
sudo dnf install -y --skip-unavailable java-21-openjdk java-21-openjdk-devel 

# Verify Java installation
echo "Verifying Java installation..."
java -version || { echo "Java installation failed. Exiting..."; exit 1; }

# Install wget if not already installed
echo "[3/9] Installing wget..."
sudo dnf install -y wget 

# Add Jenkins repository
echo "[4/9] Adding Jenkins repository..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo || {
    echo "Failed to download Jenkins repository. Check network connectivity."
    exit 1
}

# Import Jenkins repository key
echo "[5/9] Importing Jenkins repository key..."
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key || {
    echo "Failed to import Jenkins key. Check network connectivity."
    exit 1
}

# Install Jenkins
echo "[6/9] Installing Jenkins..."
sudo dnf install -y jenkins || {
    echo "Jenkins installation failed. Check repository configuration."
    exit 1
}

# Start Jenkins service
echo "Starting Jenkins service..."
sudo systemctl start jenkins || {
    echo "Failed to start Jenkins. Ensure systemd is enabled (check /etc/wsl.conf)."
    exit 1
}

# Enable Jenkins to start on boot
sudo systemctl enable jenkins

# Check Jenkins status
echo "Checking Jenkins service status..."
sudo systemctl status jenkins --no-pager

# Verify Jenkins is accessible
echo "Verifying Jenkins is running on port 8080..."
curl -s -f http://localhost:8080 >/dev/null && \
  echo "Jenkins is running and accessible on port 8080." || \
  echo "Warning: Jenkins is not accessible on http://localhost:8080. Check service status and port forwarding."

# Print initial admin password
echo "Retrieving initial Jenkins admin password..."
sudo cat /var/lib/jenkins/secrets/initialAdminPassword || echo "Unable to retrieve admin password."

# Install Podman
echo "[7/9] Installing Podman..."
sudo dnf install -y podman || {
    echo "Failed to install Podman."
    exit 1
}

# Install Ansible
echo "[8/9] Installing Ansible..."
sudo dnf install -y ansible || {
    echo "Failed to install Ansible."
    exit 1
}

# Print versions
echo "[9/9] Installed versions:"
java -version
podman --version
ansible --version

echo "============================================"
echo "Installation Complete!"
echo "- Jenkins: http://localhost:8080"
echo "- Use the admin password above to unlock Jenkins."
echo "- Podman and Ansible are installed."
echo "============================================"
