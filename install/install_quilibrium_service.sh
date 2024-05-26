#!/bin/bash  -i

cd ~
# Step 0: Welcome
echo "This script is made with ❤️ by 0xOzgur.eth"
echo "⏳Enjoy and sit back while you are building your Quilibrium Node!"
echo "⏳Processing..."
sleep 10  # Add a 10-second delay


# Step 1: Update and Upgrade the Machine
echo "Updating the machine"
echo "⏳Processing..."
sleep 2  # Add a 2-second delay
apt update
apt upgrade -y
apt install sudo -y #for non root Debian OS users
apt install git -y

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

# Installing Go 1.20.14
wget https://go.dev/dl/go1.20.14.linux-amd64.tar.gz
sudo tar -xvf go1.20.14.linux-amd64.tar.gz || { echo "Failed to extract Go! Exiting..."; exit_message; exit 1; }
sudo mv go /usr/local || { echo "Failed to move go! Exiting..."; exit_message; exit 1; }
sudo rm go1.20.14.linux-amd64.tar.gz || { echo "Failed to remove downloaded archive! Exiting..."; exit_message; exit 1; }


# Step 4: Set Go environment variables
echo "⏳Setting Go environment variables..."
sleep 5  # Add a 5-second delay

# Check if GOROOT is already set
if grep -q 'GOROOT=/usr/local/go' ~/.bashrc; then
    echo "GOROOT already set in ~/.bashrc."
else
    echo 'GOROOT=/usr/local/go' >> ~/.bashrc
    echo "GOROOT set in ~/.bashrc."
fi

# Check if GOPATH is already set
if grep -q "GOPATH=$HOME/go" ~/.bashrc; then
    echo "GOPATH already set in ~/.bashrc."
else
    echo "GOPATH=$HOME/go" >> ~/.bashrc
    echo "GOPATH set in ~/.bashrc."
fi

# Check if PATH is already set
if grep -q 'PATH=$GOPATH/bin:$GOROOT/bin:$PATH' ~/.bashrc; then
    echo "PATH already set in ~/.bashrc."
else
    echo 'PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bashrc
    echo "PATH set in ~/.bashrc."
fi

# Source .bashrc to apply changes
echo "⏳Sourcing .bashrc to apply changes"
source ~/.bashrc
sleep 5  # Add a 5-second delay

# Check GO Version
go version
sleep 5  # Add a 5-second delay

# Install gRPCurl
echo "⏳Installing gRPCurl"
sleep 1  # Add a 1-second delay
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

# Step 8:Download Ceremonyclient
echo "⏳Downloading Ceremonyclient"
sleep 1  # Add a 1-second delay
cd ~
git clone https://github.com/QuilibriumNetwork/ceremonyclient.git
cd ~/ceremonyclient/
git checkout release

# Get the system architecture
ARCH=$(uname -m)

# Get the current user's home directory
HOME_DIR=$(eval echo ~$USER)

# Use the home directory in the path
PATH="$HOME_DIR/ceremonyclient/node"

# Step10.1:Determine the ExecStart line based on the architecture
if [ "$ARCH" = "x86_64" ]; then
    EXEC_START="$PATH/node-1.4.18-linux-amd64"
elif [ "$ARCH" = "aarch64" ]; then
    EXEC_START="$PATH/node-1.4.18-linux-arm64"
elif [ "$ARCH" = "arm64" ]; then
    EXEC_START="$PATH/node-1.4.18-darwin-arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Step10.2:Create Ceremonyclient Service
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
ExecStart=$EXEC_START

[Install]
WantedBy=multi-user.target
EOF
systemctl enable ceremonyclient

# Start the ceremonyclient service
echo "✅Starting Ceremonyclient Service"
sleep 1  # Add a 1-second delay
service ceremonyclient start

# See the logs of the ceremonyclient service
echo "🎉Welcome to Quilibrium Ceremonyclient"
echo "⏳Please let it flow node logs at least 5 minutes then you can press CTRL + C to exit the logs."
sleep 5  # Add a 5-second delay
sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat