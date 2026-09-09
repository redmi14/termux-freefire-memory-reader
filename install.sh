#!/bin/bash

################################################################################
# Free Fire Memory Reader - Installation Script
################################################################################

echo "[+] Free Fire Memory Reader Installation"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running in Termux
if [ ! -d "$PREFIX" ]; then
    echo -e "${RED}[!] This script must be run in Termux${NC}"
    exit 1
fi

echo "[+] Updating package manager..."
apt update -y

echo "[+] Installing dependencies..."
apt install -y python3 python3-pip git wget curl android-tools

echo "[+] Installing Frida and Frida Tools..."
pip install --upgrade pip
pip install frida frida-tools

echo "[+] Creating installation directory..."
mkdir -p $HOME/freefire-reader
cp freefire_reader.sh $HOME/freefire-reader/
chmod +x $HOME/freefire-reader/freefire_reader.sh

echo ""
echo -e "${GREEN}[✓] Installation complete!${NC}"
echo ""
echo "[+] Quick Start:"
echo "    1. Enable USB Debugging on your phone"
echo "    2. Run: adb devices"
echo "    3. Install Shizuku app and activate it"
echo "    4. Run: cd $HOME/freefire-reader"
echo "    5. Run: ./freefire_reader.sh"
echo ""
echo "[+] Or add to PATH:"
echo "    ln -s $(pwd)/freefire_reader.sh $PREFIX/bin/freefire-reader"
echo "    Then run: freefire-reader"
echo ""
