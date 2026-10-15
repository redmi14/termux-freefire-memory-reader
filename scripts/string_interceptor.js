console.log("[+] Advanced Free Fire scanner loaded");
console.log("[+] Process: " + Process.id);

Process.enumerateModules().forEach(function(module) {
    console.log("Module: " + module.name + " @ " + module.base);
});

var libc = Module.findExportByName("libc.so", "malloc");
if (libc) {
    Interceptor.attach(libc, {
        onEnter: function(args) {
            var size = args[0].toInt32();
            if (size > 1024) {
                console.log("[malloc] " + size);
            }
        }
    });
}

console.log("[+] Scanner ready");

