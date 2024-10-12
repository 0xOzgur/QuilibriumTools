#!/bin/bash

cd ~

# Step 0: Welcome
echo "This script is made with ❤️ by 0xOzgur @ https://quilibrium.space"
echo "⏳Enjoy and sit back while you are building your Quilibrium Ceremony Client!"
echo "⏳Processing..."
sleep 10  # Add a 10-second delay

# Step 1: Update and Upgrade the Machine
echo "Updating the machine"
echo "⏳Processing..."
sleep 2  # Add a 2-second delay
apt-get update
apt-get upgrade -y

# Step 2: Install prerequisite 
echo "Installing prerequisite"
echo "⏳Processing..."
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
sudo apt install docker-ce -y

# Step 5: Adjust network buffer sizes
echo "Adjusting network buffer sizes..."
if grep -q "^net.core.rmem_max=600000000$" /etc/sysctl.conf; then
  echo "net.core.rmem_max=600000000 found inside /etc/sysctl.conf, skipping..."
else
  echo -e "\n# Change made to increase buffer sizes for better network performance for ceremonyclient\nnet.core.rmem_max=600000000" | sudo tee -a /etc/sysctl.conf > /dev/null
fi
if grep -q "^net.core.wmem_max=600000000$" /etc/sysctl.conf; then
  echo "net.core.wmem_max=600000000 found inside /etc/sysctl.conf, skipping..."
else
  echo -e "\n# Change made to increase buffer sizes for better network performance for ceremonyclient\nnet.core.wmem_max=600000000" | sudo tee -a /etc/sysctl.conf > /dev/null
fi
sudo sysctl -p


# Step 6:Download Ceremonyclient
echo "⏳Downloading Ceremonyclient"
sleep 2  # Add a 2-second delay
git clone https://source.quilibrium.com/quilibrium/ceremonyclient.git
cd ~/ceremonyclient
git checkout release-cdn

# Step 7:Build Docker Container
echo "⏳Building Ceremonyclient Container"
sleep 2  # Add a 2-second delay
docker build --build-arg GIT_COMMIT=$(git log -1 --format=%h) -t quilibrium:2.0 .2.0

# Step 8:Run Ceremonyclient Container
echo "✅Running Ceremonyclient Container"
sleep 2  # Add a 2-second delay
docker compose -f docker/docker-compose.yml up -d

# Step 9:Logs Ceremonyclient Container
echo "🎉Welcome to Quilibrium Ceremonyclient"
echo "⏳Please let it flow node logs at least 5 minutes then you can press CTRL + C to exit the logs."
sleep 5  # Add a 5-second delay
docker compose -f docker/docker-compose.yml logs -f -n, --tail 100
