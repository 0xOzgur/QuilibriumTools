#!/bin/bash

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

# Check if any of the bootstrap peers are in the output
for peer in "${bootstrap_peers[@]}"; do
    decoded_peer=$(echo "$peer" | base64 --decode)
    if [[ $output == *"$decoded_peer"* ]]; then
        echo "You see $decoded_peer as a bootstrap peer"
    else
        echo "Peer $decoded_peer not found"
    fi
done