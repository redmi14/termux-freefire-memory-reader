# Free Fire Memory Reader for Termux

🎮 **Công cụ đọc RAM game Free Fire trên Termux mà không cần root!**

Sử dụng **Shizuku + Frida** để truy cập bộ nhớ game mà vẫn giữ an toàn và không cần quyền root.

## ✨ Tính Năng

- ✅ **Không cần Root** - Sử dụng Shizuku thay thế
- ✅ **Memory Scanner** - Quét bộ nhớ game
- ✅ **Memory Dumper** - Lưu bộ nhớ ra file
- ✅ **Game Hooker** - Hook các hàm game
- ✅ **Real-time Monitoring** - Theo dõi bộ nhớ live
- ✅ **Process Lister** - Liệt kê các process chạy
- ✅ **Log Viewer** - Xem log chi tiết

## 📋 Yêu cầu

### Hardware
- Android 8.0+ (phiên bản khuyến nghị: Android 10+)
- Termux app
- Ít nhất 500MB RAM trống
- USB Debugging enabled

### Software
- **Shizuku** app (không cần root)
- **Frida Tools**
- **Python 3.7+**
- **ADB** (Android Debug Bridge)

## 🚀 Cài đặt Nhanh

### Bước 1: Chuẩn bị
```bash
# Trên điện thoại:
1. Bật USB Debugging (Settings > Developer Options)
2. Download Shizuku app từ https://github.com/RikkaApps/Shizuku/releases
3. Cài đặt Shizuku

# Trên PC (tùy chọn, nếu không có adb trên Termux):
adb devices
```

### Bước 2: Mở Termux
```bash
# Update
apt update && apt upgrade -y

# Clone repository
git clone https://github.com/redmi14/termux-freefire-memory-reader.git
cd termux-freefire-memory-reader

# Cài đặt nhanh
bash quick_start.sh
```

### Bước 3: Kích hoạt Shizuku
```bash
# Từ Termux hoặc PC (via ADB):
adb shell sh /sdcard/Android/data/moe.shizuku.privileged.api/files/start.sh

# Hoặc từ Termux nếu có root:
su -c "sh /sdcard/Android/data/moe.shizuku.privileged.api/files/start.sh"
```

### Bước 4: Chạy Tool
```bash
# Mở Free Fire trước!
./freefire_reader.sh
```

## 📖 Hướng dẫn Sử dụng

### Menu Chính

```
1) Check Status & Requirements    - Kiểm tra yêu cầu
2) List Running Processes          - Liệt kê process
3) Run Memory Scanner              - Quét bộ nhớ
4) Run Memory Dumper               - Lưu bộ nhớ
5) Run Game Hooker                 - Hook hàm game
6) View Logs                        - Xem log
7) Clean Cache                      - Xóa cache
8) Exit                             - Thoát
```

### Ví dụ: Quét Bộ Nhớ Game

```bash
$ ./freefire_reader.sh
[Chọn] 1  # Kiểm tra yêu cầu

✓ Frida installed
✓ Python3 installed
✓ Shizuku is active and ready!

[Chọn] 3  # Chạy Memory Scanner

[+] Found Free Fire: com.dts.freefireth
[+] Running scanner...

[+] Loaded Modules:
  libunity.so @ 0xf0000000
  libil2cpp.so @ 0xf2000000
  libc.so @ 0xf5000000
  ...

[+] libc.so found at: 0xf5000000
[+] Hooking malloc...
[+] malloc hooked successfully

[MALLOC] Size: 20480 bytes
[MALLOC] Size: 51200 bytes
[+] Scan complete!
```

### Ví dụ: Dump Bộ Nhớ

```bash
[Chọn] 4  # Dump Memory

[+] Found Free Fire: com.dts.freefireth
[+] Running dumper...

[*] Memory Ranges:
  0x12c00000 - 0x12c10000 (r--)
  0x12c10000 - 0x12c20000 (rwx)
  ...

[+] Memory Stats:
  Total Mapped: 1234.56 MB
  Readable: 850.23 MB
  Writable: 384.33 MB
  Executable: 200.45 MB

[+] Dump complete!
```

## 🔧 Cấu trúc Thư mục

```
~/.freefire_reader/
├── logs/
│   └── reader.log          # Log file
├── scripts/
│   ├── memory_scanner.js   # Frida script quét
│   ├── memory_dumper.js    # Frida script dump
│   └── game_hooker.js      # Frida script hook
└── dumps/
    └── (memory dumps)       # Các file dump
```

## 📊 Script Frida Có sẵn

### 1. Memory Scanner (`memory_scanner.js`)
- Liệt kê các module được load
- Liệt kê threads
- Hook malloc để xem memory allocation
- Theo dõi sự thay đổi bộ nhớ

### 2. Memory Dumper (`memory_dumper.js`)
- Lấy thông tin process ID
- Liệt kê memory ranges
- Tính toán thống kê bộ nhớ
- Tìm các pattern trong memory

### 3. Game Hooker (`game_hooker.js`)
- Hook hàm strlen
- Hook hàm open (file operations)
- Hook các hàm game custom
- Theo dõi game calls

## 🎯 Tạo Script Frida Tùy chỉnh

Thêm script của riêng bạn vào `scripts/` folder:

```javascript
// my_custom_script.js
console.log("[+] My Custom Script");

// Hook function
var target = Module.findExportByName("libil2cpp.so", "custom_function");
if (target) {
    Interceptor.attach(target, {
        onEnter: function(args) {
            console.log("[*] custom_function called");
        }
    });
}
```

Chạy:
```bash
frida -U -f com.dts.freefireth -l scripts/my_custom_script.js
```

## 🐛 Troubleshooting

### Lỗi: "Shizuku not detected"

```bash
# Giải pháp:
1. Kiểm tra Shizuku đã cài và chạy chưa
2. Chạy lệnh kích hoạt:
   adb shell sh /sdcard/Android/data/moe.shizuku.privileged.api/files/start.sh
3. Thử: frida-ps -U
```

### Lỗi: "Free Fire not found"

```bash
# Giải pháp:
1. Mở Free Fire trước khi chạy tool
2. Chạy: frida-ps -U (kiểm tra game có chạy)
3. Nếu package khác, chỉnh sửa FFPKGในscript
```

### Lỗi: "Frida connection timeout"

```bash
# Giải pháp:
1. Kiểm tra USB Debugging
2. Chạy: adb devices
3. Kiểm tra kết nối Shizuku
4. Restart Termux
```

## 🔐 Bảo Mật & Lưu Ý

⚠️ **QUAN TRỌNG:**

- ✅ **Hợp pháp cho:** Nghiên cứu, học tập, phát triển game
- ❌ **KHÔNG hợp pháp cho:** Gian lận trong game online
- ✅ **Chỉ sử dụng:** Trên thiết bị của chính bạn hoặc có sự cho phép
- ❌ **KHÔNG chia sẻ:** Data nhạy cảm hoặc private info
- ⚠️ **Cẩn thận:** Free Fire có anti-cheat, có thể detect tool

## 📝 Ví dụ Code

### Đọc Memory tại địa chỉ cụ thể

```javascript
// Trong Frida shell
Memory.readInt(ptr("0x12345678"));
Memory.readCString(ptr("0x12345678"));
Memory.readByteArray(ptr("0x12345678"), 32);
```

### Ghi Memory

```javascript
// Cẩn thận! Có thể làm crash game
Memory.writeInt(ptr("0x12345678"), 999);
Memory.writeUtf8String(ptr("0x12345678"), "test");
```

### Tìm Pattern

```javascript
var pattern = "78 9c 3d";  // Hex pattern
Memory.scan(ptr("0x00000000"), 0x10000000, pattern, {
    onMatch: function(address, size) {
        console.log("[+] Found at: " + address);
    }
});
```

## 📚 Tài Liệu Thêm

- [Frida Documentation](https://frida.re/)
- [Shizuku GitHub](https://github.com/RikkaApps/Shizuku)
- [Termux Wiki](https://wiki.termux.com/)
- [Android Security](https://developer.android.com/training/articles/security-tips)

## 🤝 Đóng Góp

Chúng tôi hoan nghênh các PR và issues:

```bash
git clone https://github.com/redmi14/termux-freefire-memory-reader.git
git checkout -b feature/your-feature
git commit -am 'Add feature'
git push origin feature/your-feature
```

## 📄 Giấy Phép

MIT License - xem [LICENSE](LICENSE) file

## 📞 Liên Hệ & Hỗ Trợ

- **Issues**: [GitHub Issues](https://github.com/redmi14/termux-freefire-memory-reader/issues)
- **Discussions**: [GitHub Discussions](https://github.com/redmi14/termux-freefire-memory-reader/discussions)

## ⚠️ Disclaimer

**Công cụ này được tạo cho mục đích GIÁO DỤC và NGHIÊN CỨU.**

Người dùng chịu trách nhiệm toàn bộ về cách sử dụng. Tác giả không chịu trách nhiệm cho bất kỳ hậu quả nào từ việc sử dụng công cụ này, bao gồm:

- Ban account Free Fire
- Mất dữ liệu game
- Thiệt hại hệ thống
- Vi phạm điều khoản dịch vụ

**Sử dụng một cách có trách nhiệm!** 🙏

---

**Phiên bản**: 1.0.0  
**Cập nhật**: 2026-09-09  
**Tác giả**: redmi14
