#!/bin/bash

set -euo pipefail

echo "============================================"
echo " Fedora Jenkins + Podman + Ansible Installer"
echo "============================================"

# Functions
log_step() {
    echo -e "\n[$1] $2"
}

fail_exit() {
    echo "$1"
    exit 1
}

# [1/9] Update packages
log_step "1/9" "Updating package list..."
sudo dnf update -y
sudo dnf install -y --skip-unavailable shadow-utils


# [2/9] Install Java 21 (for Jenkins)
log_step "2/9" "Installing OpenJDK 21..."
sudo dnf install -y --skip-unavailable java-21-openjdk java-21-openjdk-devel || fail_exit "Java install failed."
java -version || fail_exit "Java not found after install."

# [3/9] Install wget
log_step "3/9" "Installing wget..."
sudo dnf install -y wget || fail_exit "wget install failed."

# [4/9] Add Jenkins repository
log_step "4/9" "Adding Jenkins repository..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo || fail_exit "Failed to download Jenkins repo."
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key || fail_exit "Failed to import Jenkins GPG key."

# [5/9] Install Jenkins
log_step "5/9" "Installing Jenkins..."
sudo dnf install -y jenkins || fail_exit "Jenkins install failed."

# Create jenkins user if not exists
if ! id jenkins &>/dev/null; then
    sudo useradd -m -s /bin/bash jenkins
    log_step "5.1" "Created 'jenkins' user."
else
    log_step "5.1" "'jenkins' user already exists."
fi

# Enable linger to allow systemd user services
sudo loginctl enable-linger jenkins
echo "jenkins:100000:65536" | sudo tee -a /etc/subuid
echo "jenkins:100000:65536" | sudo tee -a /etc/subgid
sudo usermod -u 2000 jenkins
sudo usermod -g 2000 jenkins



# [6/9] Start Jenkins
log_step "6/9" "Starting Jenkins service..."
sudo systemctl enable --now jenkins || fail_exit "Jenkins service start failed."

log_step "6.1" "Checking Jenkins service status..."
sudo systemctl status jenkins --no-pager || fail_exit "Jenkins not running properly."

# [7/9] Validate Jenkins HTTP access
log_step "6.2" "Verifying Jenkins HTTP access..."
if curl -s -f http://localhost:8080 >/dev/null; then
    echo "✅ Jenkins is running on http://localhost:8080"
else
    echo "⚠️ Jenkins not accessible. Check firewall or systemd logs."
fi

# [8/9] Print initial admin password
log_step "6.3" "Retrieving initial admin password..."
if sudo test -f /var/lib/jenkins/secrets/initialAdminPassword; then
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
else
    echo "⚠️ Could not retrieve admin password. Wait until Jenkins fully starts."
fi

# [9/9] Install Podman and Ansible
log_step "7/9" "Installing Podman..."
sudo dnf install -y podman podman-compose || fail_exit "Podman or podman-compose install failed."

log_step "8/9" "Installing Ansible..."
sudo dnf install -y ansible || fail_exit "Ansible install failed."

# Versions
log_step "9/9" "Installed versions:"
java -version
podman --version
podman-compose --version
ansible --version

# Final message
echo -e "\n============================================"
echo "✅ Installation Complete!"
echo "🔗 Jenkins: http://localhost:8080"
echo "🔑 Use the admin password shown above to unlock Jenkins."
echo "🛠️ Podman, Ansible, and Java are all installed."
echo "============================================"
