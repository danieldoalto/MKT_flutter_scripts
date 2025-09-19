# 🚀 MikroTik SSH Script Runner v2.0.0

## 📦 Release Package

This package contains the complete MikroTik SSH Script Runner v2.0.0 release with all necessary files and documentation.

### 📁 Package Contents

```
MikroTik_SSH_Script_Runner_v2.0.0/
├── 📄 README.md                     # Complete documentation & usage guide
├── 📄 CHANGELOG.md                  # Detailed version history
├── 📄 RELEASE_NOTES.md              # Release highlights & features
├── 📄 BUILD_INSTRUCTIONS.md         # Build & development guide
├── 📄 config.yml.example            # Configuration template
├── 📁 executable/
│   ├── 🔧 myapp.exe                 # Main application executable
│   ├── 📚 flutter_windows.dll       # Flutter runtime library
│   └── 📁 data/                     # Application data directory
├── 📁 logs/                         # SSH communication logs (created on first run)
└── 📁 examples/
    ├── 📄 sample_config.yml         # Sample router configuration
    └── 📄 sample_scripts.json       # Example cached scripts
```

### 🚀 Quick Start

1. **Extract** the package to your desired location
2. **Copy** `config.yml.example` to `config.yml`
3. **Edit** `config.yml` with your MikroTik router details
4. **Run** `executable/myapp.exe`
5. **Connect** to your router and click "Update Scripts"

### ⚡ Key Features

- **90% Faster Performance**: Optimized script discovery using efficient MikroTik commands
- **Configurable Commands**: Per-router command templates in config.yml
- **Comprehensive Logging**: Detailed SSH communication audit trail
- **Flexible Security**: Support for encrypted and plain text passwords
- **User Access Control**: Script filtering based on user permission levels

### 🔧 System Requirements

- **OS**: Windows 10/11 (64-bit)
- **RAM**: 512MB minimum, 1GB recommended
- **Storage**: 100MB free space
- **Network**: SSH access to MikroTik routers

### 📋 Router Requirements

- **MikroTik RouterOS**: v6.0 or newer
- **SSH Access**: Enabled and configured
- **User Account**: Admin or script execution permissions
- **Scripts**: Following `mkt1_` or `mkt2_` naming convention

### 🔐 Security Notes

- Store sensitive passwords using the encryption feature
- Use environment variable `SCRIPT_RUNNER_KEY` for enhanced security
- Enable SSH logging for audit compliance
- Configure user levels to restrict script access

### 🐛 Troubleshooting

1. **Application won't start**: Ensure all DLL files are in the same directory
2. **Connection failed**: Check router IP, SSH port, and credentials
3. **No scripts found**: Verify script naming follows `mkt<level>_name` convention
4. **Performance issues**: Check SSH logs in the `logs/` directory

### 📞 Support

- **Documentation**: Complete guides included in README.md
- **Configuration**: Examples provided in config.yml.example
- **Logging**: Check `logs/` directory for troubleshooting
- **Issues**: GitHub repository for bug reports

### 📊 Version Information

- **Version**: 2.0.0 Build 1
- **Release Date**: January 18, 2025
- **Code Name**: Optimized Discovery
- **License**: MIT License

---

**Enjoy the power of optimized MikroTik script management!**