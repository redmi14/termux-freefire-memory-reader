# Configuration file for Free Fire Memory Reader

# ============================================
# Frida Configuration
# ============================================

# Timeout for Frida connection (seconds)
FRIDA_TIMEOUT=30

# Frida spawn timeout
FRIDA_SPAWN_TIMEOUT=60

# ============================================
# Free Fire Package Names
# ============================================

# Global version
FFPKG_GLOBAL="com.dts.freefire"

# Thailand version
FFPKG_THAI="com.dts.freefireth"

# Vietnamese version
FFPKG_VIETNAM="com.dts.freefirevn"

# Indonesia version  
FFPKG_INDO="com.dts.freefireid"

# ============================================
# Memory Scanner Settings
# ============================================

# Minimum allocation size to log (bytes)
MIN_MALLOC_SIZE=10000

# Maximum malloc logs to display
MAX_MALLOC_LOGS=10

# Memory scan pattern (hex)
SCAN_PATTERN="78 9c"

# ============================================
# Logging
# ============================================

# Log level: DEBUG, INFO, WARNING, ERROR
LOG_LEVEL="INFO"

# Max log file size (MB)
MAX_LOG_SIZE=50

# Keep logs for (days)
LOG_RETENTION_DAYS=7

# ============================================
# Paths
# ============================================

# Working directory
WORK_DIR="$HOME/.freefire_reader"

# Log directory
LOG_DIR="$WORK_DIR/logs"

# Script cache
SCRIPT_CACHE="$WORK_DIR/scripts"

# Dump directory
DUMP_DIR="$WORK_DIR/dumps"

# ============================================
# Performance
# ============================================

# Enable memory profiling
ENABLE_PROFILING=false

# Thread count for scanning
SCAN_THREADS=4

# Max memory to scan (MB)
MAX_SCAN_MEMORY=2048
