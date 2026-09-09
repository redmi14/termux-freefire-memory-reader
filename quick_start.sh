#!/bin/bash

################################################################################
# Quick Start Script - One Command Setup
################################################################################

echo "╔════════════════════════════════════════╗"
echo "║  Free Fire Memory Reader - Quick Start ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}[!] Prerequisites:${NC}"
echo "  1. Termux installed"
echo "  2. USB Debugging enabled on phone"
echo "  3. Shizuku app installed and activated"
echo ""

read -p "Do you have all requirements? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo -e "${RED}[!] Please complete requirements first${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[+] Step 1: Updating Termux...${NC}"
apt update && apt upgrade -y

echo ""
echo -e "${BLUE}[+] Step 2: Installing dependencies...${NC}"
apt install -y python3 python3-pip android-tools

echo ""
echo -e "${BLUE}[+] Step 3: Installing Frida...${NC}"
pip install frida frida-tools

echo ""
echo -e "${BLUE}[+] Step 4: Setting up Free Fire Reader...${NC}"
chmod +x freefire_reader.sh

echo ""
echo -e "${YELLOW}[!] Activating Shizuku...${NC}"
echo "    Run this command on your phone via ADB:"
echo -e "    ${GREEN}adb shell sh /sdcard/Android/data/moe.shizuku.privileged.api/files/start.sh${NC}"
echo ""

read -p "Did you activate Shizuku? (y/n): " shizuku_confirm
if [ "$shizuku_confirm" != "y" ]; then
    echo -e "${RED}[!] Please activate Shizuku first${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[+] Step 5: Testing connection...${NC}"
if frida-ps -U &> /dev/null; then
    echo -e "${GREEN}[✓] Shizuku connected successfully!${NC}"
else
    echo -e "${RED}[✗] Shizuku connection failed${NC}"
    echo "    Make sure Shizuku is activated and try again"
    exit 1
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗"
echo "║  Setup Complete! Ready to go!          ║"
echo "╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}[+] Start Free Fire first, then run:${NC}"
echo -e "${GREEN}./freefire_reader.sh${NC}"
echo ""
