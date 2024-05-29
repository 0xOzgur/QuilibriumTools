#!/bin/bash

# Step 0: Welcome
echo "This script is made with ❤️ by https://quilibrium.space @ 0xOzgur.eth for scalepod.io"
sleep 2  # Add a 2-second delay

# Stop the ceremonyclient service
service ceremonyclient stop

# Step 1:Download Binary
cd  ~/ceremonyclient
git pull
git checkout release

# Get the current user's home directory
HOME=$(eval echo ~$HOME_DIR)

# Use the home directory in the path
NODE_PATH="$HOME/ceremonyclient/node"
EXEC_START="$NODE_PATH/release_autorun.sh"

# Step 3:Re-Create Ceremonyclient Service
rm /lib/systemd/system/ceremonyclient.service
sudo tee /lib/systemd/system/ceremonyclient.service > /dev/null <<EOF
[Unit]
Description=Ceremony Client Go App Service

[Service]
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=$NODE_PATH
ExecStart=$EXEC_START

[Install]
WantedBy=multi-user.target
EOF

# Step 3: Update the ExecStart line in the Ceremonyclient Service file
# sudo sed -i "s|ExecStart=.*|ExecStart=$EXEC_START|" /lib/systemd/system/ceremonyclient.service

# Step 4:Start the ceremonyclient service
sudo systemctl daemon-reload
sudo systemctl enable ceremonyclient
sudo service ceremonyclient start