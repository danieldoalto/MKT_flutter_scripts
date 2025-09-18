# 🔐 MikroTik SSH Runner - Authentication Fix Guide

## ❌ Problem Identified: Missing SCRIPT_RUNNER_KEY

Your `SSHAuthFailError` is caused by the missing `SCRIPT_RUNNER_KEY` environment variable. The application cannot decrypt passwords without this key.

## 🔧 Solution: Set Environment Variable

### **For Current PowerShell Session:**
```powershell
$env:SCRIPT_RUNNER_KEY="MKT_Runner_SecretKey_2025_32chars"
```

### **For Permanent Setting (Recommended):**
```powershell
# Set permanently for your user
[System.Environment]::SetEnvironmentVariable("SCRIPT_RUNNER_KEY", "MKT_Runner_SecretKey_2025_32chars", "User")

# Or set for entire system (requires admin)
[System.Environment]::SetEnvironmentVariable("SCRIPT_RUNNER_KEY", "MKT_Runner_SecretKey_2025_32chars", "Machine")
```

### **Verify It's Set:**
```powershell
echo $env:SCRIPT_RUNNER_KEY
```

## 🔄 Alternative: Re-encrypt Passwords with New Key

If you don't know the original encryption key, you can:

1. **Set a new key:**
   ```powershell
   $env:SCRIPT_RUNNER_KEY="MKT_Runner_SecretKey_2025_32chars"
   ```

2. **Update config.yml with plain text passwords temporarily:**
   ```yaml
   routers:
     - name: "Casa Daniel"
       host: "192.168.10.1"
       port: 22
       username: "admin"
       password: "your-actual-password"  # Plain text temporarily
       user_level: 1
   ```

3. **Re-encrypt using the tool:**
   ```powershell
   dart run tool/encrypt_passwords.dart
   ```

## 🚀 Quick Fix Commands

Run these commands in order:

```powershell
# 1. Set the environment variable
$env:SCRIPT_RUNNER_KEY="MKT_Runner_SecretKey_2025_32chars"

# 2. Test decryption
dart run debug_auth.dart

# 3. If successful, run the app
flutter run -d windows
```

## 🔍 Troubleshooting

If you still get authentication errors after setting the key:

1. **Check MikroTik SSH settings:**
   - SSH service enabled: `/ip service enable ssh`
   - Correct port (default 22)
   - User has proper permissions

2. **Test manual SSH connection:**
   ```cmd
   ssh admin@192.168.10.1
   ```

3. **Check firewall/network:**
   - Router accessible from your network
   - No firewall blocking port 22

---
*Run the commands above and try connecting again!*