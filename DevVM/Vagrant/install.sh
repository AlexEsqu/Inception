#!/bin/bash

# Copy sshd_config file into the VM
# scp -P 4243 -r /home/$USER/Documents/Inception/DevVM/Vagrant/sshd_config $USER@localhost:/home/$USER/.

# SSH connect into the VM
# ssh -X $USER@localhost -p 4243

# Add Sudo and add User to it / Need privilege/root
su
apt install sudo
usermod -a -G sudo $USER

# Set up SSH
sudo mv sshd_config /etc/ssh/sshd_config
sudo ssh-keygen -A

# Set up Make
sudo apt install make

# Install VS-Code
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg
sudo apt install apt-transport-https

# Install Firefox
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
sudo apt-get update
sudo apt-get install firefox

# Install Docker
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

# Set up domain name
echo "127.0.0.1 $USER.42.fr" | sudo tee -a /etc/hosts



############
# OPTIONAL #
############

# Prettyfy with a new landing message appearing only once:
# FROM HOST: scp -P 4243 -r /home/$USER/Documents/Inception/DevVM/Vagrant/motd $USER@localhost:/home/$USER/.
sudo mv motd /etc/
sudo sed -i 's/session optional pam_motd.so noupdate/#session optional pam_motd.so noupdate/' /etc/pam.d/sshd

