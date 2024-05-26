#!/bin/bash  -i

cd ~
# Step 0: Welcome
echo "This script is made with ❤️ by https://quilibrium.space @ 0xOzgur.eth"
echo "The script is prepared for Ubuntu machines. If you are using another operating system, please check the compatibility of the script."
echo "The script doesn't install GO or GrpCurl packages. If you want to install them please visit https://docs.quilibrium.space/installing-prerequisites page."
echo "⏳Enjoy and sit back while you are building your Quilibrium Node!"
echo "⏳Processing..."
sleep 10  # Add a 10-second delay


# Step 1: Update and Upgrade the Machine
echo "Updating the machine"
echo "⏳Processing..."
sleep 2  # Add a 2-second delay
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


# Step 8:Download Ceremonyclient
echo "⏳Downloading Ceremonyclient"
sleep 1  # Add a 1-second delay
cd ~
if [ -d "ceremonyclient" ]; then
  echo "Directory ceremonyclient already exists, skipping git clone..."
else
  until git clone https://github.com/QuilibriumNetwork/ceremonyclient.git; do
    echo "Git clone failed, retrying..."
    sleep 2
  done
fi
cd ~/ceremonyclient/
git checkout release

# Get the system architecture
ARCH=$(uname -m)

# Get the current user's home directory
HOME=$(eval echo ~$HOME_DIR)

# Use the home directory in the path
NODE_PATH="$HOME/ceremonyclient/node"

# Step10.1:Determine the ExecStart line based on the architecture
if [ "$ARCH" = "x86_64" ]; then
    EXEC_START="$NODE_PATH/node-1.4.18-linux-amd64"
elif [ "$ARCH" = "aarch64" ]; then
    EXEC_START="$NODE_PATH/node-1.4.18-linux-arm64"
elif [ "$ARCH" = "arm64" ]; then
    EXEC_START="$NODE_PATH/node-1.4.18-darwin-arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Step10.2:Create Ceremonyclient Service
echo "⏳ Re-Creating Ceremonyclient Service"
sleep 2  # Add a 2-second delay
sudo rm /lib/systemd/system/ceremonyclient.service
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
echo "✅Starting Ceremonyclient Service"
sleep 1  # Add a 1-second delay
sudo service ceremonyclient start

# See the logs of the ceremonyclient service
echo "🎉Welcome to Quilibrium Ceremonyclient"
echo "⏳Please let it flow node logs at least 5 minutes then you can press CTRL + C to exit the logs."
sleep 5  # Add a 5-second delay
sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat