#!/bin/bash

# Navigate to the directory
cd /root/ceremonyclient/client || exit

# Run the command and extract the token balance
balance=$(./qclient token balance | grep -oP '\b\d+(?=\.\d+\s+QUIL)')

# Check if balance is not empty
if [ -n "$balance" ]; then
    # Get the current date in the required format
    current_date=$(date +"%d/%m/%Y")

    # Log the balance value in CSV format
    echo "$current_date,$balance" >> /root/scripts/log/quil_balance.csv
else
    # Get the current date in the required format
    current_date=$(date +"%d/%m/%Y")

    # Log "error" in CSV format
    echo "$current_date,error" >> /root/scripts/log/quil_balance.csv
fi
