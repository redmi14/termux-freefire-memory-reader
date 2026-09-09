#!/bin/bash

################################################################################
# Utility Script to manage Free Fire Memory Reader
################################################################################

set -e

WORK_DIR="${HOME}/.freefire_reader"
LOG_DIR="${WORK_DIR}/logs"
DUMP_DIR="${WORK_DIR}/dumps"
SCRIPT_DIR="${WORK_DIR}/scripts"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    cat << EOF
Free Fire Memory Reader - Utility Tool

Usage: $(basename "$0") [COMMAND] [OPTIONS]

Commands:
    status              Show current status
    list-processes      List running processes
    clear-logs          Clear old log files
    clear-dumps         Clear old dump files
    show-logs           Show recent logs
    install-adb         Install/update ADB
    check-deps          Check all dependencies
    help                Show this help message

Examples:
    $(basename "$0") status
    $(basename "$0") show-logs
    $(basename "$0") check-deps

EOF
}

show_status() {
    echo -e "${BLUE}[*] Free Fire Memory Reader Status${NC}"
    echo ""
    
    # Check Frida
    if command -v frida &> /dev/null; then
        echo -e "${GREEN}✓${NC} Frida: $(frida --version)"
    else
        echo -e "${RED}✗${NC} Frida: NOT INSTALLED"
    fi
    
    # Check Python
    if command -v python3 &> /dev/null; then
        echo -e "${GREEN}✓${NC} Python: $(python3 --version)"
    else
        echo -e "${RED}✗${NC} Python: NOT INSTALLED"
    fi
    
    # Check Termux
    if [ -n "$PREFIX" ]; then
        echo -e "${GREEN}✓${NC} Termux: Detected"
    else
        echo -e "${RED}✗${NC} Termux: Not detected"
    fi
    
    # Check Shizuku
    if frida-ps -U &> /dev/null; then
        echo -e "${GREEN}✓${NC} Shizuku: Connected"
    else
        echo -e "${RED}✗${NC} Shizuku: Not connected"
    fi
    
    # Check directories
    echo ""
    echo -e "${BLUE}[*] Directories:${NC}"
    echo "  Work Dir: $WORK_DIR"
    echo "  Logs: $LOG_DIR ($(ls -1 "$LOG_DIR" 2>/dev/null | wc -l) files)"
    echo "  Dumps: $DUMP_DIR ($(ls -1 "$DUMP_DIR" 2>/dev/null | wc -l) files)"
    echo ""
}

list_processes() {
    echo -e "${BLUE}[*] Running Processes${NC}"
    echo ""
    
    if ! frida-ps -U &> /dev/null; then
        echo -e "${RED}[!] Shizuku not connected${NC}"
        return 1
    fi
    
    frida-ps -U | head -30
    echo ""
    echo -e "${YELLOW}[!] Total processes: $(frida-ps -U | wc -l)${NC}"
}

clear_logs() {
    echo -e "${BLUE}[*] Clearing old logs...${NC}"
    find "$LOG_DIR" -type f -mtime +7 -delete
    echo -e "${GREEN}✓ Done${NC}"
}

clear_dumps() {
    echo -e "${BLUE}[*] Clearing old dumps...${NC}"
    find "$DUMP_DIR" -type f -mtime +7 -delete
    echo -e "${GREEN}✓ Done${NC}"
}

show_logs() {
    if [ ! -f "$LOG_DIR/reader.log" ]; then
        echo -e "${RED}[!] No logs found${NC}"
        return 1
    fi
    
    echo -e "${BLUE}[*] Recent Logs (last 50 lines)${NC}"
    echo ""
    tail -50 "$LOG_DIR/reader.log"
}

install_adb() {
    echo -e "${BLUE}[*] Installing ADB...${NC}"
    
    if command -v adb &> /dev/null; then
        echo -e "${GREEN}✓ ADB already installed${NC}"
        adb version
        return 0
    fi
    
    echo "Installing android-tools..."
    apt install -y android-tools
    
    if command -v adb &> /dev/null; then
        echo -e "${GREEN}✓ ADB installed successfully${NC}"
        adb version
    else
        echo -e "${RED}✗ Failed to install ADB${NC}"
        return 1
    fi
}

check_deps() {
    echo -e "${BLUE}[*] Checking Dependencies...${NC}"
    echo ""
    
    local missing=0
    
    # Check Termux
    if [ -z "$PREFIX" ]; then
        echo -e "${RED}✗${NC} Termux: Not running in Termux"
        missing=1
    else
        echo -e "${GREEN}✓${NC} Termux: OK"
    fi
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}✗${NC} Python3: NOT INSTALLED"
        missing=1
    else
        echo -e "${GREEN}✓${NC} Python3: $(python3 --version)"
    fi
    
    # Check Pip
    if ! command -v pip &> /dev/null; then
        echo -e "${RED}✗${NC} Pip: NOT INSTALLED"
        missing=1
    else
        echo -e "${GREEN}✓${NC} Pip: OK"
    fi
    
    # Check Frida
    if ! command -v frida &> /dev/null; then
        echo -e "${RED}✗${NC} Frida: NOT INSTALLED"
        echo "  Install with: pip install frida frida-tools"
        missing=1
    else
        echo -e "${GREEN}✓${NC} Frida: $(frida --version)"
    fi
    
    # Check ADB
    if ! command -v adb &> /dev/null; then
        echo -e "${YELLOW}⚠${NC} ADB: NOT INSTALLED (optional)"
        echo "  Install with: apt install android-tools"
    else
        echo -e "${GREEN}✓${NC} ADB: OK"
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}⚠${NC} Git: NOT INSTALLED (optional)"
    else
        echo -e "${GREEN}✓${NC} Git: OK"
    fi
    
    echo ""
    
    if [ $missing -eq 0 ]; then
        echo -e "${GREEN}[✓] All dependencies satisfied!${NC}"
        return 0
    else
        echo -e "${RED}[✗] Some dependencies are missing${NC}"
        return 1
    fi
}

# Main
case "${1:-help}" in
    status)
        show_status
        ;;
    list-processes)
        list_processes
        ;;
    clear-logs)
        clear_logs
        ;;
    clear-dumps)
        clear_dumps
        ;;
    show-logs)
        show_logs
        ;;
    install-adb)
        install_adb
        ;;
    check-deps)
        check_deps
        ;;
    help)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac
