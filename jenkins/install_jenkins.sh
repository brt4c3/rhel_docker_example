#!/bin/bash

set -euo pipefail

echo "============================================"
echo " Fedora Jenkins + Podman + Ansible Installer"
echo "============================================"

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

# Functions
log_step() {
    echo -e "\n${GREEN}[$1] $2${RESET}"
}

fail_exit() {
    echo -e "${RED}✖ $1${RESET}"
    exit 1
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        fail_exit "Please run this script as root or with sudo."
    fi
}

check_root

# [1/9] Update system and install basic tools
log_step "1/9" "Updating packages and installing core tools..."
dnf update -y
dnf install -y shadow-utils wget curl sudo

# Fix newuidmap permissions for rootless Podman
log_step "1.1" "Configuring user namespaces for Podman..."
chmod u+s /usr/bin/newuidmap /usr/bin/newgidmap

# Optional: ensure / is a shared mount if needed
if mountpoint -q /; then
    mount --make-rshared /
else
    echo "⚠️ / is not a mountpoint — skipping '--make-rshared /'"
fi

# [2/9] Install Java 21 for Jenkins
log_step "2/9" "Installing OpenJDK 21..."
dnf install -y java-21-openjdk java-21-openjdk-devel || fail_exit "Java install failed."
java -version || fail_exit "Java verification failed."

# [3/9] Add Jenkins repository and key
log_step "3/9" "Adding Jenkins repository..."
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo || fail_exit "Repo download failed."
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key || fail_exit "GPG key import failed."

# [4/9] Install Jenkins and prepare user
log_step "4/9" "Installing Jenkins..."
dnf install -y jenkins || fail_exit "Jenkins installation failed."

# Create jenkins user if needed
if ! id jenkins &>/dev/null; then
    useradd -m -s /bin/bash jenkins
    log_step "4.1" "Created 'jenkins' user."
else
    log_step "4.1" "'jenkins' user already exists."
fi

# Configure subuid/subgid
log_step "4.2" "Setting subuid/subgid for rootless containers..."
grep -q '^jenkins:' /etc/subuid || echo "jenkins:100000:65536" >> /etc/subuid
grep -q '^jenkins:' /etc/subgid || echo "jenkins:100000:65536" >> /etc/subgid

# Enable linger for user services (rootless Podman)
loginctl enable-linger jenkins

# [5/9] Start Jenkins
log_step "5/9" "Enabling and starting Jenkins service..."
systemctl enable --now jenkins || fail_exit "Jenkins service failed to start."
systemctl status jenkins --no-pager

# [6/9] Optional: Open Jenkins port in firewall
if command -v firewall-cmd &>/dev/null; then
    log_step "6/9" "Opening Jenkins port 8080 in firewalld..."
    firewall-cmd --add-port=8080/tcp --permanent
    firewall-cmd --reload
else
    echo "⚠️ firewall-cmd not found — skipping firewall configuration"
fi

# [7/9] Show Jenkins initial admin password
log_step "7/9" "Retrieving Jenkins initial admin password..."
if [[ -f /var/lib/jenkins/secrets/initialAdminPassword ]]; then
    echo -e "${GREEN}🔑 Initial Admin Password:${RESET}"
    cat /var/lib/jenkins/secrets/initialAdminPassword
else
    echo "⚠️ Jenkins not fully initialized yet. Try again in a few seconds."
fi

# [8/9] Install Podman and Ansible
log_step "8/9" "Installing Podman, podman-compose, and Ansible..."
dnf install -y podman podman-compose ansible || fail_exit "Failed to install Podman/Ansible."

# Enable podman.socket for REST API access
systemctl enable --now podman.socket
systemctl status podman.socket --no-pager

# [8.1] Initialize Podman for jenkins user
log_step "8.1" "Running Podman as jenkins to initialize containers..."
sudo -iu jenkins bash -c 'podman info || echo "⚠️ Podman initialization failed for jenkins."'

# [9/9] Print versions and success message
log_step "9/9" "Installed versions:"
echo "Java:" && java -version
echo "Podman:" && podman --version
echo "Podman Compose:" && podman-compose --version
echo "Ansible:" && ansible --version

# ✅ Final
echo -e "\n${GREEN}============================================"
echo "✅ Installation Complete!"
echo "🔗 Jenkins: http://localhost:8080"
echo "🔑 Use the admin password above to unlock Jenkins."
echo "🛠️ Podman (rootless), Ansible, and Java are all set up."
echo "============================================${RESET}"
