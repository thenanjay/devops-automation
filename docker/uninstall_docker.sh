#!/bin/bash

# Detect OS
os_name=$(grep '^ID=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')
echo "Detected OS: $os_name"

echo "Stopping Docker service..."
sudo systemctl stop docker

# Uninstall Docker based on OS
echo "Uninstalling Docker..."
if [[ "$os_name" == "ubuntu" || "$os_name" == "debian" ]]; then
  sudo apt remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo apt autoremove -y
elif [[ "$os_name" == "centos" || "$os_name" == "rhel" ]]; then
  sudo yum remove -y docker-ce docker-ce-cli containerd.io
elif [[ "$os_name" == "fedora" ]]; then
  sudo dnf remove -y docker-ce docker-ce-cli containerd.io
elif [[ "$os_name" == "arch" ]]; then
  sudo pacman -Rns --noconfirm docker
else
  echo "Unsupported OS: $os_name"
  exit 1
fi

echo "Removing Docker directories..."
sudo rm -rf /var/lib/docker
sudo rm -rf /etc/docker

# Remove user from Docker group
echo "Removing user from Docker group..."
sudo gpasswd -d "$USER" docker

echo "Docker has been completely uninstalled."
