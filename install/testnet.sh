#!/bin/bash
# Set the version number

VERSION="2.0.4-b7-testnet"
qClientVERSION="2.0.4"

cd ~
# Step 0: Welcome
echo "This script is made with ❤️ by 0xOzgur @ https://quilibrium.space "
echo "The script is prepared for Ubuntu machines. If you are using another operating system, please check the compatibility of the script."
echo "This script will be building new fresh Node for Quilibrium Testnet. Your use is at your own risk. 0xOzgur does not accept any liability."
echo "⏳Enjoy and sit back while you are building your Quilibrium Testnet Node!"
echo "⏳Processing..."
sleep 5  # Add a 10-second delay

# Step 1: Update and Upgrade the Machine
echo "Updating the machine"
echo "⏳Processing..."
sleep 2  # Add a 2-second delay

# Fof DEBIAN OS - Check if sudo and git is installed
if ! command -v sudo &> /dev/null
then
    echo "sudo could not be found"
    echo "Installing sudo..."
    su -c "apt update && apt install sudo -y"
else
    echo "sudo is installed"
fi

if ! command -v git &> /dev/null
then
    echo "git could not be found"
    echo "Installing git..."
    su -c "apt update && apt install git -y"
else
    echo "git is installed"
fi

sudo apt upgrade -y

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

# Step 4:Download Ceremonyclient
echo "⏳Creating Testnet Directories"
sleep 1  # Add a 1-second delay
mkdir testnet
cd ~/testnet
mkdir ceremonyclient
cd ~/testnet/ceremonyclient/

# Determine the ExecStart line based on the architecture
ARCH=$(uname -m)
OS=$(uname -s)

# Determine the node binary name based on the architecture and OS
if [ "$ARCH" = "x86_64" ]; then
    if [ "$OS" = "Linux" ]; then
        NODE_BINARY="node-$VERSION-linux-amd64"
        GO_BINARY="go1.22.4.linux-amd64.tar.gz"
        QCLIENT_BINARY="qclient-$qClientVERSION-linux-amd64"
    elif [ "$OS" = "Darwin" ]; then
        NODE_BINARY="node-$VERSION-darwin-amd64"
        GO_BINARY="go1.22.44.linux-amd64.tar.gz"
        QCLIENT_BINARY="qclient-$qClientVERSION-darwin-arm64"
    fi
elif [ "$ARCH" = "aarch64" ]; then
    if [ "$OS" = "Linux" ]; then
        NODE_BINARY="node-$VERSION-linux-arm64"
        GO_BINARY="go1.22.4.linux-arm64.tar.gz"
    elif [ "$OS" = "Darwin" ]; then
        NODE_BINARY="node-$VERSION-darwin-arm64"
        GO_BINARY="go1.22.4.linux-arm64.tar.gz"
        QCLIENT_BINARY="qclient-$qClientVERSION-linux-arm64"
    fi
fi


#==========================
# NODE BINARY DOWNLOAD
#==========================

# Step 4:Download qClient
echo "⏳Downloading qClient"
sleep 1  # Add a 1-second delay
    cd ~/testnet/ceremonyclient/node
    wget https://releases.quilibrium.com/$NODE_BINARY
    chmod +x $NODE_BINARY
echo "✅  Node binary for testnet downloaded and permissions configured completed."

#==========================
# qCLIENT BINARY DOWNLOAD
#==========================
    cd ~/testnet/ceremonyclient/client
    wget https://releases.quilibrium.com/$QCLIENT_BINARY
    chmod +x $QCLIENT_BINARY
    echo "✅  qClient binary for testnet downloaded and permissions configured completed."
echo

# Step 5:Determine the ExecStart line based on the architecture
# Get the current user's home directory
HOME=$(eval echo ~$HOME_DIR)

# Use the home directory in the path
NODE_PATH="$HOME/testnet/ceremonyclient/node"
EXEC_START="$NODE_PATH/$NODE_BINARY"

# Step 6:Create Ceremonyclient Service
echo "⏳ Stopping Ceremonyclient Service"
service ceremonyclient stop
sleep 2  # Add a 2-second delay

echo "⏳ Creating Ceremonyclient Testnet Service"
sleep 2  # Add a 2-second delay

sudo tee /lib/systemd/system/qtestnet.service > /dev/null <<EOF
[Unit]
Description=Ceremony Client Testnet Service

[Service]
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=$NODE_PATH
ExecStart=$EXEC_START --signature-check=false --network=1
KillSignal=SIGINT
TimeoutStopSec=75s

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
# sudo systemctl enable ceremonyclient

# Step 7: Start the ceremonyclient service
echo "✅Starting Ceremonyclient Testnet Service"
sleep 1  # Add a 1-second delay
sudo service qtestnet start

# Step 8: See the logs of the ceremonyclient service
echo "🎉Welcome to Quilibrium Ceremonyclient VERSION"
echo "⏳Please let it flow node logs at least 5 minutes then you can press CTRL + C to exit the logs."
sleep 30  # Add a 5-second delay

CONFIG_FILE="$HOME/testnet/ceremonyclient/node/.config/config.yml"

# Backup the original file
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

# Comment out existing bootstrap peers
sed -i '/bootstrapPeers:/,/^[^ ]/s/^  -/#  -/' "$CONFIG_FILE"

# Add the new bootstrap peer
sed -i '/bootstrapPeers:/a\  - /ip4/91.242.214.79/udp/8336/quic-v1/p2p/QmNSGavG2DfJwGpHmzKjVmTD6CVSyJsUFTXsW4JXt2eySR' "$CONFIG_FILE"

echo "Bootstrap peers updated in $CONFIG_FILE"
echo "Original file backed up as ${CONFIG_FILE}.bak"

sudo service qtestnet restart
sudo journalctl -u qtestnet.service -f --no-hostname -o cat