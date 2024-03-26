#!/bin/bash

# Check if the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Prompt for username
read -p "Enter username: " username

# Check if the user already exists
if id "$username" &>/dev/null; then
  echo "User '$username' already exists"
  exit 1
fi

# Prompt for password
read -s -p "Enter password: " password

# Create the user
useradd -m -s /bin/bash "$username"

# Set the password for the user
echo "$username:$password" | chpasswd

sudo mkdir "/home/$username/Documents" "/home/$username/Downloads"
sudo usermod -aG sudo "$username"

echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@$(hostname -I | cut -d" " -f1)\[\033[00m\]:\[\033[01;34m\]\w\$\[\033[00m\] '" >> /home/$username/.bashrc

# Display success message
echo "User '$username' created successfully"
