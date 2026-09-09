# Examples for Free Fire Memory Reader

## 1. Basic Setup

### Enable Developer Options
```bash
Settings > About phone > Build Number (tap 7 times)
Settings > Developer Options > Enable USB Debugging
```

### Install Shizuku
```bash
# Download from GitHub
https://github.com/RikkaApps/Shizuku/releases

# Install APK
adb install shizuku.apk
```

### Activate Shizuku
```bash
adb shell sh /sdcard/Android/data/moe.shizuku.privileged.api/files/start.sh
```

## 2. Running Memory Scanner

```bash
# Start Free Fire first
# Then run
./freefire_reader.sh

# Select option 3: Run Memory Scanner
# Output:
# [+] Loaded Modules:
#   libunity.so @ 0xf0000000
#   libc.so @ 0xf5000000
# 
# [+] malloc hooked successfully
# [MALLOC] Size: 20480 bytes
# [MALLOC] Size: 51200 bytes
```

## 3. Finding Game Values

### Using Frida Interactive
```bash
frida -U -f com.dts.freefireth

# In Frida prompt:
> var ptr = Module.findExportByName("libil2cpp.so", "il2cpp_string_new")
> Interceptor.attach(ptr, { onEnter: function(args) { console.log(Memory.readCString(args[0])); } })
```

## 4. Custom Frida Script

### Hook Game Functions
```javascript
// hook_game_functions.js

console.log("[+] Hooking game functions...");

// Find il2cpp base
var il2cpp = null;
Process.enumerateModules().forEach(function(m) {
    if (m.name === "libil2cpp.so") {
        il2cpp = m.base;
    }
});

if (il2cpp) {
    console.log("[+] libil2cpp.so @ " + il2cpp);
    
    // Hook il2cpp_string_new
    var il2cpp_string_new = Module.findExportByName("libil2cpp.so", "il2cpp_string_new");
    if (il2cpp_string_new) {
        Interceptor.attach(il2cpp_string_new, {
            onEnter: function(args) {
                var str = Memory.readCString(args[0]);
                if (str && str.length > 0) {
                    console.log("[String] " + str);
                }
            }
        });
    }
}
```

### Run Custom Script
```bash
frida -U -f com.dts.freefireth -l hook_game_functions.js
```

## 5. Memory Dumping

### Dump Specific Range
```javascript
// dump_range.js

var baseAddr = Module.findBaseAddress("libunity.so");
if (baseAddr) {
    var dumpSize = 0x100000;  // 1MB
    var data = Memory.readByteArray(baseAddr, dumpSize);
    console.log("[+] Dumped " + dumpSize + " bytes from libunity.so");
    
    // You can send this to file via frida-tools
    send({type: "dump", data: data});
}
```

## 6. Finding Specific Values

### Search for Player Name
```javascript
// find_player_name.js

var playerName = "YourUsername";  // Change this
var encoded = playerName.charCodeAt(0).toString(16);

console.log("[*] Searching for: " + playerName);

Memory.scan(ptr("0x00000000"), 0x20000000, playerName.substring(0, 3), {
    onMatch: function(address, size) {
        var found = Memory.readCString(address);
        if (found.indexOf(playerName) !== -1) {
            console.log("[+] Found at: " + address + " => " + found);
        }
    },
    onError: function(reason) {
        console.log("[-] Error: " + reason);
    },
    onComplete: function() {
        console.log("[+] Scan complete");
    }
});
```

## 7. Monitoring Memory Allocation

```javascript
// monitor_malloc.js

var malloc = Module.findExportByName("libc.so", "malloc");
var free = Module.findExportByName("libc.so", "free");

var allocCount = 0;
var freeCount = 0;

Interceptor.attach(malloc, {
    onEnter: function(args) {
        allocCount++;
    },
    onLeave: function(retval) {
        var size = this.context.x0.toInt32();  // Android ARM64
        if (size > 5000) {
            console.log("[MALLOC] " + size + " bytes (Total: " + allocCount + ")");
        }
    }
});

Interceptor.attach(free, {
    onEnter: function(args) {
        freeCount++;
    }
});

setInterval(function() {
    console.log("[STATS] Allocations: " + allocCount + ", Frees: " + freeCount);
}, 5000);
```

## 8. Hooking File Operations

```javascript
// hook_files.js

var open = Module.findExportByName("libc.so", "open");

Interceptor.attach(open, {
    onEnter: function(args) {
        var path = Memory.readCString(args[0]);
        var flags = args[1].toInt32();
        
        if (path.indexOf("freefire") !== -1 || path.indexOf("game") !== -1) {
            console.log("[OPEN] " + path + " (flags: " + flags + ")");
        }
    }
});
```

## 9. RPC Communication

```javascript
// rpc_server.js

rpc.exports = {
    getModules: function() {
        var modules = [];
        Process.enumerateModules().forEach(function(m) {
            modules.push({
                name: m.name,
                base: m.base.toString(),
                size: m.size
            });
        });
        return modules;
    },
    
    readMemory: function(address, size) {
        return Memory.readByteArray(ptr(address), size);
    },
    
    writeMemory: function(address, value) {
        Memory.writeInt(ptr(address), value);
        return true;
    }
};
```

### Client Side (Python)
```python
import frida

device = frida.get_usb_device()
process = device.attach('com.dts.freefireth')
session = process.create_script(open('rpc_server.js').read())
session.on('message', lambda msg: print(msg))
session.load()

rpc = session.exports
modules = rpc.get_modules()
print(modules)
```

## 10. Troubleshooting

### Check Shizuku Status
```bash
frida-ps -U

# If connected:
# ID  Name                          Identifier
# --  ----                          ----------
# ...
```

### Check Free Fire Process
```bash
frida-ps -U | grep -i freefire

# Output: PID  com.dts.freefireth
```

### View Real-time Logs
```bash
tail -f ~/.freefire_reader/logs/reader.log
```

### Clear Cache
```bash
rm -rf ~/.freefire_reader/scripts/*
rm -rf ~/.freefire_reader/dumps/*
```

## Important Notes

⚠️ **Warning**: These examples are for educational purposes only.
- Don't use on online games to gain unfair advantage
- Free Fire has anti-cheat (PlaySpan)
- Unauthorized modifications may result in ban
- Use responsibly

✅ **Legal Uses**:
- Research and analysis
- Learning about Android security
- Reverse engineering educational content
- Authorized testing with game developer permission
