#!/bin/bash
# Install Nomad server
sudo apt update
sudo apt install -y unzip curl

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

# Nomad server config
cat <<EOF | sudo tee /etc/nomad.d/server.hcl
server {
  enabled          = true
  bootstrap_expect = 1
  data_dir         = "/opt/nomad/data"
}
client {
  enabled = false
}
EOF

# Start Nomad
sudo nomad agent -config=/etc/nomad.d/server.hcl > /var/log/nomad.log 2>&1 &
