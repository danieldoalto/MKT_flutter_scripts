# Changelog

All notable changes to the MikroTik SSH Script Runner project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-03-13

### 🚀 **Major Feature Update - Android Support & Config Editor**

This release brings the highly requested Android support with a touch-optimized UI and a built-in Configuration Editor for seamless management.

### ✨ **Added**
- **Android Compatibility**: Fully functional Android version for mobile network management.
- **Adaptive Layout System**: Automatic switching between Desktop (tabs) and Mobile (bottom nav) interfaces.
- **Configuration Editor**: Integrated YAML editor with syntax highlighting and validation.
- **Backup & Restore**: Automated backup system for configurations with point-in-time restoration.
- **Touch-Optimized UI**: Enhanced mobile widgets with larger touch targets and responsive spacing.
- **Flutter SDK Upgrade**: Migrated to Flutter **3.41.4** for improved performance and security.

### 🔧 **Fixed**
- **Layout Consistency**: Unified layout logic through the new LayoutManager.
- **Path Handling**: Cross-platform path resolution for cache and logs (Android vs Desktop).
- **Dependency Conflicts**: Updated all packages to latest stable versions compatible with Flutter 3.41.

### 🏗️ **Technical Improvements**
- **Architecture**: Implemented `AdaptiveThemeProvider` for platform-specific design tokens.
- **Lifecycle Management**: Added Android-specific connection handling to prevent drops during app suspension.
- **Performance**: Improved YAML parsing speed and memory footprint in the editor.

---

## [2.0.0] - 2025-01-18

### 🚀 **Major Release - Complete Rewrite & Optimization**

This release represents a complete overhaul of the MikroTik SSH Script Runner with significant performance improvements, enhanced security, and comprehensive logging capabilities.

### ✨ **Added**
- **Optimized Script Discovery**: 90% faster script discovery using efficient MikroTik commands
  - New command: `:foreach s in=[/system script find] do={ :put [/system script get $s name] }`
  - Selective comment retrieval: `:put [system/script/ get [find name="{script_name}"] comment ]`
- **Configurable Command Templates**: Per-router command customization in config.yml
- **Comprehensive SSH Logging**: Detailed communication logs in `/logs` folder with timestamps
- **Flexible Password Handling**: Support for both encrypted and plain text passwords
- **Enhanced Error Handling**: Proper error dialogs instead of silent failures
- **JSON Caching System**: Local cache for discovered scripts per router
- **User Level Access Control**: Advanced filtering based on `mkt<LEVEL>_` naming convention
- **Update Scripts Button**: New UI component for refreshing script lists
- **Script Descriptions**: Automatic extraction from MikroTik script comment field

### 🔧 **Fixed**
- **Critical Syntax Errors**: Fixed unterminated string literals in app_state.dart
- **Authentication Issues**: Resolved SSHAuthFailError with flexible key management
- **RouterConfig Conflicts**: Fixed naming conflicts using import aliasing
- **Environment Variables**: Added fallback to config.yml for encryption keys
- **Import Dependencies**: Cleaned up duplicate and conflicting imports

### 🎨 **Changed**
- **Script Discovery Workflow**: Complete rewrite from `/system script print detail` to optimized commands
- **Configuration Structure**: Enhanced config.yml with command templates and encryption flags
- **UI/UX Improvements**: Better script execution panel with descriptions and status indicators
- **State Management**: Improved Provider-based state handling with proper error propagation
- **Security Model**: Enhanced with configurable encryption and environment variable fallbacks

### 🏗️ **Technical Improvements**
- **Performance**: Reduced script discovery time from ~30s to ~3s for large router configurations
- **Architecture**: Implemented service-oriented architecture with dedicated logging and crypto services
- **Code Quality**: Added comprehensive error handling and validation throughout the application
- **Testing**: Created test utilities for SSH logging and optimized discovery workflows
- **Documentation**: Complete README overhaul with detailed setup and troubleshooting guides

### 📋 **Dependencies Updated**
- Flutter SDK: ^3.9.0
- dartssh2: ^2.13.0 (Enhanced SSH connectivity)
- encrypt: ^5.0.3 (AES-256 encryption)
- yaml: ^3.1.3 (Configuration parsing)
- provider: ^6.1.5+1 (State management)

### 🔐 **Security Enhancements**
- **Flexible Encryption**: Optional password encryption with `password_encrypted` flag
- **Environment Security**: Support for `SCRIPT_RUNNER_KEY` environment variable
- **Audit Trail**: Complete SSH communication logging for security compliance
- **Access Control**: Granular user level permissions (mkt1_, mkt2_)

### 📊 **Project Status**
- **Completion**: 100% of planned features implemented and tested
- **Performance**: 90% improvement in script discovery speed
- **Reliability**: Enhanced error handling and recovery mechanisms
- **Maintainability**: Modular architecture with clear separation of concerns

---

## [1.0.0] - 2024-12-XX

### Initial Release
- Basic SSH connectivity to MikroTik routers
- Simple script execution functionality
- YAML configuration support
- Basic UI with Flutter desktop

---

**Note**: Version 2.0.0 represents a major milestone with complete optimization of the script discovery system, comprehensive logging, and enhanced security features. This release is production-ready with significant performance improvements over the initial version.