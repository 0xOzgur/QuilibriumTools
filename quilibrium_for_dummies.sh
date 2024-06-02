#!/bin/bash -i

# Source .bashrc to make GO work if it is not working
source ~/.bashrc

clear

# Set the version number
VERSION="1.4.18"

# Get system information
ARCH=$(uname -m)
OS=$(uname -s)

# Determine the node binary name based on the architecture and OS
if [ "$ARCH" = "x86_64" ]; then
    if [ "$OS" = "Linux" ]; then
        NODE_BINARY='node-1.4.18-linux-amd64'
        GO_BINARY='go1.20.14.linux-amd64.tar.gz'
    elif [ "$OS" = "Darwin" ]; then
        NODE_BINARY='node-1.4.18-darwin-amd64'
        GO_BINARY='go1.20.14.linux-amd64.tar.gz'
    fi
elif [ "$ARCH" = "aarch64" ]; then
    if [ "$OS" = "Linux" ]; then
        NODE_BINARY='node-1.4.18-linux-arm64'
        GO_BINARY='go1.20.14.linux-arm64.tar.gz'
    elif [ "$OS" = "Darwin" ]; then
        NODE_BINARY='node-1.4.18-darwin-arm64.tar.gz'
        GO_BINARY='go1.20.14.linux-arm64.tar.gz'
    fi
fi

# Function for each menu option
install_prerequisites() {
echo "Installing prerequisites..."

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
sudo apt update
sudo apt upgrade -y

apt install cpulimit -y
apt install gawk -y #incase it is not installed

wget https://go.dev/dl/$GO_BINARY || { echo "Failed to download Node! Exiting..."; exit_message; exit 1; }    
sudo tar -xvf $GO_BINARY || { echo "Failed to extract Go! Exiting..."; exit_message; exit 1; }
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
    line_exists() {
    grep -qF "$1" "$2"
}

# Step 1: Enable gRPC
echo "Enabling gRPC..."
cd "$HOME/ceremonyclient/node" || { echo "Failed to change directory to ~/ceremonyclient/node! Exiting..."; exit 1; }

# Check if the line listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/8337 exists
if ! line_exists "listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/8337" .config/config.yml; then
    # Check if the line listenGrpcMultiaddr: "" exists
    if line_exists "listenGrpcMultiaddr: \"\"" .config/config.yml; then
        # Substitute listenGrpcMultiaddr: "" with listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/8337
        sudo sed -i 's#^listenGrpcMultiaddr:.*$#listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/8337#' .config/config.yml || { echo "Failed to enable gRPC! Exiting..."; exit 1; }
    else
        # Add listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/8337
        echo "listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/8337" | sudo tee -a .config/config.yml > /dev/null || { echo "Failed to enable gRPC! Exiting..."; exit 1; }
    fi
else
    echo "gRPC already enabled."
fi


# Check if the line listenRESTMultiaddr: /ip4/127.0.0.1/tcp/8338 exists
if ! line_exists "listenRESTMultiaddr: /ip4/127.0.0.1/tcp/8338" .config/config.yml; then
    # Check if the line listenRESTMultiaddr: "" exists
    if line_exists "listenRESTMultiaddr: \"\"" .config/config.yml; then
        # Substitute listenRESTMultiaddr: "" with listenRESTMultiaddr: /ip4/127.0.0.1/tcp/8338
        sudo sed -i 's#^listenRESTMultiaddr:.*$#listenRESTMultiaddr: /ip4/127.0.0.1/tcp/8338#' .config/config.yml || { echo "Failed to enable gRPC! Exiting..."; exit 1; }
    else
        # Add listenRESTMultiaddr: /ip4/127.0.0.1/tcp/8338
        echo "listenRESTMultiaddr: /ip4/127.0.0.1/tcp/8338" | sudo tee -a .config/config.yml > /dev/null || { echo "Failed to enable gRPC! Exiting..."; exit 1; }
    fi
else
    echo "gRPC already enabled."
fi



# Step 2: Enable Stats Collection
echo "Enabling Stats Collection..."
if ! line_exists "  statsMultiaddr: \"/dns/stats.quilibrium.com/tcp/443\"" .config/config.yml; then
    sudo sed -i '/^ *engine:/a\  statsMultiaddr: "/dns/stats.quilibrium.com/tcp/443"' .config/config.yml || { echo "Failed to enable Stats Collection! Exiting..."; exit 1; }
else
    echo "Stats Collection already enabled."
fi

# Check if both lines were added successfully
if line_exists "listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/8337" .config/config.yml && line_exists "  statsMultiaddr: \"/dns/stats.quilibrium.com/tcp/443\"" .config/config.yml; then
    echo "Success: The script successfully edited your config.yml file."
else
    echo "ERROR: The script failed to correctly edit your config.yml file."
    echo "You may want to follow the online guide to do it manually."
    exit 1
fi

echo "gRPC calls setup was successful."
}

update_node() {
    echo "Updating node..."
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
echo "🎉 Welcome to Quilibrium Ceremonyclient $VERSION"
}

check_visibility() {
    echo "⏳Processing..."
    sleep 2  # Add a 2-second delay

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
    cd ~/ceremonyclient/node && ./$NODE_BINARY -node-info
}


node_logs() {
    echo "Getting node logs..."
    sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat
    # sudo journalctl -u ceremonyclient.service -n 100 --no-hostname -o cat
}

restart_node() {
    echo "Restarting node..."
    service ceremonyclient restart
}

stop_node() {
    echo "Stopping node..."
    service ceremonyclient stop
    echo "Node stopped"
}


# Menu
while true; do
    clear
    echo "This script is made with ❤️ by 0xOzgur.eth @ https://quilibrium.space"
    echo "Welcome to Quilibrium for Dummies!"

echo "
    _____        _ _ _ _           _             
   / ___ \      (_) (_) |         (_)            
  | |   | |_   _ _| |_| | _   ____ _ _   _ ____  
  | |   |_| | | | | | | || \ / ___) | | | |    \ 
   \ \____| |_| | | | | |_) ) |   | | |_| | | | |
    \_____)\____|_|_|_|____/|_|   |_|\____|_|_|_|
                                                 
              ___                                    
             / __)                                   
            | |__ ___   ____                         
            |  __) _ \ / ___)                        
            | | | |_| | |                            
            _|  \___/|_|                            
                                                 
   _____                     _                   
  (____ \                   (_)                  
   _   \ \ _   _ ____  ____  _  ____  ___        
  | |   | | | | |    \|    \| |/ _  )/___)       
  | |__/ /| |_| | | | | | | | ( (/ /|___ |       
  |_____/  \____|_|_|_|_|_|_|_|\____|___/        
                                                 "



    echo "Please choose an option:"
    
    echo "1) Install Prerequisites"
    echo "2) Install Node"
    echo "3) Configure grpCurl"
    echo "4) Update Node"
    echo "5) Check Visibility"
    echo "6) Node Info"
    echo "7) Node Logs"
    echo "8) Restart Node"
    echo "9) Stop Node"
    echo "e) Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1) install_prerequisites ;;
        2) install_node ;;
        3) configure_grpcurl ;;
        4) update_node ;;
        5) check_visibility ;;
        6) node_info ;;
        7) node_logs ;;
        8) restart_node ;;
        9) stop_node ;;
        e) break ;;
        *) echo "Invalid option, please try again." ;;
    esac

    read -n 1 -s -r -p "Press any key to continue"
done