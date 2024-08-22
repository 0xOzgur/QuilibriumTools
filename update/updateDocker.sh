#!/bin/bash

# Step 0: Welcome
echo "This script is made with ❤️ by 0xOzgur.eth"
echo "⏳Enjoy and sit back while you are upgrading your Quilibrium Node to v1.4.21.1!"
echo "⏳Processing..."
sleep 10  # Add a 10-second delay

# Stop the ceremonyclient service
service ceremonyclient stop

# Step 1:Download Binary
echo "⏳ Downloading New Release v1.4.21.1"
cd  ~/ceremonyclient
git pull
git checkout release-cdn

# Step 7:Build Docker Container
echo "⏳Building Ceremonyclient Container"
sleep 2  # Add a 2-second delay
docker build --build-arg GIT_COMMIT=$(git log -1 --format=%h) -t quilibrium -t quilibrium:1.4.21.1 .

# Step 8:Run Ceremonyclient Container
echo "✅Running Ceremonyclient Container"
sleep 2  # Add a 2-second delay
docker compose -f docker/docker-compose.yml up -d

# Step 9:Logs Ceremonyclient Container
echo "🎉Welcome to Quilibrium Ceremonyclient"
echo "⏳Please let it flow node logs at least 5 minutes then you can press CTRL + C to exit the logs."
sleep 5  # Add a 5-second delay
docker compose -f docker/docker-compose.yml logs -f -n, --tail 100