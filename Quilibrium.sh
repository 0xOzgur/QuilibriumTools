#!/bin/bash

# Get system information
ARCH=$(uname -m)
OS=$(uname -s)

# Determine the node binary name based on the architecture and OS
if [ "$ARCH" = "x86_64" ]; then
    if [ "$OS" = "Linux" ]; then
        NODE_BINARY='node-1.4.18-linux-amd64'
    elif [ "$OS" = "Darwin" ]; then
        NODE_BINARY='node-1.4.18-darwin-amd64'
    fi
elif [ "$ARCH" = "aarch64" ]; then
    if [ "$OS" = "Linux" ]; then
        NODE_BINARY='node-1.4.18-linux-arm64'
    elif [ "$OS" = "Darwin" ]; then
        NODE_BINARY='node-1.4.18-darwin-arm64'
    fi
fi

# Function for each menu option
install_prerequisites() {
echo "Installing prerequisites..."

apt install cpulimit -y
apt install gawk -y #incase it is not instal

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
}

install_node() {
    echo "Installing node..."
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

# Step 3: Check if directory ~/ceremonyclient exists, download from github 
if [ -d ~/ceremonyclient ]; then
    # Check if backup directory ~/backup/qnode_keys exists, if not create it
    if [ ! -d ~/backup/qnode_keys ]; then
        mkdir -p ~/backup/qnode_keys
    fi
    
    # Check if files exist, then backup
    if [ -f ~/ceremonyclient/node/.config/keys.yml ]; then
        cp ~/ceremonyclient/node/.config/keys.yml ~/backup/qnode_keys/
        echo "✅ Backup of keys.yml created in ~/backup/qnode_keys folder"
    fi
    
    if [ -f ~/ceremonyclient/node/.config/config.yml ]; then
        cp ~/ceremonyclient/node/.config/config.yml ~/backup/qnode_keys/
        echo "✅ Backup of config.yml created in ~/backup/qnode_keys folder"
    fi
fi

# Step 4:Download Ceremonyclient
echo "⏳Downloading Ceremonyclient"
sleep 1  # Add a 1-second delay
cd ~
if [ -d "ceremonyclient" ]; then
  echo "Directory ceremonyclient already exists, skipping git clone..."
else
  until git clone https://source.quilibrium.com/quilibrium/ceremonyclient.git || git clone https://git.quilibrium-mirror.ch/agostbiro/ceremonyclient.git; do
    echo "Git clone failed, retrying..."
    sleep 2
  done
fi
cd ~/ceremonyclient/
git remote set-url origin https://source.quilibrium.com/quilibrium/ceremonyclient.git || git remote set-url origin https://git.quilibrium-mirror.ch/agostbiro/ceremonyclient.git 
git checkout release

# Set the version number
# VERSION="1.4.18"

# Get the system architecture
# ARCH=$(uname -m)

# Step 5:Determine the ExecStart line based on the architecture
# Get the current user's home directory
HOME=$(eval echo ~$HOME_DIR)

# Use the home directory in the path
NODE_PATH="$HOME/ceremonyclient/node"
EXEC_START="$NODE_PATH/release_autorun.sh"

# Step 6:Create Ceremonyclient Service
echo "⏳ Creating Ceremonyclient Service"
sleep 2  # Add a 2-second delay

# Check if the file exists before attempting to remove it
if [ -f "/lib/systemd/system/ceremonyclient.service" ]; then
    # If the file exists, remove it
    rm /lib/systemd/system/ceremonyclient.service
    echo "ceremonyclient.service file removed."
else
    # If the file does not exist, inform the user
    echo "ceremonyclient.service file does not exist. No action taken."
fi

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

sudo systemctl daemon-reload
sudo systemctl enable ceremonyclient

# Step 7: Start the ceremonyclient service
echo "✅Starting Ceremonyclient Service"
sleep 1  # Add a 1-second delay
sudo service ceremonyclient start

# Step 8: See the logs of the ceremonyclient service
echo "🎉Welcome to Quilibrium Ceremonyclient"
}

configure_grpcurl() {
    echo "Configuring grpcurl..."
    # Your code here
}

update_node() {
    echo "Configuring grpcurl..."
    service ceremonyclient stop

apt install cpulimit -y
apt install gawk -y #incase it is not installed

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

# Step 4:Start the ceremonyclient service
echo "✅ Starting Ceremonyclient Service"
sleep 2  # Add a 2-second delay
sudo systemctl daemon-reload
sudo systemctl enable ceremonyclient
sudo service ceremonyclient start

# See the logs of the ceremonyclient service
echo "🎉 Welcome to Quilibrium Ceremonyclient v1.4.18"
}

check_visibility() {
    echo "This script is made with ❤️ by 0xOzgur.eth @ https://quilibrium.space"
    echo "⏳You need GO and grpcurl installed and configured on your machine to run this script. If you don't have them, please install and configure grpcurl first."
    echo "You can find the installation instructions at https://docs.quilibrium.space/installing-prerequisites"
    echo "⏳Processing..."
    sleep 5  # Add a 5-second delay

    # Bootstrap peer list
    bootstrap_peers=(
    "EiDpYbDwT2rZq70JNJposqAC+vVZ1t97pcHbK8kr5G4ZNA=="
    "EiCcVN/KauCidn0nNDbOAGMHRZ5psz/lthpbBeiTAUEfZQ=="
    "EiDhVHjQKgHfPDXJKWykeUflcXtOv6O2lvjbmUnRrbT2mw=="
    "EiDHhTNA0yf07ljH+gTn0YEk/edCF70gQqr7QsUr8RKbAA=="
    "EiAnwhEcyjsHiU6cDCjYJyk/1OVsh6ap7E3vDfJvefGigw=="
    "EiB75ZnHtAOxajH2hlk9wD1i9zVigrDKKqYcSMXBkKo4SA=="
    "EiDEYNo7GEfMhPBbUo+zFSGeDECB0RhG0GfAasdWp2TTTQ=="
    "EiCzMVQnCirB85ITj1x9JOEe4zjNnnFIlxuXj9m6kGq1SQ=="
    )

    # Run the grpcurl command and capture its output
    output=$(grpcurl -plaintext localhost:8337 quilibrium.node.node.pb.NodeService.GetNetworkInfo)

    # Check if any of the specific peers are in the output
    visible=false
    for peer in "${bootstrap_peers[@]}"; do
        if [[ $output == *"$peer"* ]]; then
            visible=true
            echo "You see $peer as a bootstrap peer"
        else
            echo "Peer $peer not found"
        fi
    done

    if $visible ; then
        echo "Great, your node is visible!"
    else
        echo "Sorry, your node is not visible. Please restart your node and try again."
    fi
}

node_info() {
    echo "Getting node info..."
    cd ~/ceremonyclient/node && ./${NODE_BINARY} -node-info
}


node_logs() {
    echo "Getting node logs..."
    sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat
}

# Menu
    echo "Welcome! Please choose an option:"
while true; do
    echo "1) Install Prerequisites"
    echo "2) Install Node"
    echo "3) Configure grpCurl"
    echo "4) Update Node"
    echo "5) Check Visibility"
    echo "6) Node Info"
    echo "7) Node Logs"
    echo "8) Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1) install_prerequisites ;;
        2) install_node ;;
        3) configure_grpcurl ;;
        4) update_node ;;
        4) check_visibility ;;
        5) node_info ;;
        6) node_logs ;;
        7) break ;;
        *) echo "Invalid option, please try again." ;;
    esac
done