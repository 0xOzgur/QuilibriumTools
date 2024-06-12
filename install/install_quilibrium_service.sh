#!/bin/bash
# Set the version number
VERSION="1.4.19"
cd ~
# Step 0: Welcome
echo "This script is made with ❤️ by 0xOzgur.eth @ https://quilibrium.space "
echo "The script is prepared for Ubuntu machines. If you are using another operating system, please check the compatibility of the script."
echo "The script doesn't install GO or GrpCurl packages. If you want to install them please visit https://docs.quilibrium.space/installing-prerequisites page."
echo "⏳Enjoy and sit back while you are building your Quilibrium Node!"
echo "⏳Processing..."
sleep 10  # Add a 10-second delay

# Step 1: Update and Upgrade the Machine
echo "Updating the machine"
echo "⏳Processing..."
sleep 2  # Add a 2-second delay

# Fof DEBIAN OS - Check if sudo and git is installed
if ! command -v sudo &> /dev/null
then
    echo "sudo could not be found"
    echo "Installing sudo..."
    su -c "apt update && apt install sudo -y"
else
    echo "sudo is installed"
fi

if ! command -v git &> /dev/null
then
    echo "git could not be found"
    echo "Installing git..."
    su -c "apt update && apt install git -y"
else
    echo "git is installed"
fi

# if ! command -v cpulimit &> /dev/null
# then
#     echo "cpulimit could not be found"
#     echo "Installing cpulimit..."
#     su -c "apt update && apt install cpulimit -y"
# else
#     echo "cpulimit is installed"
# fi

sudo apt upgrade -y

# Step 2: Adjust network buffer sizes
echo "Adjusting network buffer sizes..."
if grep -q "^net.core.rmem_max=600000000$" /etc/sysctl.conf; then
  echo "net.core.rmem_max=600000000 found inside /etc/sysctl.conf, skipping..."
else
  echo -e "\n# Change made to increase buffer sizes for better network performance for ceremonyclient\nnet.core.rmem_max=600000000" | sudo tee -a /etc/sysctl.conf > /dev/null
fi
if grep -q "^net.core.wmem_max=600000000$" /etc/sysctl.conf; then
  echo "net.core.wmem_max=600000000 found inside /etc/sysctl.conf, skipping..."
else
  echo -e "\n# Change made to increase buffer sizes for better network performance for ceremonyclient\nnet.core.wmem_max=600000000" | sudo tee -a /etc/sysctl.conf > /dev/null
fi
sudo sysctl -p

# Step 3: Check if directory ~/ceremonyclient exists, download from github 
if [ -d ~/ceremonyclient ]; then
    # Check if backup directory ~/backup/qnode_keys exists, if not create it
    if [ ! -d ~/backup/qnode_keys ]; then
        mkdir -p ~/backup/qnode_keys
    fi
    
    # Check if files exist, then backup
    if [ -f ~/ceremonyclient/node/.config/keys.yml ]; then
        cp ~/ceremonyclient/node/.config/keys.yml ~/backup/qnode_keys/
        echo "✅ Backup of keys.yml created in ~/backup/qnode_keys folder"
    fi
    
    if [ -f ~/ceremonyclient/node/.config/config.yml ]; then
        cp ~/ceremonyclient/node/.config/config.yml ~/backup/qnode_keys/
        echo "✅ Backup of config.yml created in ~/backup/qnode_keys folder"
    fi
fi

# Step 4:Download Ceremonyclient
echo "⏳Downloading Ceremonyclient"
sleep 1  # Add a 1-second delay
cd ~
if [ -d "ceremonyclient" ]; then
  echo "Directory ceremonyclient already exists, skipping git clone..."
else
  until git clone https://github.com/QuilibriumNetwork/ceremonyclient.git || git clone https://source.quilibrium.com/quilibrium/ceremonyclient.git; do
    echo "Git clone failed, retrying..."
    sleep 2
  done
fi
cd ~/ceremonyclient/
# git remote set-url origin https://github.com/QuilibriumNetwork/ceremonyclient.git || git remote set-url origin https://source.quilibrium.com/quilibrium/ceremonyclient.git 
git checkout release

# Get the system architecture
# ARCH=$(uname -m)

# Step 5:Determine the ExecStart line based on the architecture
# Get the current user's home directory
HOME=$(eval echo ~$HOME_DIR)

# Use the home directory in the path
NODE_PATH="$HOME/ceremonyclient/node"
EXEC_START="$NODE_PATH/release_autorun.sh"

# Step 6:Create Ceremonyclient Service
echo "⏳ Creating Ceremonyclient Service"
sleep 2  # Add a 2-second delay

# Check if the file exists before attempting to remove it
if [ -f "/lib/systemd/system/ceremonyclient.service" ]; then
    # If the file exists, remove it
    rm /lib/systemd/system/ceremonyclient.service
    echo "ceremonyclient.service file removed."
else
    # If the file does not exist, inform the user
    echo "ceremonyclient.service file does not exist. No action taken."
fi

sudo tee /lib/systemd/system/ceremonyclient.service > /dev/null <<EOF
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

sudo systemctl daemon-reload
sudo systemctl enable ceremonyclient

# Step 7: Start the ceremonyclient service
echo "✅Starting Ceremonyclient Service"
sleep 1  # Add a 1-second delay
sudo service ceremonyclient start

# Step 8: See the logs of the ceremonyclient service
echo "🎉Welcome to Quilibrium Ceremonyclient"
echo "⏳Please let it flow node logs at least 5 minutes then you can press CTRL + C to exit the logs."
sleep 5  # Add a 5-second delay
sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat
