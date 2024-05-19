#!/bin/bash


# Step 0: Welcome
echo "This script is prepared by 0xOzgur.eth"
echo "Enjoy and sit back while you are building your Quilibrium Ceremony Client!"
echo "Processing..."
sleep 10  # Add a 10-second delay

# Step 1: Update and Upgrade the Machine
echo "Updating the machine"
echo "Processing..."
sleep 2  # Add a 2-second delay
apt-get update
apt-get upgrade -y

# Step 2: Install prerequisite 
echo "Installing prerequisite"
echo "Processing..."
sleep 2  # Add a 2-second delay
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

apt-cache policy docker-ce

# Step 4: Install Docker 
echo "Installing Docker"
echo "Processing..."
sleep 2  # Add a 2-second delay
sudo apt install docker-ce

# Step 5:Download Ceremonyclient
echo "Downloading Ceremonyclient"
sleep 2  # Add a 2-second delay
git clone https://github.com/QuilibriumNetwork/ceremonyclient.git
cd ~/ceremonyclient

# Step 5:Build Docker Container
echo "Building Ceremonyclient Container"
sleep 2  # Add a 2-second delay
docker build --build-arg GIT_COMMIT=$(git log -1 --format=%h) -t quilibrium -t quilibrium:1.4.17 .

# Step 5:Run Ceremonyclient Container
echo "Running Ceremonyclient Container"
sleep 2  # Add a 2-second delay
docker compose up -d

# Step 5:Logs Ceremonyclient Container
echo "Welcome to Quilibrium Ceremonyclient"
sleep 2  # Add a 2-second delay
docker compose logs -f -n, --tail 100