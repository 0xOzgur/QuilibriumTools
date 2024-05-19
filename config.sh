#!/bin/bash

# Step 0: Welcome
echo "This script is prepared by 0xOzgur.eth"
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