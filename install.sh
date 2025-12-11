#!/bin/bash
# =============================================================================
# dsdep Quick Install Script
# 
# Usage:
#   curl -sSL https://raw.githubusercontent.com/ripiktech/dsdep/main/install.sh | sudo bash
#
# Or:
#   wget -qO- https://raw.githubusercontent.com/ripiktech/dsdep/main/install.sh | sudo bash
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO_URL="https://github.com/ripiktech/dsdep"
RAW_URL="https://raw.githubusercontent.com/ripiktech/dsdep/main"
INSTALL_DIR="/usr/local/bin"
SHARE_DIR="/usr/local/share/dsdep"

echo -e "${CYAN}"
cat << 'EOF'
    ____  _____ ____  _____ ____  
   / __ \/ ___// __ \/ ___// __ \ 
  / / / /\__ \/ / / /\__ \/ /_/ / 
 / /_/ /___/ / /_/ /___/ / ____/  
/_____//____/_____//____/_/       
                                   
EOF
echo -e "${NC}"
echo "Installing dsdep - Data Science Deployment Tool"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Check for dependencies
echo -e "${CYAN}Checking dependencies...${NC}"

for cmd in curl git; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${YELLOW}Installing $cmd...${NC}"
        apt-get update -qq
        apt-get install -y -qq $cmd
    fi
done

echo -e "${GREEN}Dependencies OK${NC}"

# Create directories
echo -e "${CYAN}Creating directories...${NC}"
mkdir -p "$INSTALL_DIR"
mkdir -p "$SHARE_DIR/templates"

# Download main script
echo -e "${CYAN}Downloading dsdep...${NC}"
curl -sSL "$RAW_URL/bin/dsdep" -o "$INSTALL_DIR/dsdep"
chmod +x "$INSTALL_DIR/dsdep"

# Download templates
echo -e "${CYAN}Downloading templates...${NC}"
curl -sSL "$RAW_URL/templates/requirements.txt" -o "$SHARE_DIR/templates/requirements.txt"

# Verify installation
echo ""
if [ -x "$INSTALL_DIR/dsdep" ]; then
    echo -e "${GREEN}✓ dsdep installed successfully!${NC}"
    echo ""
    echo "Version: $($INSTALL_DIR/dsdep --version)"
    echo ""
    echo -e "${CYAN}Getting started:${NC}"
    echo "  dsdep --help"
    echo ""
    echo -e "${CYAN}Example:${NC}"
    echo "  sudo dsdep -r https://github.com/user/project -c myenv"
    echo ""
else
    echo -e "${RED}✗ Installation failed${NC}"
    exit 1
fi
