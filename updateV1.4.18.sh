#!/bin/bash

# Stop the ceremonyclient service
service ceremonyclient stop

# Step 0:Download Binary
echo "⏳ Downloading Binary"
sleep 2  # Add a 2-second delay
cd ~/ceremonyclient/node

wget -O- https://github.com/QuilibriumNetwork/ceremonyclient/releases/download/v1.4.18/node-1.4.18-linux-amd64.bin > $HOME/ceremonyclient/node/node

# Step 1:Make the file executable
echo "⏳ Making the Binary executable"
sleep 2  # Add a 2-second delay
chmod +x node

# Step 3:Re-Create Ceremonyclient Service
echo "⏳ Re-Creating Ceremonyclient Service"
sleep 2  # Add a 2-second delay
rm /lib/systemd/system/ceremonyclient.service
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

# Step 4:Start the ceremonyclient service
echo "✅ Starting Ceremonyclient Service"
sleep 2  # Add a 2-second delay
systemctl enable ceremonyclient
service ceremonyclient start

# See the logs of the ceremonyclient service
echo "🎉 Welcome to Quilibrium Ceremonyclient"
echo "⏳ Please let it flow node logs at least 5 minutes then you can press CTRL + C to exit the logs."
sleep 5  # Add a 5-second delay
sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat