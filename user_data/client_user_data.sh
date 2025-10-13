#!/bin/bash
# Install Nomad client
sudo apt update
sudo apt install -y unzip curl docker.io

# Start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Nomad installation
NOMAD_VERSION="1.6.5"
curl -O https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
unzip nomad_${NOMAD_VERSION}_linux_amd64.zip
sudo mv nomad /usr/local/bin/
rm nomad_${NOMAD_VERSION}_linux_amd64.zip

# Create directories
sudo mkdir -p /etc/nomad.d
sudo mkdir -p /opt/nomad/data
sudo chmod 775 /etc/nomad.d /opt/nomad/data

# Client config
cat <<EOF | sudo tee /etc/nomad.d/client.hcl
client {
  enabled = true
  servers = ["${azurerm_linux_virtual_machine.nomad_server.private_ip_address}:4647"]
  data_dir = "/opt/nomad/data"
}
EOF

# Start Nomad
sudo nomad agent -config=/etc/nomad.d/client.hcl > /var/log/nomad.log 2>&1 &
