// Game String Interceptor
// Captures all string operations in Free Fire

console.log("[+] Free Fire Game String Interceptor");

var capturedStrings = {};
var stringCount = 0;

// ============================================
// String Capture
// ============================================

console.log("[*] Setting up string interception...");

// Intercept sprintf
try {
    var sprintf = Module.findExportByName("libc.so", "sprintf");
    if (sprintf) {
        Interceptor.attach(sprintf, {
            onLeave: function(retval) {
                try {
                    var result = Memory.readCString(this.context.x0);
                    if (result && result.length > 0 && result.length < 256) {
                        if (!capturedStrings[result]) {
                            capturedStrings[result] = 0;
                        }
                        capturedStrings[result]++;
                        stringCount++;
                        
                        if (stringCount <= 20) {
                            console.log("[STRING] " + result);
                        }
                    }
                } catch (e) {}
            }
        });
        console.log("[+] sprintf hooked");
    }
} catch (e) {
    console.log("[-] Failed to hook sprintf: " + e);
}

// Intercept strcpy
try {
    var strcpy = Module.findExportByName("libc.so", "strcpy");
    if (strcpy) {
        Interceptor.attach(strcpy, {
            onEnter: function(args) {
                try {
                    var src = Memory.readCString(args[1]);
                    if (src && src.length > 0 && src.length < 256) {
                        if (stringCount < 50) {
                            console.log("[STRCPY] " + src);
                            stringCount++;
                        }
                    }
                } catch (e) {}
            }
        });
        console.log("[+] strcpy hooked");
    }
} catch (e) {}

// Intercept strcat
try {
    var strcat = Module.findExportByName("libc.so", "strcat");
    if (strcat) {
        Interceptor.attach(strcat, {
            onEnter: function(args) {
                try {
                    var cat = Memory.readCString(args[1]);
                    if (cat && cat.length > 0 && cat.length < 256) {
                        console.log("[STRCAT] " + cat);
                    }
                } catch (e) {}
            }
        });
        console.log("[+] strcat hooked");
    }
} catch (e) {}

// ============================================
// ilCpp String Interception
// ============================================

console.log("[*] Looking for il2cpp string functions...");

try {
    var il2cpp_string_new = Module.findExportByName("libil2cpp.so", "il2cpp_string_new");
    if (il2cpp_string_new) {
        Interceptor.attach(il2cpp_string_new, {
            onEnter: function(args) {
                try {
                    var str = Memory.readCString(args[0]);
                    if (str && str.length > 0) {
                        console.log("[IL2CPP] " + str);
                    }
                } catch (e) {}
            }
        });
        console.log("[+] il2cpp_string_new hooked");
    }
} catch (e) {}

// ============================================
// Statistics
// ============================================

setInterval(function() {
    var uniqueStrings = Object.keys(capturedStrings).length;
    console.log("\n[STATS] Captured " + uniqueStrings + " unique strings, " + stringCount + " total calls");
}, 30000);

console.log("\n[+] String interception active. Keep this running to capture strings...");
