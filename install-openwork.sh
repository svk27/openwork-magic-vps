#!/bin/bash

# Define colors for our friendly UI
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Exit immediately if a command exits with a non-zero status
set -e

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  🚀 Welcome to the OpenWork + Docker Installer 🚀    ${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""

# Step 1: Update and upgrade the system
echo -e "${YELLOW}[1/4] Updating and upgrading your Ubuntu system...${NC}"
echo "This might take a minute depending on your connection..."
sudo apt-get update -y
sudo apt-get upgrade -y
echo -e "${GREEN}✔ System update complete!${NC}\n"

# Step 2: Install required dependencies
echo -e "${YELLOW}[2/4] Installing base dependencies (curl, Node.js, npm)...${NC}"
sudo apt-get install -y ca-certificates curl nodejs npm
echo -e "${GREEN}✔ Base dependencies installed!${NC}\n"

# Step 3: Install Docker
echo -e "${YELLOW}[3/4] Installing Docker Engine...${NC}"
# Add Docker's official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to the docker group so sudo isn't required for docker commands
sudo usermod -aG docker $USER
echo -e "${GREEN}✔ Docker installed and configured!${NC}\n"

# Step 4: Install OpenWork Orchestrator
echo -e "${YELLOW}[4/4] Installing OpenWork Orchestrator globally via npm...${NC}"
sudo npm install -g openwork-orchestrator
echo -e "${GREEN}✔ OpenWork Orchestrator installed successfully!${NC}\n"

# Final Success Message
echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}🎉 All done! OpenWork and Docker are ready to go. 🎉${NC}"
echo ""
echo -e "${RED}IMPORTANT: Since we just installed Docker and added you to the docker group,${NC}"
echo -e "${RED}you MUST log out and log back in (or restart your terminal) for it to work.${NC}"
echo ""
echo -e "After reloading your terminal, you can use EasyWorkspace:"
echo -e "  ${YELLOW}easyworkspace start${NC}"
echo -e "${BLUE}======================================================${NC}"
