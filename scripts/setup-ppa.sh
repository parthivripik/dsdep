#!/bin/bash
# =============================================================================
# Script to setup a PPA (Personal Package Archive) on Launchpad
# 
# This script guides you through creating a PPA for dsdep
# Prerequisites:
#   - Launchpad account (https://launchpad.net)
#   - GPG key registered with Launchpad
#   - debsign, dput installed
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PACKAGE_NAME="dsdep"
VERSION="1.0.0"

echo -e "${CYAN}"
echo "==========================================="
echo " PPA Setup Guide for dsdep"
echo "==========================================="
echo -e "${NC}"

echo "This guide will help you publish dsdep to a PPA."
echo ""

# Check prerequisites
echo -e "${YELLOW}Step 1: Check Prerequisites${NC}"
echo ""

for tool in gpg debsign dput dpkg-buildpackage; do
    if command -v $tool &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $tool"
    else
        echo -e "  ${RED}✗${NC} $tool - Install with: sudo apt-get install devscripts dput"
    fi
done

echo ""
echo -e "${YELLOW}Step 2: Setup GPG Key${NC}"
echo ""
echo "If you don't have a GPG key:"
echo "  gpg --full-generate-key"
echo ""
echo "Export your key to Launchpad:"
echo "  gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID"
echo ""

echo -e "${YELLOW}Step 3: Create Launchpad Account & PPA${NC}"
echo ""
echo "1. Create account at: https://launchpad.net"
echo "2. Register your GPG key at: https://launchpad.net/~/+editpgpkeys"
echo "3. Create a PPA at: https://launchpad.net/~/+activate-ppa"
echo "   - Name: dsdep"
echo "   - Display name: Data Science Deployment Tool"
echo ""

echo -e "${YELLOW}Step 4: Configure dput${NC}"
echo ""
echo "Add this to ~/.dput.cf:"
echo ""
cat << 'EOF'
[dsdep-ppa]
fqdn = ppa.launchpad.net
method = ftp
incoming = ~YOUR_LAUNCHPAD_USERNAME/dsdep/ubuntu/
login = anonymous
allow_unsigned_uploads = 0
EOF
echo ""

echo -e "${YELLOW}Step 5: Build Source Package${NC}"
echo ""
echo "Run these commands from the dsdep-package directory:"
echo ""
echo "  # Update changelog with your details"
echo "  dch -i"
echo ""
echo "  # Build source package"
echo "  debuild -S -sa"
echo ""
echo "  # Upload to PPA"
echo "  dput dsdep-ppa ../dsdep_${VERSION}-1_source.changes"
echo ""

echo -e "${YELLOW}Step 6: Wait for Build${NC}"
echo ""
echo "Launchpad will build the package automatically."
echo "Check status at: https://launchpad.net/~YOUR_USERNAME/+archive/ubuntu/dsdep"
echo ""

echo -e "${YELLOW}Step 7: Users Install With${NC}"
echo ""
echo "  sudo add-apt-repository ppa:YOUR_USERNAME/dsdep"
echo "  sudo apt-get update"
echo "  sudo apt-get install dsdep"
echo ""

echo -e "${GREEN}==========================================="
echo " Alternative: GitHub Releases"
echo "===========================================${NC}"
echo ""
echo "Simpler alternative to PPA:"
echo ""
echo "1. Build the .deb package:"
echo "   make deb"
echo ""
echo "2. Create GitHub Release and upload the .deb file"
echo ""
echo "3. Users install with:"
echo "   wget https://github.com/ripiktech/dsdep/releases/download/v${VERSION}/dsdep_${VERSION}-1_all.deb"
echo "   sudo dpkg -i dsdep_${VERSION}-1_all.deb"
echo ""
