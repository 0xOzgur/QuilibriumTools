#!/bin/bash  -i

# Step 0: Welcome
echo "This script is prepared by 0xOzgur.eth"
echo "Enjoy and sit back while you are building your Quilibrium Node!"
echo "Processing..."
sleep 10  # Add a 10-second delay


# Installing Go 1.20.14
wget https://go.dev/dl/go1.20.14.linux-amd64.tar.gz
sudo tar -xvf go1.20.14.linux-amd64.tar.gz || { echo "Failed to extract Go! Exiting..."; exit_message; exit 1; }
sudo mv go /usr/local || { echo "Failed to move go! Exiting..."; exit_message; exit 1; }
sudo rm go1.20.14.linux-amd64.tar.gz || { echo "Failed to remove downloaded archive! Exiting..."; exit_message; exit 1; }


# Step 4: Set Go environment variables
echo "Setting Go environment variables..."
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
echo "Sourcing .bashrc to apply changes"
source ~/.bashrc
sleep 5  # Add a 5-second delay

# Check GO Version
go version
sleep 5  # Add a 5-second delay

# Install gRPCurl
echo "Installing gRPCurl"
sleep 1  # Add a 1-second delay
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

# Download Ceremonyclient
echo "Downloading Ceremonyclient"
sleep 1  # Add a 1-second delay
cd ~
git clone https://github.com/QuilibriumNetwork/ceremonyclient.git

# Build Ceremonyclient
echo "Building Ceremonyclient"
sleep 1  # Add a 1-second delay
cd ~/ceremonyclient/node
GOEXPERIMENT=arenas go install ./...

# Build Ceremonyclient qClient
echo "Building qCiient"
sleep 1  # Add a 1-second delay
cd ~/ceremonyclient/client
GOEXPERIMENT=arenas go build -o qclient main.go

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
ExecStart=/root/go/bin/node ./...

[Install]
WantedBy=multi-user.target
EOF

# Start the ceremonyclient service
echo "Starting Ceremonyclient Service"
sleep 1  # Add a 1-second delay
systemctl enable ceremonyclient
service ceremonyclient start

# See the logs of the ceremonyclient service
echo "CTRL + C to exit the logs."
sleep 5  # Add a 5-second delay
sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat
