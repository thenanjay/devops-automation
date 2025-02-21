#!/bin/bash

# Detect OS
os_name=$(grep '^ID=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')
echo "Detected OS: $os_name"

# Update system packages
echo "Updating system packages..."
if [[ "$os_name" == "ubuntu" || "$os_name" == "debian" ]]; then
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y ca-certificates curl gnupg lsb-release
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/$os_name/gpg | sudo tee /etc/apt/keyrings/docker.asc >/dev/null
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$os_name $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
elif [[ "$os_name" == "centos" || "$os_name" == "rhel" ]]; then
  sudo yum install -y yum-utils
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum install -y docker-ce docker-ce-cli containerd.io
elif [[ "$os_name" == "fedora" ]]; then
  sudo dnf install -y dnf-plugins-core
  sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  sudo dnf install -y docker-ce docker-ce-cli containerd.io
elif [[ "$os_name" == "arch" ]]; then
  sudo pacman -Syu --noconfirm
  sudo pacman -S --noconfirm docker
else
  echo "Unsupported OS: $os_name"
  exit 1
fi

# Enable and start Docker
echo "Enabling and starting Docker..."
sudo systemctl enable --now docker

# Add current user to the Docker group (optional)
echo "Adding user to Docker group (optional)..."
sudo usermod -aG docker $USER

# Test Docker installation
echo "Testing Docker installation..."
docker --version || {
  echo "Docker installation failed"
  exit 1
}

echo "Docker installation completed successfully!"

# Instructions to apply user group changes
echo "Please logout and log back in or run 'newgrp docker' to apply user group changes."
