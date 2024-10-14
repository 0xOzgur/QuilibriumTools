#!/bin/bash

VERSION="2.0.0.1"

# Step 0: Welcome
echo "This script is made with ❤️ by 0xOzgur @ https://quilibrium.space"
echo "⏳Enjoy and sit back while you are upgrading your Quilibrium Node to v$VERSION!"
echo "The script is prepared for Ubuntu machines. If you are using another operating system, please check the compatibility of the script."
echo "⏳Processing..."
sleep 5  # Add a 5-second delay

# Stop the ceremonyclient service
    echo "Updating node..."
    service ceremonyclient stop
    echo "⏳ Stopping the ceremonyclient service if it exists..."
if systemctl is-active --quiet ceremonyclient; then
    if sudo systemctl stop ceremonyclient; then
        echo "🔴 Service stopped successfully."
        echo
    else
        echo "❌ Failed to stop the ceremonyclient service." >&2
        echo
    fi
else
    echo "ℹ️ Ceremonyclient service is not active or does not exist."
    echo
fi
sleep 1

# apt install cpulimit -y
# apt install gawk -y #incase it is not installed

# Download Binary
echo "⏳ Downloading New Release v$VERSION"
cd  ~/ceremonyclient
git remote set-url origin https://github.com/QuilibriumNetwork/ceremonyclient.git
git checkout main
git branch -D release
git pull
git checkout release
echo "✅ Downloaded the latest changes successfully."
echo

get_os_arch() {
    local arch=$(uname -m)
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    
    case $arch in
        x86_64)
            arch="amd64"
            ;;
        aarch64)
            arch="arm64"
            ;;
    esac
    
    echo "${os}-${arch}"
}

# Get the current OS and architecture
OS_ARCH=$(get_os_arch)

# Fetch the list of files from the release page
FILES=$(curl -s $BASE_URL | grep -oE "node-[0-9]+\.[0-9]+\.[0-9]+-${OS_ARCH}(\.dgst)?(\.sig\.[0-9]+)?")


# Change to the download directory
cd ~/ceremonyclient/node

# Download each file
for file in $FILES; do
    echo "Downloading $file..."
    wget "https://releases.quilibrium.com/$file"
    
    # Check if the download was successful
    if [ $? -eq 0 ]; then
        echo "Successfully downloaded $file"
    else
        echo "Failed to download $file"
    fi
    
    echo "------------------------"
done



# Determine the ExecStart line based on the architecture
ARCH=$(uname -m)
OS=$(uname -s)

# Determine the node binary name based on the architecture and OS
if [ "$ARCH" = "x86_64" ]; then
    if [ "$OS" = "Linux" ]; then
        NODE_BINARY="node-$VERSION-linux-amd64"
        GO_BINARY="go1.22.4.linux-amd64.tar.gz"
        QCLIENT_BINARY="qclient-2.0.0-linux-amd64"
    elif [ "$OS" = "Darwin" ]; then
        NODE_BINARY="node-$VERSION-darwin-amd64"
        GO_BINARY="go1.22.44.linux-amd64.tar.gz"
        QCLIENT_BINARY="qclient-2.0.0-darwin-arm64"
    fi
elif [ "$ARCH" = "aarch64" ]; then
    if [ "$OS" = "Linux" ]; then
        NODE_BINARY="node-$VERSION-linux-arm64"
        GO_BINARY="go1.22.4.linux-arm64.tar.gz"
    elif [ "$OS" = "Darwin" ]; then
        NODE_BINARY="node-$VERSION-darwin-arm64"
        GO_BINARY="go1.22.4.linux-arm64.tar.gz"
        QCLIENT_BINARY="qclient-2.0.0-linux-arm64"
    fi
fi

# Step 4:Update qClient

# Get the current OS and architecture
OS_ARCH=$(get_os_arch)

# Fetch the list of files from the release page
FILES=$(curl -s $BASE_URL | grep -oE "qclient-[0-9]+\.[0-9]+\.[0-9]+-${OS_ARCH}(\.dgst)?(\.sig\.[0-9]+)?")

# Change to the download directory
cd ~/ceremonyclient/client

# Download each file
for file in $FILES; do
    echo "Downloading $file..."
    wget "https://releases.quilibrium.com/$file"
    
    # Check if the download was successful
    if [ $? -eq 0 ]; then
        echo "Successfully downloaded $file"
    else
        echo "❌ Error: Failed to download $file"
        echo "Your node will still work, but you'll need to install the qclient manually later if needed."
    fi
    
    echo "------------------------"
done

        mv $QCLIENT_BINARY qclient
        chmod +x qclient
        echo "✅ qClient binary downloaded and configured successfully."

echo

# Get the current user's home directory
HOME=$(eval echo ~$HOME_DIR)

# Use the home directory in the path
NODE_PATH="$HOME/ceremonyclient/node"
EXEC_START="$NODE_PATH/$NODE_BINARY"

# Re-Create Ceremonyclient Service
echo "⏳ Re-Creating Ceremonyclient Service"
sleep 2  # Add a 2-second delay
SERVICE_FILE="/lib/systemd/system/ceremonyclient.service"
if [ ! -f "$SERVICE_FILE" ]; then
    echo "📝 Creating new ceremonyclient service file..."
    if ! sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Ceremony Client Go App Service

[Service]
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=$NODE_PATH
ExecStart=$EXEC_START
KillSignal=SIGINT
TimeoutStopSec=30s

[Install]
WantedBy=multi-user.target
EOF
    then
        echo "❌ Error: Failed to create ceremonyclient service file." >&2
        exit 1
    fi
else
    echo "🔍 Checking existing ceremonyclient service file..."
    # Check if the required lines exist and if they are different
    if ! grep -q "WorkingDirectory=$NODE_PATH" "$SERVICE_FILE" || ! grep -q "ExecStart=$EXEC_START" "$SERVICE_FILE"; then
        echo "🔄 Updating existing ceremonyclient service file..."
        # Replace the existing lines with new values
        sudo sed -i "s|WorkingDirectory=.*|WorkingDirectory=$NODE_PATH|" "$SERVICE_FILE"
        sudo sed -i "s|ExecStart=.*|ExecStart=$EXEC_START|" "$SERVICE_FILE"
    else
        echo "✅ No changes needed."
    fi
fi

# Start the ceremonyclient service
echo "✅ Starting Ceremonyclient Service"
sleep 2  # Add a 2-second delay
sudo systemctl daemon-reload
sudo systemctl enable ceremonyclient
sudo systemctl start ceremonyclient

# See the logs of the ceremonyclient service
echo "🎉 Welcome to Quilibrium Ceremonyclient v$VERSION"
echo "⏳ Please let it flow node logs at least 5 minutes then you can press CTRL + C to exit the logs."
sleep 2  # Add a 2-second delay
sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat
