#!/bin/bash

APP_NAME="Free Fire Memory Reader"
APP_VERSION="1.1.0"

WORK_DIR="${WORK_DIR:-$HOME/.freefire_reader}"
LOG_DIR="${WORK_DIR}/logs"
SCRIPT_CACHE="${WORK_DIR}/scripts"
DUMP_DIR="${WORK_DIR}/dumps"
LOG_FILE="${LOG_DIR}/reader.log"

FRIDA_TIMEOUT=30
FRIDA_SPAWN_TIMEOUT=60

FFPKG_CANDIDATES=(
    "com.dts.freefireth"
    "com.dts.freefire"
    "com.dts.freefirevn"
    "com.dts.freefireid"
)

MIN_MALLOC_SIZE=10000
MAX_MALLOC_LOGS=10
SCAN_PATTERN="78 9c"
LOG_LEVEL="INFO"
MAX_LOG_SIZE=50
LOG_RETENTION_DAYS=7
ENABLE_PROFILING=false
SCAN_THREADS=4
MAX_SCAN_MEMORY=2048

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

