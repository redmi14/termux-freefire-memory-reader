#!/bin/bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/freefire-reader"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

printf '%b\n' "${BLUE}[+] Free Fire Memory Reader Installation${NC}"

if [ -z "${PREFIX:-}" ]; then
    printf '%b\n' "${RED}[!] This installer is intended for Termux.${NC}"
    exit 1
fi

printf '%b\n' "${YELLOW}[+] Updating package manager...${NC}"
apt update -y || {
    printf '%b\n' "${RED}[!] apt update failed.${NC}"
    exit 1
}

printf '%b\n' "${YELLOW}[+] Installing dependencies...${NC}"
apt install -y python3 python3-pip git wget curl android-tools || {
    printf '%b\n' "${RED}[!] Dependency installation failed.${NC}"
    exit 1
}

printf '%b\n' "${YELLOW}[+] Installing Frida...${NC}"
pip install --upgrade pip
pip install --upgrade frida frida-tools || {
    printf '%b\n' "${RED}[!] Frida installation failed.${NC}"
    exit 1
}

printf '%b\n' "${YELLOW}[+] Preparing installation directory...${NC}"
mkdir -p "$TARGET_DIR"
cp -R "$SCRIPT_DIR"/. "$TARGET_DIR/" || {
    printf '%b\n' "${RED}[!] Failed to copy project files.${NC}"
    exit 1
}

chmod +x "$TARGET_DIR"/*.sh
chmod +x "$TARGET_DIR"/core/*.sh
chmod +x "$TARGET_DIR"/tests/*.sh

ln -sf "$TARGET_DIR/freefire_reader.sh" "$PREFIX/bin/freefire-reader"
ln -sf "$TARGET_DIR/freefire_tui.sh" "$PREFIX/bin/freefire-tui"

printf '%b\n' "${GREEN}[✓] Installation complete!${NC}"
printf '%b\n' "${BLUE}[+] Run:${NC}"
printf '    freefire-reader help\n'
printf '    freefire-reader tui\n'
printf '\n'
printf '%b\n' "${BLUE}[+] Important:${NC}"
printf '  1. Enable USB Debugging on the phone\n'
printf '  2. Install Shizuku and connect it\n'
printf '  3. Open Free Fire, then run freefire-reader tui\n'
printf '\n'

