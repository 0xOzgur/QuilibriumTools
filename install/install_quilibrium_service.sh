#!/bin/bash  -i

cd ~
# Step 0: Welcome
echo "This script is made with ❤️ by https://quilibrium.space @ 0xOzgur.eth"
echo "The script is prepared for Ubuntu machines. If you are using another operating system, please check the compatibility of the script."
echo "The script doesn't install GO or GrpCurl packages. If you want to install them please visit https://docs.quilibrium.space/installing-prerequisites page."
echo "⏳Enjoy and sit back while you are building your Quilibrium Node!"
echo "⏳Processing..."

# Step 1: Update and Upgrade the Machine
sudo apt update
sudo apt upgrade -y
sudo apt install git -y

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
sleep 1  # Add a 1-second delay
cd ~
if [ -d "ceremonyclient" ]; then
  echo "Directory ceremonyclient already exists, skipping git clone..."
else
  until git clone https://source.quilibrium.com/quilibrium/ceremonyclient.git; do
    echo "Git clone failed, retrying..."
    sleep 2
  done
fi
cd ~/ceremonyclient/
git checkout release-cdn

# Set the version number
VERSION="1.4.18"

# Get the system architecture
ARCH=$(uname -m)

# Get the current user's home directory
HOME=$(eval echo ~$HOME_DIR)

# Use the home directory in the path
NODE_PATH="$HOME/ceremonyclient/node"

# Step4:Determine the ExecStart line based on the architecture
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

# Step5:Create Ceremonyclient Service
# Check if the ceremonyclient.service file exists
if [ -f /lib/systemd/system/ceremonyclient.service ]; then
  # If it exists, remove it
  sudo rm /lib/systemd/system/ceremonyclient.service
fi
sudo tee /lib/systemd/system/ceremonyclient.service > /dev/null <<EOF
[Unit]
Description=Ceremony Client Go App Service

[Service]
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=/root/ceremonyclient/node
ExecStart=$EXEC_START

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable ceremonyclient

# Start the ceremonyclient service
sudo service ceremonyclient start