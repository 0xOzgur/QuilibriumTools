#!/bin/bash

cd ~

# Step 0: Welcome
echo "This script is made with ❤️ by 0xOzgur.eth"
echo "⏳Enjoy and sit back while you are building your Quilibrium Ceremony Client!"
echo "⏳Processing..."
sleep 10  # Add a 10-second delay

# Step 1: Update and Upgrade the Machine
echo "Updating the machine"
echo "⏳Processing..."
sleep 2  # Add a 2-second delay
apt-get update
apt-get upgrade -y

# Step 2: Adjust network buffer sizes
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

# Step 3:Download Ceremonyclient
echo "⏳Downloading Ceremonyclient"
sleep 2  # Add a 2-second delay
git clone https://github.com/QuilibriumNetwork/ceremonyclient.git

cd ~/ceremonyclient/node

# Step 4:Download Binary
echo "⏳Downloading Binary"
sleep 2  # Add a 2-second delay
wget https://github.com/QuilibriumNetwork/ceremonyclient/releases/download/v1.4.17/node-1.4.17-linux-amd64.bin
ls
mv node*.bin node

# Step 5:Make the file executable
echo "⏳Making the Binary executable"
sleep 2  # Add a 2-second delay
chmod +x node

# Step 6:Create Ceremonyclient Service
echo "⏳Creating Ceremonyclient Service"
sleep 2  # Add a 2-second delay
sudo tee /lib/systemd/system/ceremonyclient.service > /dev/null <<EOF
[Unit]
Description=Ceremony Client Go App Service

[Service]
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=/root/ceremonyclient/node
ExecStart=/root/ceremonyclient/node/node

[Install]
WantedBy=multi-user.target
EOF

# Step 7:Start the ceremonyclient service
echo "✅Starting Ceremonyclient Service"
sleep 2  # Add a 2-second delay
systemctl enable ceremonyclient
service ceremonyclient start

# See the logs of the ceremonyclient service
echo "🎉Welcome to Quilibrium Ceremonyclient"
echo "⏳Please let it flow node logs at least 5 minutes then you can press CTRL + C to exit the logs."
sleep 5  # Add a 5-second delay
sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat