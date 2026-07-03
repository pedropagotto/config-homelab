#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please, run this script as root (using su - first)."
  exit 1
fi

REAL_USER=${LOGNAME:-$SUDO_USER}

if [ "$REAL_USER" = "root" ]; then
  REAL_USER=$(ls /home | head -n 1)
fi

echo "=================================================="
echo "Starting Optimized Home Lab Setup on Debian"
echo "Common user detected for permissions: $REAL_USER"
echo "=================================================="

apt update && apt install sudo ca-certificates curl gnupg lsb-release -y

usermod -aG sudo "$REAL_USER"

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update && apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

systemctl daemon-reload
systemctl enable docker.service
systemctl enable containerd.service

usermod -aG docker "$REAL_USER"

echo "=================================================="
echo "Installation completed successfully!"
echo "The system will reboot in 5 seconds to apply permissions."
echo "After rebooting, log in via SSH with your common user and use 'sudo'."
echo "=================================================="

sleep 5
reboot