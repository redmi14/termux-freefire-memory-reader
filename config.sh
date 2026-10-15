#!/bin/bash

# Free Fire Memory Reader for Termux
# Updated: 2026-10-15

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"
source "${SCRIPT_DIR}/core/common.sh"

ensure_dirs

show_help() {
    cat <<EOF
Free Fire Memory Reader

Usage: ./freefire_reader.sh [command]

Commands:
  menu      Show interactive menu (default)
  tui       Open the upgraded terminal UI
  status    Show environment and dependency status
  processes List processes via Frida/Shizuku
  scanner   Run the memory scanner
  dumper    Run the memory dumper
  hooker    Run the game hooker
  logs      View recent logs
  clean     Clean generated cache and dumps
  help      Show this help

Examples:
  ./freefire_reader.sh status
  ./freefire_reader.sh tui
  ./freefire_reader.sh scanner
EOF
}

show_main_menu() {
    clear
    printf '\n'
    printf '%b\n' "${CYAN}╔══════════════════════════════════════════════╗${NC}"
    printf '%b' "${CYAN}║${NC} "
    printf '%b' "${GREEN}Free Fire Memory Reader - Termux${NC}"
    printf '%b\n' "${CYAN} ║${NC}"
    printf '%b\n' "${CYAN}╚══════════════════════════════════════════════╝${NC}"
    printf '%b\n' "${YELLOW}Using: Shizuku + Frida (No Root Required)${NC}"
    printf '\n'
    printf '  1) Check Status & Requirements\n'
    printf '  2) List Running Processes\n'
    printf '  3) Run Memory Scanner\n'
    printf '  4) Run Memory Dumper\n'
    printf '  5) Run Game Hooker\n'
    printf '  6) Open TUI\n'
    printf '  7) View Logs\n'
    printf '  8) Clean Cache\n'
    printf '  9) Exit\n'
    printf '\n'
}

run_memory_scanner() {
    if ! ensure_dependencies; then
        return 1
    fi

    local pkg
    pkg="$(detect_freefire)"
    if [ -z "$pkg" ]; then
        error "Free Fire not found. Please open the game first."
        return 1
    fi

    success "Detected Free Fire package: $pkg"

    local script_path="${SCRIPT_CACHE}/memory_scanner.js"
    cat > "$script_path" <<'FRIDA_SCRIPT'
console.log("[+] Free Fire Memory Scanner");
console.log("[+] Package: " + Process.id);

console.log("\n[*] Loaded modules:");
var moduleCount = 0;
Process.enumerateModules().forEach(function(module) {
    if (moduleCount < 12) {
        console.log("  " + module.name + " @ " + module.base);
        moduleCount++;
    }
});
if (moduleCount >= 12) {
    console.log("  ... and more");
}

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

console.log("\n[*] Threads:");
var threadCount = 0;
Process.enumerateThreads().forEach(function(thread) {
    if (threadCount < 10) {
        console.log("  Thread " + thread.id);
        threadCount++;
    }
});

console.log("\n[+] Hooking malloc...");
var malloc = Module.findExportByName("libc.so", "malloc");
if (malloc) {
    var count = 0;
    Interceptor.attach(malloc, {
        onEnter: function(args) {
            var size = args[0].toInt32();
            if (size > 10000 && count < 5) {
                console.log("[MALLOC] Size: " + size + " bytes");
                count++;
            }
        }
    });
    console.log("[+] malloc hooked successfully");
} else {
    console.log("[-] Failed to hook malloc");
}

console.log("\n[+] Scan complete! Keep this running to see more data...");
FRIDA_SCRIPT

    log "Running memory scanner against $pkg"
    frida -U -f "$pkg" -l "$script_path" --no-pause
}

run_memory_dumper() {
    if ! ensure_dependencies; then
        return 1
    fi

    local pkg
    pkg="$(detect_freefire)"
    if [ -z "$pkg" ]; then
        error "Free Fire not found. Please open the game first."
        return 1
    fi

    success "Detected Free Fire package: $pkg"

    local script_path="${SCRIPT_CACHE}/memory_dumper.js"
    cat > "$script_path" <<'FRIDA_SCRIPT'
console.log("[+] Free Fire Memory Dumper");
var total = 0;
var readable = 0;
var writable = 0;
var executable = 0;

console.log("\n[*] Memory ranges:");
var rangeCount = 0;
Process.enumerateRanges("---").forEach(function(range) {
    if (rangeCount < 12) {
        console.log("  " + range.base + " - " + range.base.add(range.size) + " (" + range.protection + ")");
        rangeCount++;
    }
    total += range.size;
    if (range.protection.indexOf("r") !== -1) readable += range.size;
    if (range.protection.indexOf("w") !== -1) writable += range.size;
    if (range.protection.indexOf("x") !== -1) executable += range.size;
});

console.log("\n[+] Memory Stats:");
console.log("  Total Mapped: " + (total / 1024 / 1024).toFixed(2) + " MB");
console.log("  Readable: " + (readable / 1024 / 1024).toFixed(2) + " MB");
console.log("  Writable: " + (writable / 1024 / 1024).toFixed(2) + " MB");
console.log("  Executable: " + (executable / 1024 / 1024).toFixed(2) + " MB");
console.log("\n[+] Dump complete!");
FRIDA_SCRIPT

    log "Running memory dumper against $pkg"
    frida -U -f "$pkg" -l "$script_path" --no-pause
}

run_game_hooker() {
    if ! ensure_dependencies; then
        return 1
    fi

    local pkg
    pkg="$(detect_freefire)"
    if [ -z "$pkg" ]; then
        error "Free Fire not found. Please open the game first."
        return 1
    fi

    success "Detected Free Fire package: $pkg"

    local script_path="${SCRIPT_CACHE}/game_hooker.js"
    cat > "$script_path" <<'FRIDA_SCRIPT'
console.log("[+] Free Fire Game Hooker");
var hooked = 0;

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

    log "Running game hooker against $pkg"
    frida -U -f "$pkg" -l "$script_path" --no-pause
}

view_logs() {
    if [ ! -f "$LOG_FILE" ]; then
        error "No log file found yet."
        return 1
    fi
    printf '\n'
    tail -n 50 "$LOG_FILE"
}

clean_cache() {
    mkdir -p "$SCRIPT_CACHE" "$DUMP_DIR"
    rm -rf "${SCRIPT_CACHE:?}"/*
    rm -rf "${DUMP_DIR:?}"/*
    success "Cleared generated scripts and dumps."
}

main_menu() {
    while true; do
        show_main_menu
        read -r -p "Select option [1-9]: " choice

        case "$choice" in
            1)
                show_status
                read -r -p "Press Enter to continue..." _
                ;;
            2)
                list_running_processes
                read -r -p "Press Enter to continue..." _
                ;;
            3)
                run_memory_scanner
                read -r -p "Press Enter to continue..." _
                ;;
            4)
                run_memory_dumper
                read -r -p "Press Enter to continue..." _
                ;;
            5)
                run_game_hooker
                read -r -p "Press Enter to continue..." _
                ;;
            6)
                exec "$SCRIPT_DIR/freefire_tui.sh"
                ;;
            7)
                view_logs
                read -r -p "Press Enter to continue..." _
                ;;
            8)
                clean_cache
                read -r -p "Press Enter to continue..." _
                ;;
            9)
                success "Exiting Free Fire Memory Reader"
                exit 0
                ;;
            *)
                warning "Invalid option. Please try again."
                sleep 1
                ;;
        esac
    done
}

case "${1:-menu}" in
    status)
        show_status
        ;;
    processes)
        list_running_processes
        ;;
    scanner)
        run_memory_scanner
        ;;
    dumper)
        run_memory_dumper
        ;;
    hooker)
        run_game_hooker
        ;;
    tui)
        exec "$SCRIPT_DIR/freefire_tui.sh"
        ;;
    logs)
        view_logs
        ;;
    clean)
        clean_cache
        ;;
    menu)
        ensure_dependencies
        main_menu
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
 esac

