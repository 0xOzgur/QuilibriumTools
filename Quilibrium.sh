#!/bin/bash
    echo "Welcome! Please choose an option:"
# Menu
while true; do
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

# Function for each menu option
install_prerequisites() {
    echo "Installing prerequisites..."
    # Your code here
}

install_node() {
    echo "Installing node..."
    # Your code here
}

configure_grpcurl() {
    echo "Configuring grpcurl..."
    # Your code here
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
    # Your code here
}

