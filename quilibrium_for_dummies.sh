#!/bin/bash -i

# Source .bashrc to make GO work if it is not working
source ~/.bashrc

clear

# Set the version number

VERSION="2.0.5.1"
qClientVERSION="2.0.4.1"


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

# URLs for scripts
UPDATE_URL="https://raw.githubusercontent.com/0xOzgur/QuilibriumTools/main/update.sh"
PREREQUISITES_URL="https://raw.githubusercontent.com/0xOzgur/QuilibriumTools/main/install/Install_prerequisites.sh"
NODE_INSTALL_URL="https://raw.githubusercontent.com/0xOzgur/QuilibriumTools/main/install/install_quilibrium_service.sh"
GRPCURL_CONFIG_URL="https://raw.githubusercontent.com/0xOzgur/QuilibriumTools/main/configuration/config.sh"
NODE_UPDATE_URL="https://raw.githubusercontent.com/0xOzgur/QuilibriumTools/main/update/update.sh"
CHECK_VISIBILITY_URL="https://raw.githubusercontent.com/0xOzgur/QuilibriumTools/main/visibility_check.sh"

# Function for each menu option
install_prerequisites() {
    echo ""
    echo "⌛️  Preparing server with necessary apps and settings..."
    wget --no-cache -O - "$PREREQUISITES_URL" | bash
}

# Install Node
install_node() {
    echo ""
    echo "⌛️  Installing node as a service..."
    wget --no-cache -O - "$NODE_INSTALL_URL" | bash
}

configure_grpcurl() {
    echo ""
    echo "⌛️  Configuring grpCurl..."
    wget --no-cache -O - "$GRPCURL_CONFIG_URL" | bash
}

update_node() {
    echo ""
    echo "⌛️  Updating node..."
    wget --no-cache -O - "$NODE_UPDATE_URL" | bash
}

check_visibility() {
    echo ""
    echo "⌛️  Checking visibility..."
    wget --no-cache -O - "$CHECK_VISIBILITY_URL" | bash
}

node_info() {
    echo "Getting node info..."
    cd ~/ceremonyclient/node && ./$NODE_BINARY -node-info
}


node_logs() {
    echo "Getting node logs..."
    sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat
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
    echo "This script is made with ❤️ by 0xOzgur @ https://quilibrium.space"
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

    echo "Welcome you Dummy!"
    echo "Please follow insturctions very carefully"
    echo "Please install prerequisites first, then install node, lastly configure grpcurl."
    echo "Do not forget to restart the node after configuration."
    echo ""
    echo "Quilibrium Version: $VERSION"
    echo ""
    echo "Please choose an option:"
    echo ""
    echo "1) Install Prerequisites      5) Check Visibility         9) Stop Node"
    echo "2) Install Node               6) Node Info                e) Exit"
    echo "3) Configure grpCurl          7) Node Logs"
    echo "4) Update Node                8) Restart Node"

    echo ""
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
    echo ""
    read -n 1 -s -r -p "Press any key to continue"
done
