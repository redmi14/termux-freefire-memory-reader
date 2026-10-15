#!/bin/bash

ensure_dirs() {
    mkdir -p "$WORK_DIR" "$LOG_DIR" "$SCRIPT_CACHE" "$DUMP_DIR"
    touch "$LOG_FILE"
}

log() {
    printf '%b\n' "${BLUE}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    printf '%b\n' "${GREEN}✓ $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    printf '%b\n' "${RED}✗ ERROR: $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    printf '%b\n' "${YELLOW}⚠ $1${NC}" | tee -a "$LOG_FILE"
}

ensure_termux() {
    if [ -z "${PREFIX:-}" ]; then
        warning "This tool is designed for Termux. Some checks may be skipped."
        return 1
    fi
    return 0
}

require_cmd() {
    local cmd="$1"
    local hint="${2:-Install the missing dependency first.}"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        error "$cmd is required. $hint"
        return 1
    fi
    return 0
}

frida_connected() {
    frida-ps -U >/dev/null 2>&1
}

detect_freefire() {
    local output
    output="$(frida-ps -U 2>/dev/null || true)"

    if [ -z "$output" ]; then
        return 1
    fi

    local pkg
    for pkg in "${FFPKG_CANDIDATES[@]}"; do
        if printf '%s\n' "$output" | grep -qE "(^|[[:space:]])${pkg}([[:space:]]|$)"; then
            printf '%s\n' "$pkg"
            return 0
        fi
    done

    pkg="$(printf '%s\n' "$output" | grep -i "freefire" | awk '{print $NF}' | head -1)"
    if [ -n "$pkg" ]; then
        printf '%s\n' "$pkg"
        return 0
    fi

    return 1
}

ensure_dependencies() {
    if ! require_cmd python3 "Install with: pkg install python"; then
        return 1
    fi

    if ! require_cmd frida "Install with: pip install frida frida-tools"; then
        return 1
    fi

    if ! frida_connected; then
        warning "Shizuku is not connected or Frida is not active. Some features may fail."
        return 1
    fi

    success "Environment check passed."
    return 0
}

show_status() {
    printf '%b\n' "${CYAN}=== Free Fire Reader Status ===${NC}"

    if command -v python3 >/dev/null 2>&1; then
        success "Python3: $(python3 --version)"
    else
        error "Python3: missing"
    fi

    if command -v frida >/dev/null 2>&1; then
        success "Frida: $(frida --version)"
    else
        error "Frida: missing"
    fi

    if command -v adb >/dev/null 2>&1; then
        success "ADB: $(adb --version 2>/dev/null | head -n 1)"
    else
        warning "ADB: not installed"
    fi

    if [ -n "${PREFIX:-}" ]; then
        success "Termux: detected"
    else
        warning "Termux: not detected"
    fi

    if frida_connected; then
        success "Shizuku/Frida: connected"
    else
        error "Shizuku/Frida: not connected"
    fi

    local pkg
    if pkg="$(detect_freefire 2>/dev/null)"; then
        success "Free Fire package: $pkg"
    else
        warning "Free Fire process: not detected"
    fi

    printf '\n'
    printf 'Work dir: %s\n' "$WORK_DIR"
    printf 'Log file: %s\n' "$LOG_FILE"
}

list_running_processes() {
    if ! frida_connected; then
        error "Shizuku is not connected. Please enable it first."
        return 1
    fi

    printf '%b\n' "${CYAN}=== Frida Processes ===${NC}"
    frida-ps -U | head -n 30
    printf '\n'
    local pkg
    if pkg="$(detect_freefire 2>/dev/null)"; then
        success "Free Fire found: $pkg"
    else
        warning "Free Fire is not running yet."
    fi
}

