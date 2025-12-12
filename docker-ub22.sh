#!/usr/bin/env bash
set -e

echo "▶ Installing Docker Engine & Docker Compose (v2)"

# Ensure script is run with sudo privileges
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root or with sudo"
  exit 1
fi

# Remove old Docker versions if present
echo "▶ Removing old Docker versions (if any)"
apt-get remove -y docker docker-engine docker.io containerd runc || true

# Update system
echo "▶ Updating package index"
apt-get update -y

# Install dependencies
echo "▶ Installing dependencies"
apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

# Create keyrings directory
install -m 0755 -d /etc/apt/keyrings

# Add Docker GPG key
echo "▶ Adding Docker GPG key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo "▶ Adding Docker APT repository"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
apt-get update -y

# Install Docker Engine + plugins
echo "▶ Installing Docker Engine"
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# Enable Docker on boot
echo "▶ Enabling Docker service"
systemctl enable docker
systemctl start docker

# Add invoking user to docker group
if [ -n "$SUDO_USER" ]; then
  echo "▶ Adding user '$SUDO_USER' to docker group"
  usermod -aG docker "$SUDO_USER"
fi

# Print versions
echo
echo "✅ Installation complete"
echo "Docker version:"
docker --version
echo
echo "Docker Compose version:"
docker compose version

echo
echo "⚠️  Log out and log back in (or reboot) to use Docker without sudo"
