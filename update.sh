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
git pull
git checkout release

# Set the version number
VERSION="1.4.18"

# Get the system architecture
ARCH=$(uname -m)

# Get the current user's home directory
HOME=$(eval echo ~$HOME_DIR)

# Use the home directory in the path
NODE_PATH="$HOME/ceremonyclient/node"

# Step10.1:Determine the ExecStart line based on the architecture
if [ "$ARCH" = "x86_64" ]; then
    EXEC_START="$NODE_PATH/node-$VERSION-linux-amd64"
elif [ "$ARCH" = "aarch64" ]; then
    EXEC_START="$NODE_PATH/node-$VERSION-linux-arm64"
elif [ "$ARCH" = "arm64" ]; then
    EXEC_START="$NODE_PATH/node-$VERSION-darwin-arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Step 3:Re-Create Ceremonyclient Service
echo "⏳ Re-Creating Ceremonyclient Service"
sleep 2  # Add a 2-second delay

# Update the ExecStart line in the service file
sudo sed -i "s|ExecStart=.*|ExecStart=$EXEC_START|" /lib/systemd/system/ceremonyclient.service

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