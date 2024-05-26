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

# Step 3: Update the ExecStart line in the Ceremonyclient Service file
sudo sed -i "s|ExecStart=.*|ExecStart=$EXEC_START|" /lib/systemd/system/ceremonyclient.service

# Step 4:Start the ceremonyclient service
sudo systemctl daemon-reload
sudo systemctl enable ceremonyclient
sudo service ceremonyclient start