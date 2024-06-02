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
"EiD1ClZn/lr+n/gnS96Q4gKwBDk3yl33kNIhx9wUxJiyEA=="
"EiD7C6nsh1456MTlTihUrDqO4tLn/wcb1HXM5V7P5GXEQ=="
"EiDUezzC3QCy6pNVg6+L9l0rH6CVIQSqxEKAGMSQJqnO1g=="
"EiDLg4I2+SAV7f0dUfT/qwDJWAstv1CAYmbhvJG3LxrgZw=="
"EiALqqXPhdT+LWlx2cbx3vYiFGxeUhv+KgyhE+MT8g7fLg=="
"EiAhM5Eo0QoOQVPCJqrDCC+qe+Kx3kGohU5q+1rb5voD7A=="
"EiC3Li+DpEtPnomK9KWzAWtW7XUzVKUewNVrURiKSeWsfg=="
"EiBaq9Jsbu2vW+rFVrqI288t298TJUy+/xv8IF3V8uN1Xg=="
"EiAkOMWQQAGlDDINXrhSJmnwi0LVdkFv1wLGtrp3FrYxPg=="
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