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
echo -e "${GREEN}  🚀 Welcome to the OpenWork Orchestrator Installer 🚀  ${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""

# Step 1: Update and upgrade the system
echo -e "${YELLOW}[1/3] Updating and upgrading your Ubuntu system...${NC}"
echo "This might take a minute depending on your connection..."
sudo apt update -y
sudo apt upgrade -y
echo -e "${GREEN}✔ System update complete!${NC}\n"

# Step 2: Install required dependencies
echo -e "${YELLOW}[2/3] Installing necessary dependencies (curl, Node.js, npm)...${NC}"
# Installing curl and the standard Node.js/npm packages from the Ubuntu repository
sudo apt install -y curl nodejs npm
echo -e "${GREEN}✔ Dependencies installed!${NC}\n"

# Step 3: Install OpenWork Orchestrator
echo -e "${YELLOW}[3/3] Installing OpenWork Orchestrator globally via npm...${NC}"
sudo npm install -g openwork-orchestrator
echo -e "${GREEN}✔ OpenWork Orchestrator installed successfully!${NC}\n"

# Final Success Message
echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}🎉 All done! OpenWork Orchestrator is ready to go. 🎉${NC}"
echo ""
echo -e "To start OpenWork in your workspace, run the following command:"
echo -e "${YELLOW}openwork start --workspace /path/to/your/workspace --approval auto${NC}"
echo ""
echo -e "Once it starts, copy the ${YELLOW}OpenWork URL${NC} and ${YELLOW}OpenWork Owner Token${NC} into your OpenWork Desktop App to connect your remote workspace."
echo -e "${BLUE}======================================================${NC}"
