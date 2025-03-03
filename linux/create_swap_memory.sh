#!/bin/bash

SWAP_SIZE=10G
SWAP_FILE="/swapfile"
SWAPPINESS_VALUE=60

echo "Creating a ${SWAP_SIZE} swap file..."

# Disable swap if it's already enabled
sudo swapoff -a

# Create a swap file
if ! sudo fallocate -l $SWAP_SIZE $SWAP_FILE; then
  echo "fallocate failed, using dd instead..."
  sudo dd if=/dev/zero of=$SWAP_FILE bs=1M count=10240 status=progress
fi

# Set correct permissions
sudo chmod 600 $SWAP_FILE

# Format it as swap
sudo mkswap $SWAP_FILE

# Enable swap
sudo swapon $SWAP_FILE

# Make it permanent
if ! grep -q "$SWAP_FILE" /etc/fstab; then
  echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab
fi

# Set swappiness value
echo "Setting swappiness to ${SWAPPINESS_VALUE}..."
sudo sysctl vm.swappiness=$SWAPPINESS_VALUE

# Make swappiness permanent
if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
  echo "vm.swappiness=$SWAPPINESS_VALUE" | sudo tee -a /etc/sysctl.conf
else
  sudo sed -i "s/^vm.swappiness=.*/vm.swappiness=$SWAPPINESS_VALUE/" /etc/sysctl.conf
fi

# Apply changes
sudo sysctl -p

# Verify swap
echo "Swap space after update:"
free -h
echo "Swappiness value:"
cat /proc/sys/vm/swappiness

echo "Swap setup and swappiness configuration complete! 🚀"
