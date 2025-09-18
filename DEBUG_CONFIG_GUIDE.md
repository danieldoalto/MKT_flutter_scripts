# 🔧 Debug Configuration Guide

## ✅ **New Configuration System Implemented**

I've successfully implemented a flexible configuration system that supports both **plain text** (debug mode) and **encrypted** (production mode) passwords.

## 📋 **How It Works**

### **Configuration File Structure** ([config.yml](file://d:\Projetos\MKT_flutter_scripts\config.yml))

```yaml
# MikroTik SSH Script Runner Configuration
# Set password_encrypted to false for plain text passwords (debug mode)
# Set password_encrypted to true for encrypted passwords (production mode)
password_encrypted: false
encryption_key: "MKT_Runner_SecretKey_2025_32chars"  # Used when password_encrypted is true

routers:
  - name: "Casa Daniel"
    host: "192.168.10.1"
    port: 22
    username: "admin"
    password: "pint@do100"  # Plain text for debugging
    user_level: 1
  # ... more routers
```

### **Configuration Modes**

| Mode | `password_encrypted` | Password Format | Encryption Key Required |
|------|---------------------|-----------------|------------------------|
| **Debug** | `false` | Plain text | ❌ No |
| **Production** | `true` | Encrypted (Base64) | ✅ Yes |

## 🚀 **Usage Instructions**

### **Debug Mode (Current Setup)**

- ✅ **Ready to use immediately**
- ✅ **No environment variables needed**
- ✅ **No encryption key required**
- ✅ **Passwords in plain text**

```powershell
# Just run the application
flutter run -d windows
```

### **Production Mode (When Ready)**

1. **Change flag in config.yml**:

   ```yaml
   password_encrypted: true
   ```

2. **Encrypt passwords**:

   ```powershell
   dart run tool/encrypt_passwords.dart
   ```

3. **Run application**:

   ```powershell
   flutter run -d windows
   ```

## 🔍 **Testing & Verification**

### **Test Configuration**

```powershell
dart run debug_auth.dart
```

**Expected Output:**

```
🔍 Testing New Configuration System...

📋 Configuration:
   - password_encrypted: false
   - Using plain text passwords (debug mode)

🔗 Testing router configuration:
✅ Casa Daniel: admin@192.168.10.1:22 (password: 10 chars)
✅ Router TF: admin@10.1.1.1:22 (password: 10 chars)
✅ Router borda: admin@192.168.0.254:22 (password: 10 chars)

🎉 Configuration loaded successfully!
💡 You can now run: flutter run -d windows
```

## 🛠️ **Implementation Details**

### **Key Changes Made:**

1. **Modified [`config.yml`](file://d:\Projetos\MKT_flutter_scripts\config.yml)**:
   - Added `password_encrypted: false` flag
   - Added `encryption_key` for future use
   - Set passwords to plain text

2. **Updated [`RouterConfig.fromYaml()`](file://d:\Projetos\MKT_flutter_scripts\lib\models\router_config.dart)**:
   - Now accepts configuration context
   - Handles both encrypted and plain text passwords
   - Optional CryptoService parameter

3. **Modified [`AppState._loadConfig()`](file://d:\Projetos\MKT_flutter_scripts\lib\app_state.dart)**:
   - Reads encryption flag from config
   - Uses encryption key from config file (fallback to environment)
   - Provides detailed logging

4. **Enhanced [`encrypt_passwords.dart`](file://d:\Projetos\MKT_flutter_scripts\tool\encrypt_passwords.dart)**:
   - Automatically sets `password_encrypted: true` after encryption
   - Uses key from config file or environment

## 🔄 **Migration Path**

### **From Debug to Production:**

1. Verify all passwords work in debug mode
2. Run encryption tool: `dart run tool/encrypt_passwords.dart`
3. Config automatically updated to `password_encrypted: true`
4. Test encrypted mode: `dart run debug_auth.dart`

### **From Production to Debug:**

1. Manually set `password_encrypted: false` in config.yml
2. Replace encrypted passwords with plain text
3. No environment variables needed

## 🎯 **Current Status**

- ✅ **Debug mode active** (`password_encrypted: false`)
- ✅ **Plain text passwords working**
- ✅ **No SSHAuthFailError** (environment variable not required)
- ✅ **Ready for testing SSH connections**

**You can now run the application without any environment variable setup!**

```powershell
flutter run -d windows
```

---
*This configuration system gives you full control over password handling for both development and production environments.*
