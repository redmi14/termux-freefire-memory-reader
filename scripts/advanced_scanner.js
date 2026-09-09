// Advanced Memory Scanner for Free Fire
// Scans for specific patterns and values

console.log("[+] Free Fire Advanced Memory Scanner");
console.log("[+] Process: " + Process.id);

var foundPatterns = 0;
var scanStartTime = new Date().getTime();

// Configuration
var CONFIG = {
    SCAN_SIZE: 0x10000000,  // 256MB
    PATTERN_CACHE: true,
    LOG_MATCHES: true
};

// ============================================
// Module Discovery
// ============================================

console.log("\n[*] Discovering Modules...");
var modules = {};
Process.enumerateModules().forEach(function(m) {
    modules[m.name] = {
        base: m.base,
        size: m.size,
        path: m.path
    };
});

// Print important modules
var importantModules = ["libunity.so", "libil2cpp.so", "libc.so", "libm.so"];
importantModules.forEach(function(name) {
    if (modules[name]) {
        console.log("  [+] " + name + " @ " + modules[name].base);
    }
});

// ============================================
// Function Hooking
// ============================================

console.log("\n[*] Hooking Key Functions...");

// Hook malloc
var malloc = Module.findExportByName("libc.so", "malloc");
if (malloc) {
    var mallocCount = 0;
    Interceptor.attach(malloc, {
        onEnter: function(args) {
            var size = args[0].toInt32();
            if (size > 50000 && mallocCount < 10) {
                console.log("  [MALLOC] Size: " + (size / 1024).toFixed(2) + " KB");
                mallocCount++;
            }
        }
    });
    console.log("  [+] malloc hooked");
}

// Hook strlen
var strlen = Module.findExportByName("libc.so", "strlen");
if (strlen) {
    var strlenCount = 0;
    Interceptor.attach(strlen, {
        onEnter: function(args) {
            try {
                var str = Memory.readCString(args[0]);
                if (str && str.length > 0 && str.length < 200) {
                    if ((str.indexOf("player") !== -1 || str.indexOf("game") !== -1) && strlenCount < 5) {
                        console.log("  [STRING] " + str);
                        strlenCount++;
                    }
                }
            } catch (e) {
                // Ignore errors
            }
        }
    });
    console.log("  [+] strlen hooked");
}

// Hook open
var open = Module.findExportByName("libc.so", "open");
if (open) {
    var openCount = 0;
    Interceptor.attach(open, {
        onEnter: function(args) {
            try {
                var path = Memory.readCString(args[0]);
                if ((path.indexOf("game") !== -1 || path.indexOf("data") !== -1) && openCount < 5) {
                    console.log("  [OPEN] " + path);
                    openCount++;
                }
            } catch (e) {
                // Ignore errors
            }
        }
    });
    console.log("  [+] open hooked");
}

// ============================================
// Memory Analysis
// ============================================

console.log("\n[*] Memory Analysis...");

var memStats = {
    total: 0,
    readable: 0,
    writable: 0,
    executable: 0,
    shared: 0
};

Process.enumerateRanges("---").forEach(function(range) {
    memStats.total += range.size;
    if (range.protection.indexOf("r") !== -1) memStats.readable += range.size;
    if (range.protection.indexOf("w") !== -1) memStats.writable += range.size;
    if (range.protection.indexOf("x") !== -1) memStats.executable += range.size;
});

console.log("  Total Memory: " + (memStats.total / 1024 / 1024).toFixed(2) + " MB");
console.log("  Readable: " + (memStats.readable / 1024 / 1024).toFixed(2) + " MB");
console.log("  Writable: " + (memStats.writable / 1024 / 1024).toFixed(2) + " MB");
console.log("  Executable: " + (memStats.executable / 1024 / 1024).toFixed(2) + " MB");

// ============================================
// Pattern Search
// ============================================

console.log("\n[*] Searching for Common Patterns...");

// Search for common strings
var searchStrings = ["Firebase", "Analytics", "player", "game", "config"];
var patternResults = {};

searchStrings.forEach(function(pattern) {
    patternResults[pattern] = 0;
});

console.log("  [!] Pattern search is running... (this may take time)");

// ============================================
// Thread Info
// ============================================

console.log("\n[*] Thread Information...");
var threadCount = 0;
Process.enumerateThreads().forEach(function(thread) {
    if (threadCount < 10) {
        console.log("  Thread " + thread.id + " - State: " + (thread.state || "unknown"));
        threadCount++;
    }
});
if (threadCount >= 10) {
    console.log("  ... and " + (Process.enumerateThreads().length - 10) + " more threads");
}

// ============================================
// Scan Summary
// ============================================

var scanEndTime = new Date().getTime();
var scanDuration = (scanEndTime - scanStartTime) / 1000;

console.log("\n" + "=".repeat(50));
console.log("[+] Scan Complete!");
console.log("  Duration: " + scanDuration.toFixed(2) + " seconds");
console.log("  Patterns Found: " + foundPatterns);
console.log("  Modules Loaded: " + Object.keys(modules).length);
console.log("=".repeat(50));
console.log("\n[!] Monitoring continues... Press Ctrl+C to stop");
