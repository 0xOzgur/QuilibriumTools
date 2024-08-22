#!/bin/bash

# Set the version number
VERSION="1.4.21.1"

# Determine the ExecStart line based on the architecture
ARCH=$(uname -m)
OS=$(uname -s)

# Determine the node binary name based on the architecture and OS
if [ "$ARCH" = "x86_64" ]; then
    if [ "$OS" = "Linux" ]; then
        NODE_BINARY="node-$VERSION-linux-amd64"
        GO_BINARY="go1.22.4.linux-amd64.tar.gz"
    elif [ "$OS" = "Darwin" ]; then
        NODE_BINARY="node-$VERSION-darwin-amd64"
        GO_BINARY="go1.22.44.linux-amd64.tar.gz"
    fi
elif [ "$ARCH" = "aarch64" ]; then
    if [ "$OS" = "Linux" ]; then
        NODE_BINARY="node-$VERSION-linux-arm64"
        GO_BINARY="go1.22.4.linux-arm64.tar.gz"
    elif [ "$OS" = "Darwin" ]; then
        NODE_BINARY="node-$VERSION-darwin-arm64"
        GO_BINARY="go1.22.4.linux-arm64.tar.gz"
    fi
fi

echo "Installing prerequisites..."
sleep 1  # Add a 1-second delay

echo "Updating the machine"
echo "⏳Processing..."
sleep 1  # Add a 1-second delay

# Fof DEBIAN OS - Check if sudo and git is installed
# Step 1.1: Prepare Machine
if ! command -v sudo &> /dev/null
then
    echo "sudo could not be found"
    echo "Installing sudo..."
    su -c "apt update && apt install sudo -y"
else
    echo "sudo is installed"
fi
# ınstall git if not installed
if ! command -v git &> /dev/null
then
    echo "git could not be found"
    echo "Installing git..."
    su -c "apt update && apt install git -y"
else
    echo "git is installed"
fi

# Update the machine
sudo apt update
sudo apt upgrade -y

# Install cpu limit and gawk
apt install cpulimit -y
apt install gawk -y #incase it is not installed

# Download and install Go
wget https://go.dev/dl/$GO_BINARY || { echo "Failed to download Node! Exiting..."; exit_message; exit 1; }    
sudo tar -xvf $GO_BINARY || { echo "Failed to extract Go! Exiting..."; exit_message; exit 1; }
sudo rm -rf /usr/local/go || { echo "Failed to remove existing Go! Exiting..."; exit_message; exit 1; }
sudo mv go /usr/local || { echo "Failed to move go! Exiting..."; exit_message; exit 1; }
sudo rm $GO_BINARY || { echo "Failed to remove downloaded archive! Exiting..."; exit_message; exit 1; }


# Set Go environment variables
echo "⏳Setting Go environment variables..."
sleep 2  # Add a 2-second delay

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
sleep 2  # Add a 2-second delay

# Check GO Version
go version
sleep 2  # Add a 2-second delay

# Install gRPCurl
echo "⏳Installing gRPCurl"
sleep 1  # Add a 1-second delay
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest