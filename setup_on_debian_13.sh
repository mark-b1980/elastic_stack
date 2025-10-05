#!/bin/bash

################################################################################################
# Check if running as root
################################################################################################
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

################################################################################################
# Change directory to script location
################################################################################################
script_dir=$(dirname "$0")
cd "$script_dir"

################################################################################################
# Install needed tools
################################################################################################
apt update
apt install -y openssh-server docker.io docker-compose ufw htop
systemctl enable sshd
systemctl start sshd

################################################################################################
# Configure firewall
################################################################################################
ufw allow 22/tcp
ufw allow 9200/tcp
ufw allow 8220/tcp
ufw allow 5601/tcp
ufw allow 5044/tcp
ufw allow 5044/upp
ufw allow 5141/udp
ufw enable 
ufw status

################################################################################################
# Generate random keys and passwords
################################################################################################
# Generate random password & keys
PASSWORD=$(openssl rand -base64 16 | sed 's/=/U/g' | sed 's|/|3|g' | sed 's|+|t|g')
ENCRYPTION_KEY=$(openssl rand -base64 32 | sed 's/=/B/g' | sed 's|/|5|g' | sed 's|+|a|g')
API_TOKEN=$(openssl rand -base64 32 | sed 's/=/X/g' | sed 's|/|0|g' | sed 's|+|p|g')

cp env.template .env
echo "ELASTIC_PASSWORD=$PASSWORD" >> .env
echo "KIBANA_PASSWORD=$PASSWORD" >> .env
echo "ENCRYPTION_KEY=$ENCRYPTION_KEY" >> .env
echo "FLEET_TOKEN=$API_TOKEN" >> .env

################################################################################################
# Add user to docker group
################################################################################################
getent group docker || groupadd docker
read -p "Enter the username to add to the docker group: " USER_NAME
usermod -aG docker $USER_NAME

# Prompt user for IP address
read -p "Enter the server IP address: " IP 
echo "SERVER IP: $IP"

echo "ELASTIC_IP=$IP" >> .env

################################################################################################
# Start Elastic Stack & print password
################################################################################################
docker compose up -d
echo "Waiting 30 seconds for Elastic Stack to fully start..."
sleep 30
docker compose ps

# Display access information
echo 
echo "You can access the Kibana at http://$IP:5601 with the following credentials:"
echo "---------------------------------------------------------------------------------------------------------"
echo "  username: elastic"
echo "  password: $PASSWORD"
echo "---------------------------------------------------------------------------------------------------------"

CID=$(docker ps -qf name=es01)
docker cp "$CID:/usr/share/elasticsearch/config/certs/ca/ca.crt" ./installation_scripts/elastic-ca.crt
