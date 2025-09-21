# ⚙️ Configuration Editor - Implementation Plan

## Immediate Action Steps for Settings Tab & Config Editor

### 🎯 **Objective**

Add a "Settings" tab with a complete configuration editor for config.yml that supports:

- Loading and editing config.yml with syntax highlighting
- Saving changes with validation
- Creating and restoring backups
- Cross-platform file operations (Android + Desktop)

---

## 🚀 **Phase 1: Quick Start Implementation**

### **Step 1: Add Settings Tab to Existing TabBar**

**File to modify**: [`main.dart`](file://d:\Projetos\MKT_flutter_scripts\lib\main.dart)

**Current TabBar** (lines 115-120):

```dart
const TabBar(
  tabs: [
    Tab(icon: Icon(Icons.router), text: 'Router Control'),
    Tab(icon: Icon(Icons.terminal), text: 'SSH Logs'),
  ],
),
```

**Updated TabBar**:

```dart
const TabBar(
  tabs: [
    Tab(icon: Icon(Icons.router), text: 'Router Control'),
    Tab(icon: Icon(Icons.terminal), text: 'SSH Logs'),
    Tab(icon: Icon(Icons.settings), text: 'Settings'),  // NEW
  ],
),
```

**Additional changes needed**:

1. Update `TabController` length from 2 to 3
2. Add third entry to `TabBarView.children`
3. Import the new ConfigEditorPanel widget

### **Step 2: Create ConfigEditorPanel Widget**

**New file**: `lib/widgets/config_editor_panel.dart`

**Basic structure**:

```dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';

class ConfigEditorPanel extends StatefulWidget {
  @override
  _ConfigEditorPanelState createState() => _ConfigEditorPanelState();
}

class _ConfigEditorPanelState extends State<ConfigEditorPanel> {
  final TextEditingController _textController = TextEditingController();
  String _configPath = '';
  bool _isModified = false;
  List<String> _validationErrors = [];

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  // Implementation methods here...
}
```

---

## 📝 **Phase 2: Core Dependencies**

### **Add Required Dependencies to pubspec.yaml**

```yaml
dependencies:
  # ... existing dependencies ...
  
  # Configuration Editor dependencies
  file_picker: ^8.0.0+1           # File picker for backups
  code_text_field: ^1.1.0         # Syntax highlighted editor
  yaml_edit: ^2.2.2               # YAML editing (already present)
  intl: ^0.19.0                   # Date formatting for backups
```

---

## 🛠️ **Phase 3: Implementation Breakdown**

### **3.1: File Operations Service**

**New file**: `lib/services/config_service.dart`

```dart
class ConfigService {
  static Future<String> getConfigPath() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final appDir = await getApplicationDocumentsDirectory();
      return '${appDir.path}/config.yml';
    }
    return 'config.yml';
  }

  static Future<String> loadConfigContent() async { /* ... */ }
  static Future<void> saveConfig(String content) async { /* ... */ }
  static Future<void> createBackup() async { /* ... */ }
  static Future<List<String>> getBackupList() async { /* ... */ }
  static Future<void> restoreFromBackup(String backupPath) async { /* ... */ }
}
```

### **3.2: Configuration Editor Widget Layout**

```dart
class ConfigEditorPanel extends StatefulWidget {
  // Main layout structure:
  // - AppBar with save/backup buttons
  // - Text editor with syntax highlighting
  // - Bottom panel with validation status
  // - Side panel for backup management (desktop)
  // - Bottom sheet for backup management (mobile)
}
```

### **3.3: Mobile vs Desktop Layout**

```dart
Widget build(BuildContext context) {
  return Platform.isAndroid 
    ? _buildMobileLayout()
    : _buildDesktopLayout();
}

Widget _buildMobileLayout() {
  return Column(
    children: [
      _buildMobileToolbar(),
      Expanded(child: _buildEditor()),
      _buildMobileStatusBar(),
    ],
  );
}

Widget _buildDesktopLayout() {
  return Row(
    children: [
      Expanded(flex: 3, child: _buildEditor()),
      Container(width: 300, child: _buildBackupPanel()),
    ],
  );
}
```

---

## 📱 **Phase 4: Platform-Specific Features**

### **4.1: Android File Operations**

```dart
// Android-specific file picker for import/export
Future<void> _importConfigFromFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['yml', 'yaml'],
  );
  
  if (result != null) {
    // Load and display imported config
  }
}

Future<void> _exportBackup() async {
  // Save backup to Downloads folder
  // Show sharing options
}
```

### **4.2: Desktop File Operations**

```dart
// Desktop file dialog integration
Future<void> _saveAsConfig() async {
  String? path = await FilePicker.platform.saveFile(
    dialogTitle: 'Save Configuration As',
    fileName: 'config.yml',
    type: FileType.custom,
    allowedExtensions: ['yml'],
  );
  
  if (path != null) {
    await File(path).writeAsString(_textController.text);
  }
}
```

---

## 🔍 **Phase 5: Validation and Error Handling**

### **5.1: Real-time YAML Validation**

```dart
void _validateYaml(String content) {
  setState(() {
    _validationErrors.clear();
    
    try {
      final yaml = loadYaml(content);
      _validateRouterConfig(yaml);
      _validateRequiredFields(yaml);
      _validateDataTypes(yaml);
    } catch (e) {
      _validationErrors.add('YAML Syntax Error: ${e.toString()}');
    }
  });
}

void _validateRouterConfig(dynamic yaml) {
  // Validate router configuration structure
  // Check required fields: host, port, username, password
  // Validate IP addresses and port ranges
  // Verify encryption settings
}
```

### **5.2: Error Display UI**

```dart
Widget _buildValidationPanel() {
  if (_validationErrors.isEmpty) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.green.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('Configuration is valid', style: TextStyle(color: Colors.green)),
        ],
      ),
    );
  }
  
  return Container(
    padding: EdgeInsets.all(8),
    color: Colors.red.withOpacity(0.1),
    child: Column(
      children: _validationErrors.map((error) => 
        Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Expanded(child: Text(error, style: TextStyle(color: Colors.red))),
          ],
        )
      ).toList(),
    ),
  );
}
```

---

## ⚡ **Quick Implementation Timeline**

### **Day 1: Basic Structure**

- ✅ Add Settings tab to TabBar
- ✅ Create ConfigEditorPanel with basic layout
- ✅ Implement file loading functionality

### **Day 2: Editor Implementation**

- ✅ Add syntax highlighting text editor
- ✅ Implement save functionality
- ✅ Add basic validation

### **Day 3: Backup System**

- ✅ Create backup creation functionality
- ✅ Implement backup list and management
- ✅ Add restore from backup feature

### **Day 4: Mobile Optimization**

- ✅ Android file picker integration
- ✅ Mobile-responsive layout
- ✅ Touch-optimized controls

### **Day 5: Testing & Polish**

- ✅ Cross-platform testing
- ✅ Error handling validation
- ✅ UI polish and integration

---

## 🎯 **Immediate Next Steps**

1. **Start with TabBar modification** in [`main.dart`](file://d:\Projetos\MKT_flutter_scripts\lib\main.dart)
2. **Create basic ConfigEditorPanel** widget structure
3. **Add required dependencies** to [`pubspec.yaml`](file://d:\Projetos\MKT_flutter_scripts\pubspec.yaml)
4. **Implement file loading** from config.yml
5. **Test basic functionality** on both platforms

This implementation plan provides a clear roadmap for creating a professional configuration editor that seamlessly integrates with the existing MikroTik SSH Script Runner while providing powerful config management capabilities on both Android and desktop platforms!
