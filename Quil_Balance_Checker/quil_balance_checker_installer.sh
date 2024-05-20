#!/bin/bash

# Step 1: Ensure /root/scripts and /root/scripts/log directories exist
echo "Checking if /root/scripts and /root/scripts/log directories exist..."
if mkdir -p /root/scripts/log; then
    echo "Directories ensured successfully."
else
    echo "Failed to ensure directories." >&2
    exit 1
fi

# Step 2: Create or overwrite quil_balance_checker.sh
echo "Creating or overwriting /root/scripts/quil_balance_checker.sh..."
if echo '#!/bin/bash' > /root/scripts/quil_balance_checker.sh; then
    echo "File /root/scripts/quil_balance_checker.sh created successfully."
else
    echo "Failed to create /root/scripts/quil_balance_checker.sh." >&2
    exit 1
fi

# Step 3: Paste the script content into quil_balance_checker.sh
echo "Adding script content to /root/scripts/quil_balance_checker.sh..."
if echo "#!/bin/bash

# Navigate to the directory
cd /root/ceremonyclient/client || exit

# Run the command and extract the token balance
balance=\$(./qclient token balance | grep -oP '\\b\\d+(?=\\.\\d+\\s+QUIL)')

# Check if balance is not empty
if [ -n \"\$balance\" ]; then
    # Get the current date in the required format
    current_date=\$(date +\"%d/%m/%Y\")

    # Log the balance value in CSV format
    echo \"\$current_date,\$balance\" >> /root/scripts/log/quil_balance.csv
else
    # Get the current date in the required format
    current_date=\$(date +\"%d/%m/%Y\")

    # Log \"error\" in CSV format
    echo \"\$current_date,error\" >> /root/scripts/log/quil_balance.csv
fi
" > /root/scripts/quil_balance_checker.sh; then
    echo "Script content added successfully."
else
    echo "Failed to add script content." >&2
    exit 1
fi

# Step 4: Grant execute permissions
echo "Setting execute permissions for /root/scripts/quil_balance_checker.sh..."
if chmod +x /root/scripts/quil_balance_checker.sh; then
    echo "Execute permissions set successfully."
else
    echo "Failed to set execute permissions." >&2
    exit 1
fi

# Step 5: Create cronjob if not already existing
echo "Checking for existing cronjob..."
if crontab -l | grep -q 'quil_balance_checker.sh'; then
    echo "Cronjob already exists."
else
    echo "Creating new cronjob..."
    if { crontab -l; echo '0 10 * * * export TZ="Europe/Rome" && /root/scripts/quil_balance_checker.sh'; } | crontab -; then
        echo "Cronjob created successfully."
    else
        echo "Failed to create cronjob." >&2
        exit 1
    fi
fi

echo "Installer script executed successfully!"
