#!/bin/bash

################################################################################
# Free Fire Memory Reader for Termux
# Using Shizuku + Frida (No Root Required)
# Author: redmi14
# License: MIT
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="${HOME}/.freefire_reader"
LOG_DIR="${WORK_DIR}/logs"
SCRIPT_CACHE="${WORK_DIR}/scripts"
DUMP_DIR="${WORK_DIR}/dumps"

# Free Fire Package
FFPKG="com.dts.freefireth"
FFPKG_ALT="com.dts.freefire"

# Create directories
mkdir -p "${LOG_DIR}" "${SCRIPT_CACHE}" "${DUMP_DIR}"

################################################################################
# Utility Functions
################################################################################

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1" | tee -a "${LOG_DIR}/reader.log"
}

success() {
    echo -e "${GREEN}✓ $1${NC}" | tee -a "${LOG_DIR}/reader.log"
}

error() {
    echo -e "${RED}✗ ERROR: $1${NC}" | tee -a "${LOG_DIR}/reader.log"
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}" | tee -a "${LOG_DIR}/reader.log"
}

header() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════╗"
    echo "║  $1"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
}

################################################################################
# Check Requirements
################################################################################

check_requirements() {
    header "Checking Requirements"
    
    local missing=0
    
    # Check Frida
    if ! command -v frida &> /dev/null; then
        error "Frida not found. Installing..."
        pip install frida frida-tools 2>&1 | tee -a "${LOG_DIR}/reader.log"
        missing=1
    else
        success "Frida installed: $(frida --version)"
    fi
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        error "Python3 not found"
        return 1
    else
        success "Python3: $(python3 --version)"
    fi
    
    # Check ADB
    if command -v adb &> /dev/null; then
        success "ADB: $(adb --version | head -1)"
    else
        warning "ADB not found (optional)"
    fi
    
    return 0
}

################################################################################
# Check Shizuku Status
################################################################################

check_shizuku() {
    header "Checking Shizuku"
    
    log "Testing Shizuku connection..."
    
    if frida-ps -U &> /dev/null; then
        success "✓ Shizuku is active and ready!"
        return 0
    else
        error "Shizuku not detected"
        echo ""
        echo -e "${YELLOW}Cara mengaktifkan Shizuku:${NC}"
        echo "1. Download & install Shizuku app"
        echo "2. Buka Termux dan jalankan:"
        echo -e "   ${CYAN}adb shell sh /sdcard/Android/data/moe.shizuku.privileged.api/files/start.sh${NC}"
        echo ""
        return 1
    fi
}

################################################################################
# List Running Processes
################################################################################

list_processes() {
    header "Running Processes"
    
    log "Listing all running processes..."
    frida-ps -U | head -20
    
    echo ""
    log "Looking for Free Fire..."
    if frida-ps -U | grep -E "$FFPKG|$FFPKG_ALT|freefir" -i; then
        success "Free Fire is running!"
        return 0
    else
        warning "Free Fire not detected. Please start the game first."
        return 1
    fi
}

################################################################################
# Detect Free Fire Package
################################################################################

detect_freefire() {
    log "Detecting Free Fire package..."
    
    if frida-ps -U | grep -q "$FFPKG"; then
        echo "$FFPKG"
        return 0
    elif frida-ps -U | grep -q "$FFPKG_ALT"; then
        echo "$FFPKG_ALT"
        return 0
    else
        # Try to find by name
        local pkg=$(frida-ps -U | grep -i "freefir" | awk '{print $NF}' | head -1)
        if [ -n "$pkg" ]; then
            echo "$pkg"
            return 0
        fi
        return 1
    fi
}

################################################################################
# Create Frida Scripts
################################################################################

create_memory_scanner() {
    local script_file="${SCRIPT_CACHE}/memory_scanner.js"
    
    cat > "$script_file" << 'FRIDA_SCRIPT'
console.log("[+] Free Fire Memory Scanner");
console.log("[+] Package: " + Process.id);

// 1. List all loaded modules
console.log("\n[*] Loaded Modules:");
var moduleCount = 0;
Process.enumerateModules().forEach(function(module) {
    if (moduleCount < 15) {
        console.log("  " + module.name + " @ " + module.base);
        moduleCount++;
    }
});
if (moduleCount >= 15) {
    console.log("  ... and more");
}

// 2. Find libc
var libcBase = null;
Process.enumerateModules().forEach(function(m) {
    if (m.name.indexOf("libc.so") !== -1) {
        libcBase = m.base;
    }
});

if (libcBase) {
    console.log("\n[+] libc.so found at: " + libcBase);
} else {
    console.log("\n[-] libc.so not found");
}

// 3. List threads
console.log("\n[*] Threads:");
var threadCount = 0;
Process.enumerateThreads().forEach(function(thread) {
    if (threadCount < 10) {
        console.log("  Thread " + thread.id);
        threadCount++;
    }
});

// 4. Hook malloc
console.log("\n[+] Hooking malloc...");
var malloc = Module.findExportByName("libc.so", "malloc");
if (malloc) {
    var mallocCount = 0;
    Interceptor.attach(malloc, {
        onEnter: function(args) {
            var size = args[0].toInt32();
            if (size > 10000 && mallocCount < 5) {
                console.log("[MALLOC] Size: " + size + " bytes");
                mallocCount++;
            }
        }
    });
    console.log("[+] malloc hooked successfully");
} else {
    console.log("[-] Failed to hook malloc");
}

console.log("\n[+] Scan complete! Keep this running to see more data...");
FRIDA_SCRIPT
    
    echo "$script_file"
}

create_memory_dumper() {
    local script_file="${SCRIPT_CACHE}/memory_dumper.js"
    
    cat > "$script_file" << 'FRIDA_SCRIPT'
console.log("[+] Free Fire Memory Dumper");

// Get process info
var processName = Process.id;
console.log("[+] Process ID: " + processName);

// Get memory ranges
console.log("\n[*] Memory Ranges:");
var rangeCount = 0;
Process.enumerateRanges("r--").forEach(function(range) {
    if (rangeCount < 10) {
        console.log("  " + range.base + " - " + range.base.add(range.size) + " (" + range.protection + ")");
        rangeCount++;
    }
});

// Get memory stats
console.log("\n[*] Getting memory statistics...");
var stats = {
    totalMapped: 0,
    readable: 0,
    writable: 0,
    executable: 0
};

Process.enumerateRanges("---").forEach(function(range) {
    stats.totalMapped += range.size;
    if (range.protection.indexOf("r") !== -1) stats.readable += range.size;
    if (range.protection.indexOf("w") !== -1) stats.writable += range.size;
    if (range.protection.indexOf("x") !== -1) stats.executable += range.size;
});

console.log("[+] Memory Stats:");
console.log("  Total Mapped: " + (stats.totalMapped / 1024 / 1024).toFixed(2) + " MB");
console.log("  Readable: " + (stats.readable / 1024 / 1024).toFixed(2) + " MB");
console.log("  Writable: " + (stats.writable / 1024 / 1024).toFixed(2) + " MB");
console.log("  Executable: " + (stats.executable / 1024 / 1024).toFixed(2) + " MB");

console.log("\n[+] Dump complete!");
FRIDA_SCRIPT
    
    echo "$script_file"
}

create_game_hooker() {
    local script_file="${SCRIPT_CACHE}/game_hooker.js"
    
    cat > "$script_file" << 'FRIDA_SCRIPT'
console.log("[+] Free Fire Game Hooker");

// Hook common game functions
var hooked = 0;

// Try to hook strlen
try {
    var strlen = Module.findExportByName("libc.so", "strlen");
    if (strlen) {
        Interceptor.attach(strlen, {
            onEnter: function(args) {
                var str = Memory.readCString(args[0]);
                if (str && str.length > 0 && str.length < 100) {
                    if (str.indexOf("game") !== -1 || str.indexOf("player") !== -1) {
                        console.log("[strlen] " + str);
                    }
                }
            }
        });
        hooked++;
    }
} catch (e) {
    console.log("[-] Failed to hook strlen: " + e);
}

// Try to hook open
try {
    var open = Module.findExportByName("libc.so", "open");
    if (open) {
        Interceptor.attach(open, {
            onEnter: function(args) {
                var path = Memory.readCString(args[0]);
                if (path && path.indexOf("freefire") !== -1) {
                    console.log("[open] " + path);
                }
            }
        });
        hooked++;
    }
} catch (e) {
    console.log("[-] Failed to hook open: " + e);
}

console.log("\n[+] " + hooked + " functions hooked");
console.log("[+] Waiting for game calls...");
FRIDA_SCRIPT
    
    echo "$script_file"
}

################################################################################
# Run Memory Scanner
################################################################################

run_scanner() {
    header "Memory Scanner"
    
    local pkg=$(detect_freefire)
    if [ -z "$pkg" ]; then
        error "Free Fire not found. Please start the game first."
        return 1
    fi
    
    success "Found Free Fire: $pkg"
    
    local script=$(create_memory_scanner)
    log "Running scanner..."
    
    frida -U -f "$pkg" -l "$script" --no-pause
}

################################################################################
# Run Memory Dumper
################################################################################

run_dumper() {
    header "Memory Dumper"
    
    local pkg=$(detect_freefire)
    if [ -z "$pkg" ]; then
        error "Free Fire not found. Please start the game first."
        return 1
    fi
    
    success "Found Free Fire: $pkg"
    
    local script=$(create_memory_dumper)
    log "Running dumper..."
    
    frida -U -f "$pkg" -l "$script" --no-pause
}

################################################################################
# Run Game Hooker
################################################################################

run_hooker() {
    header "Game Hooker"
    
    local pkg=$(detect_freefire)
    if [ -z "$pkg" ]; then
        error "Free Fire not found. Please start the game first."
        return 1
    fi
    
    success "Found Free Fire: $pkg"
    
    local script=$(create_game_hooker)
    log "Running hooker..."
    
    frida -U -f "$pkg" -l "$script" --no-pause
}

################################################################################
# Interactive Menu
################################################################################

show_menu() {
    clear
    header "Free Fire Memory Reader - Termux"
    
    echo -e "${CYAN}Using: Shizuku + Frida (No Root Required)${NC}"
    echo ""
    echo "1) Check Status & Requirements"
    echo "2) List Running Processes"
    echo "3) Run Memory Scanner"
    echo "4) Run Memory Dumper"
    echo "5) Run Game Hooker"
    echo "6) View Logs"
    echo "7) Clean Cache"
    echo "8) Exit"
    echo ""
    read -p "Select option [1-8]: " choice
}

view_logs() {
    header "Recent Logs"
    tail -50 "${LOG_DIR}/reader.log"
}

clean_cache() {
    header "Cleaning Cache"
    rm -rf "${SCRIPT_CACHE}"/*
    rm -rf "${DUMP_DIR}"/*
    success "Cache cleaned"
}

################################################################################
# Main Menu Loop
################################################################################

main() {
    log "Free Fire Memory Reader Started"
    
    # Check requirements on startup
    if ! check_requirements; then
        error "Failed to check requirements"
        return 1
    fi
    
    while true; do
        show_menu
        
        case "$choice" in
            1)
                check_requirements
                check_shizuku
                read -p "Press Enter to continue..."
                ;;
            2)
                list_processes
                read -p "Press Enter to continue..."
                ;;
            3)
                run_scanner
                read -p "Press Enter to continue..."
                ;;
            4)
                run_dumper
                read -p "Press Enter to continue..."
                ;;
            5)
                run_hooker
                read -p "Press Enter to continue..."
                ;;
            6)
                view_logs
                read -p "Press Enter to continue..."
                ;;
            7)
                clean_cache
                read -p "Press Enter to continue..."
                ;;
            8)
                success "Exiting Free Fire Memory Reader"
                log "Free Fire Memory Reader Stopped"
                exit 0
                ;;
            *)
                error "Invalid option"
                sleep 2
                ;;
        esac
    done
}

################################################################################
# Script Entry Point
################################################################################

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
