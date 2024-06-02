#!/bin/bash

# Step 0: Welcome
echo "This script is made with ❤️ by https://quilibrium.space @ 0xOzgur.eth"
echo "⏳You need GO and grpcurl installed on your machine to run this script. If you don't have them, please install them first."
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