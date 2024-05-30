#!/bin/bash

# Step 0: Welcome
echo "This script is made with ❤️ by https://quilibrium.space @ 0xOzgur.eth"
echo "⏳Enjoy and sit back while you are upgrading your Quilibrium Node to v1.4.18!"
echo "The script is prepared for Ubuntu machines. If you are using another operating system, please check the compatibility of the script."
echo "⏳Processing..."
sleep 10  # Add a 10-second delay

# Stop the ceremonyclient service
service ceremonyclient stop

# Step 1:Download Binary
echo "⏳ Downloading New Release v1.4.18"
cd  ~/ceremonyclient
git remote set-url origin https://source.quilibrium.com/quilibrium/ceremonyclient.git || git remote set-url origin https://git.quilibrium-mirror.ch/agostbiro/ceremonyclient.git
git pull
git checkout release

# Get the current user's home directory
HOME=$(eval echo ~$HOME_DIR)

# Use the home directory in the path
NODE_PATH="$HOME/ceremonyclient/node"
EXEC_START="$NODE_PATH/release_autorun.sh"

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
WorkingDirectory=$NODE_PATH
ExecStart=$EXEC_START

[Install]
WantedBy=multi-user.target
EOF

# Step 4:Start the ceremonyclient service
echo "✅ Starting Ceremonyclient Service"
sleep 2  # Add a 2-second delay
sudo systemctl daemon-reload
sudo systemctl enable ceremonyclient
sudo service ceremonyclient start

# See the logs of the ceremonyclient service
echo "🎉 Welcome to Quilibrium Ceremonyclient v1.4.18"
echo "⏳ Please let it flow node logs at least 5 minutes then you can press CTRL + C to exit the logs."
sleep 5  # Add a 5-second delay
sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat