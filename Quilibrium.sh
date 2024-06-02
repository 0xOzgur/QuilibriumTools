#!/bin/bash  -i

# Function for each menu option
install_prerequisites() {
        echo "Installing prerequisites..."
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
    #VERSION="1.4.18"

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
        echo "Enjoy and sit back while you are configuring grpCurl for Quilibrium Ceremony Client!"
    echo "Processing..."
    sleep 10  # Add a 10-second delay


    # Function to check if a line exists in a file
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

check_visibility() {
        echo "Checking visibility..."
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
    cd ~/ceremonyclient/node && ./${NODE_BINARY} -node-info && cd ~
}

# Menu
while true; do
    echo "Welcome! Please choose an option:"
    echo "1) Install Prerequisites"
    echo "2) Install Node"
    echo "3) Configure grpcurl"
    echo "4) Check Visibility"
    echo "5) Node Info"
    echo "6) Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1) install_prerequisites ;;
        2) install_node ;;
        3) configure_grpcurl ;;
        4) check_visibility ;;
        5) node_info ;;
        6) break ;;
        *) echo "Invalid option, please try again." ;;
    esac
done