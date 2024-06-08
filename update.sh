#!/bin/bash

# Step 0: Welcome
echo "This script is made with ❤️ by 0xOzgur.eth @ https://quilibrium.space"
echo "⏳Enjoy and sit back while you are upgrading your Quilibrium Node to v1.4.19!"
echo "The script is prepared for Ubuntu machines. If you are using another operating system, please check the compatibility of the script."
echo "⏳Processing..."
sleep 5  # Add a 5-second delay

# Stop the ceremonyclient service
service ceremonyclient stop

apt install cpulimit -y
apt install gawk -y #incase it is not installed

# Step 1:Download Binary
echo "⏳ Downloading New Release v1.4.19"
cd  ~/ceremonyclient
git remote set-url origin https://source.quilibrium.com/quilibrium/ceremonyclient.git || git remote set-url origin https://git.quilibrium-mirror.ch/agostbiro/ceremonyclient.git
git pull
git checkout release-cdn

# Get the current user's home directory
HOME=$(eval echo ~$HOME_DIR)

# Use the home directory in the path
NODE_PATH="$HOME/ceremonyclient/node"
EXEC_START="$NODE_PATH/release_autorun.sh"

# Step 3:Re-Create Ceremonyclient Service
echo "⏳ Re-Creating Ceremonyclient Service"
sleep 2  # Add a 2-second delay
SERVICE_FILE="/lib/systemd/system/ceremonyclient.service"
if [ ! -f "$SERVICE_FILE" ]; then
    echo "📝 Creating new ceremonyclient service file..."
    if ! sudo tee "$SERVICE_FILE" > /dev/null <<EOF
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
    then
        echo "❌ Error: Failed to create ceremonyclient service file." >&2
        exit 1
    fi
else
    echo "🔍 Checking existing ceremonyclient service file..."
    # Check if the required lines exist and if they are different
    if ! grep -q "WorkingDirectory=$NODE_PATH" "$SERVICE_FILE" || ! grep -q "ExecStart=$EXEC_START" "$SERVICE_FILE"; then
        echo "🔄 Updating existing ceremonyclient service file..."
        # Replace the existing lines with new values
        sudo sed -i "s|WorkingDirectory=.*|WorkingDirectory=$NODE_PATH|" "$SERVICE_FILE"
        sudo sed -i "s|ExecStart=.*|ExecStart=$EXEC_START|" "$SERVICE_FILE"
    else
        echo "✅ No changes needed."
    fi
fi

# Step 4:Start the ceremonyclient service
echo "✅ Starting Ceremonyclient Service"
sleep 2  # Add a 2-second delay
sudo systemctl daemon-reload
sudo systemctl enable ceremonyclient
sudo service ceremonyclient start

# See the logs of the ceremonyclient service
echo "🎉 Welcome to Quilibrium Ceremonyclient v1.4.19"
echo "⏳ Please let it flow node logs at least 5 minutes then you can press CTRL + C to exit the logs."
sleep 5  # Add a 5-second delay
sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat
