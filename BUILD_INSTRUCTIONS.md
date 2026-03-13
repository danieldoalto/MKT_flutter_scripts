# MikroTik SSH Script Runner - Build Instructions

## 🏗️ Building for v2.1.0

### Prerequisites
- **Flutter SDK**: 3.41.4 (Stable)
- **Environment**: Windows 10/11 or Android Studio (for Mobile)
- **Key**: `SCRIPT_RUNNER_KEY` environment variable set for password testing.

### Build Commands

#### 1. Windows Desktop Release
```bash
flutter clean
flutter pub get
flutter build windows --release --build-name=2.1.0 --build-number=1
```
*Output*: `build/windows/x64/runner/Release/myapp.exe`

#### 2. Android Mobile Release
```bash
flutter clean
flutter pub get
flutter build apk --release --build-name=2.1.0 --build-number=1
```
*Output*: `build/app/outputs/flutter-apk/app-release.apk`

### 📦 Release Verification

| Check | Action |
|:---|:---|
| **Version** | Verify `AppVersion` in `lib/version.dart` is `2.1.0`. |
| **Adaptive UI** | Run on both platforms to verify `LayoutManager` behavior. |
| **Config Editor** | Verify YAML saving and backup creation in Settings. |
| **SSH Discovery** | Verify optimized script discovery speed (< 5s). |
| **Android Lifecycle** | Verify connection stays alive when app is minimized. |

### 🚀 Distribution Steps

1. **Tag**: Create Git tag `v2.1.0`.
2. **Package**: Bundle the `.exe` (with data folder) and the `.apk`.
3. **Docs**: Ensure `CHANGELOG.md` and `RELEASE_NOTES.md` are updated.
4. **Binary**: Upload to GitHub Releases or distribution server.

**Build Status**: ✅ **v2.1.0 Ready for Deployment**