#!/bin/bash

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"
source "${SCRIPT_DIR}/core/common.sh"

ensure_dirs

show_tui() {
    clear
    printf '%b\n' "${CYAN}╔══════════════════════════════════════════════╗${NC}"
    printf '%b' "${CYAN}║${NC} "
    printf '%b' "${GREEN}Free Fire Memory Reader - TUI${NC}"
    printf '%b\n' "${CYAN} ║${NC}"
    printf '%b\n' "${CYAN}╚══════════════════════════════════════════════╝${NC}"
    printf '%b\n' "${BLUE}1) Status\n2) Processes\n3) Scanner\n4) Dumper\n5) Hooker\n6) Logs\n7) Clean\n8) Back to main menu\n9) Exit${NC}"
    printf '\n'
}

run_from_tui() {
    while true; do
        show_tui
        read -r -p "Choice [1-9]: " choice
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
                if ! ensure_dependencies; then
                    read -r -p "Press Enter to continue..." _
                    continue
                fi
                "$SCRIPT_DIR/freefire_reader.sh" scanner
                read -r -p "Press Enter to continue..." _
                ;;
            4)
                if ! ensure_dependencies; then
                    read -r -p "Press Enter to continue..." _
                    continue
                fi
                "$SCRIPT_DIR/freefire_reader.sh" dumper
                read -r -p "Press Enter to continue..." _
                ;;
            5)
                if ! ensure_dependencies; then
                    read -r -p "Press Enter to continue..." _
                    continue
                fi
                "$SCRIPT_DIR/freefire_reader.sh" hooker
                read -r -p "Press Enter to continue..." _
                ;;
            6)
                view_logs
                read -r -p "Press Enter to continue..." _
                ;;
            7)
                clean_cache
                read -r -p "Press Enter to continue..." _
                ;;
            8)
                exec "$SCRIPT_DIR/freefire_reader.sh" menu
                ;;
            9)
                success "Exiting TUI"
                exit 0
                ;;
            *)
                warning "Invalid choice"
                sleep 1
                ;;
        esac
    done
}

run_from_tui

