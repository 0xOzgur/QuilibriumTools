#!/bin/bash


# Step 0: Welcome
echo "This script is prepared by 0xOzgur.eth"
echo "Enjoy and sit back while you are building your Quilibrium Node!"
echo "Processing..."
sleep 10  # Add a 10-second delay


# Download Ceremonyclient
echo "Downloading Ceremonyclient"
sleep 2  # Add a 2-second delay
git clone https://github.com/QuilibriumNetwork/ceremonyclient.git

cd ~/ceremonyclient/node

# Download Binary
echo "Downloading Binary"
sleep 2  # Add a 2-second delay
wget https://github.com/QuilibriumNetwork/ceremonyclient/releases/download/v1.4.17/node-1.4.17-linux-amd64.bin
ls
mv node*.bin node

# Make the file executable
echo "Making the Binary executable"
sleep 2  # Add a 2-second delay
chmod +x node

# Create Ceremonyclient Service
echo "Creating Ceremonyclient Service"
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

# Start the ceremonyclient service
echo "Starting Ceremonyclient Service"
sleep 1  # Add a 1-second delay
systemctl enable ceremonyclient
service ceremonyclient start

# See the logs of the ceremonyclient service
echo "CTRL + C to exit the logs."
sleep 5  # Add a 5-second delay
sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat