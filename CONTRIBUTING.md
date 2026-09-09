# Contributing to Free Fire Memory Reader

Thank you for your interest in contributing! Here's how you can help:

## Code of Conduct

- Be respectful and constructive
- No harassment or discrimination
- Help others learn
- Focus on educational and legitimate use cases

## How to Contribute

### 1. Fork the Repository
```bash
git clone https://github.com/yourusername/termux-freefire-memory-reader.git
cd termux-freefire-memory-reader
```

### 2. Create a Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 3. Make Your Changes
- Follow the existing code style
- Add comments for complex logic
- Test thoroughly

### 4. Commit Your Changes
```bash
git commit -am 'Add descriptive message'
```

### 5. Push to Your Fork
```bash
git push origin feature/your-feature-name
```

### 6. Create a Pull Request
- Describe what your changes do
- Reference any related issues
- Explain why the change is needed

## Types of Contributions Welcome

- 🐛 Bug fixes
- ✨ New features
- 📚 Documentation improvements
- 🔧 Performance optimizations
- 🎯 New Frida scripts
- 🧪 Test cases

## Code Style

### Bash
```bash
# Use 4 spaces for indentation
# Add comments for functions
my_function() {
    local var="value"
    echo "$var"
}
```

### JavaScript (Frida)
```javascript
// Use consistent indentation
// Add console.log for debugging
console.log("[+] Starting function");

var result = Module.findExportByName("lib.so", "function");
if (result) {
    console.log("[+] Found function");
}
```

## Testing

Before submitting:
1. Test on actual device with Shizuku
2. Test with different Free Fire versions
3. Check for errors in logs
4. Verify scripts run without crashes

## Documentation

If adding a new feature:
- Update README.md with usage instructions
- Add examples to EXAMPLES.md
- Include comments in code
- Document any new configuration options

## Reporting Issues

When reporting bugs:
1. Include your Android version
2. Include Termux version
3. Include Frida version (`frida --version`)
4. Describe steps to reproduce
5. Include error messages from logs
6. Attach relevant log files

## Questions?

- Check existing issues and discussions
- Ask in GitHub Discussions
- Read the documentation

---

Thanks for helping make this project better! 🙏
