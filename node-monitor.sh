#!/bin/bash

# Define file paths for storing previous values
seniority_file="/tmp/previous_seniority.txt"
balance_file="/tmp/previous_balance.txt"

# Arrays to store the last 30 frame ages
submitting_ages=()
creating_ages=()

# Flags to track the detection of both messages
submitting_proof_detected=false
shard_ring_proof_detected=false

# Function to calculate the average of an array
calculate_average() {
    local arr=("$@")
    local sum=0
    for age in "${arr[@]}"; do
        sum=$(echo "$sum + $age" | bc)
    done
    echo "scale=2; $sum / ${#arr[@]}" | bc
}

# Monitor journalctl for the specific keywords
sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat | grep --line-buffered -E 'submitting data proof|creating data shard ring proof' | while read -r line
do
    # Print a human-readable timestamp
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $line"

    # Check for each specific message, extract frame age, and update arrays
    if [[ "$line" == *"submitting data proof"* ]]; then
        submitting_proof_detected=true
        frame_age=$(echo "$line" | grep -oP '"frame_age":[0-9.]+(?=})' | cut -d: -f2)
        submitting_ages+=("$frame_age")
        # Keep only the last 30 frame ages
        if [ ${#submitting_ages[@]} -gt 30 ]; then
            submitting_ages=("${submitting_ages[@]:1}")
        fi
    elif [[ "$line" == *"creating data shard ring proof"* ]]; then
        shard_ring_proof_detected=true
        frame_age=$(echo "$line" | grep -oP '"frame_age":[0-9.]+(?=})' | cut -d: -f2)
        creating_ages+=("$frame_age")
        # Keep only the last 30 frame ages
        if [ ${#creating_ages[@]} -gt 30 ]; then
            creating_ages=("${creating_ages[@]:1}")
        fi
    fi

    # Only proceed if both messages have been detected
    if $submitting_proof_detected && $shard_ring_proof_detected; then
        # Reset flags for the next cycle
        submitting_proof_detected=false
        shard_ring_proof_detected=false

        # Print the averages for the last 30 frame ages
        echo "Average frame age for 'creating data shard ring proof': $(calculate_average "${creating_ages[@]}")"
        echo "Average frame age for 'submitting data proof': $(calculate_average "${submitting_ages[@]}")"

        # Navigate to the ceremonyclient/node directory
        cd ~/ceremonyclient/node

        # Run the token balance command and filter for the Total balance line
        total_balance=$(./qclient-2.0.3-linux-amd64 token balance | grep -oP 'Total balance: \K[0-9.]+')
        echo "Total balance: $total_balance"

        # Run the node-info command and filter for specific lines
        node_info=$(./node-2.0.3.4-linux-amd64 -node-info)
        seniority=$(echo "$node_info" | grep -oP 'Seniority: \K[0-9]+')
        prover_ring=$(echo "$node_info" | grep 'Prover Ring')
        owned_balance=$(echo "$node_info" | grep 'Owned balance')

        echo "$prover_ring"
        echo "Seniority: $seniority"
        echo "$owned_balance"

        # Load previous values if they exist, otherwise set defaults
        previous_seniority=$(cat "$seniority_file" 2>/dev/null || echo "0")
        previous_balance=$(cat "$balance_file" 2>/dev/null || echo "0")

        # Compare and check if Seniority and Total balance have increased
        if (( seniority > previous_seniority )); then
            echo "Seniority has increased from $previous_seniority to $seniority"
        else
            echo "Seniority has not increased."
        fi

        if (( $(echo "$total_balance > $previous_balance" | bc -l) )); then
            echo "Total balance has increased from $previous_balance to $total_balance"
        else
            echo "Total balance has not increased."
        fi

        # Store current Seniority and Total balance for the next iteration
        echo "$seniority" > "$seniority_file"
        echo "$total_balance" > "$balance_file"
    fi
done
