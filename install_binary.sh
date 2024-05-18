#!/bin/bash

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
sleep 1  # Add a 1-second delay
sudo tee /lib/systemd/system/ceremonyclient.service > /dev/null <<EOF
[Unit]
Description=Ceremony Client Go App Service

[Service]
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=/root/ceremonyclient/node
Environment=GOEXPERIMENT=arenas
ExecStart=/root/go/bin/node/node ./...

[Install]
WantedBy=multi-user.target
EOF

# Run the node
echo "Running the node"
sleep 2  # Add a 2-second delay
./node