import 'dart:convert';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';
import 'package:intl/intl.dart';

/// Information about a backup file
class BackupInfo {
  final String fileName;
  final String filePath;
  final DateTime createdAt;
  final int size;

  BackupInfo({
    required this.fileName,
    required this.filePath,
    required this.createdAt,
    required this.size,
  });

  String get formattedDate => DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt);
  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Service for managing configuration file operations
/// Handles loading, saving, backup, and restore of config.yml
class ConfigService {
  static String? _configPath;
  static String? _backupDirectoryPath;

  /// Get the appropriate config.yml path for the current platform
  static Future<String> getConfigPath() async {
    if (_configPath != null) return _configPath!;
    
    if (Platform.isAndroid || Platform.isIOS) {
      // Use app documents directory on mobile platforms
      final appDir = await getApplicationDocumentsDirectory();
      _configPath = '${appDir.path}/config.yml';
    } else {
      // Use local directory on desktop platforms
      _configPath = 'config.yml';
    }
    
    return _configPath!;
  }

  /// Get the backup directory path
  static Future<String> getBackupDirectoryPath() async {
    if (_backupDirectoryPath != null) return _backupDirectoryPath!;
    
    if (Platform.isAndroid || Platform.isIOS) {
      final appDir = await getApplicationDocumentsDirectory();
      _backupDirectoryPath = '${appDir.path}/config_backups';
    } else {
      _backupDirectoryPath = 'config_backups';
    }
    
    // Ensure backup directory exists
    final backupDir = Directory(_backupDirectoryPath!);
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    return _backupDirectoryPath!;
  }

  /// Load configuration file content
  static Future<String> loadConfigContent() async {
    try {
      final configPath = await getConfigPath();
      final file = File(configPath);
      
      if (!await file.exists()) {
        // Create default config if it doesn't exist
        final defaultConfig = await _createDefaultConfig();
        await file.writeAsString(defaultConfig);
        return defaultConfig;
      }
      
      return await file.readAsString();
    } catch (e) {
      throw Exception('Failed to load configuration: $e');
    }
  }

  /// Save configuration content to file
  static Future<void> saveConfig(String content) async {
    try {
      // Validate YAML syntax before saving
      loadYaml(content);
      
      final configPath = await getConfigPath();
      final file = File(configPath);
      
      // Create backup before saving if file exists
      if (await file.exists()) {
        await createAutoBackup();
      }
      
      // Write to temporary file first (atomic operation)
      final tempFile = File('${configPath}.tmp');
      await tempFile.writeAsString(content);
      
      // Replace original file with temporary file
      await tempFile.rename(configPath);
      
    } catch (e) {
      throw Exception('Failed to save configuration: $e');
    }
  }

  /// Create automatic backup with timestamp
  static Future<String> createAutoBackup() async {
    try {
      final configPath = await getConfigPath();
      final configFile = File(configPath);
      
      if (!await configFile.exists()) {
        throw Exception('Configuration file does not exist');
      }
      
      final backupDir = await getBackupDirectoryPath();
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final backupPath = '$backupDir/config_backup_$timestamp.yml';
      
      await configFile.copy(backupPath);
      return backupPath;
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  /// Create manual backup with custom name
  static Future<String> createManualBackup(String name) async {
    try {
      final configPath = await getConfigPath();
      final configFile = File(configPath);
      
      if (!await configFile.exists()) {
        throw Exception('Configuration file does not exist');
      }
      
      final backupDir = await getBackupDirectoryPath();
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final backupPath = '$backupDir/${safeName}_$timestamp.yml';
      
      await configFile.copy(backupPath);
      return backupPath;
    } catch (e) {
      throw Exception('Failed to create manual backup: $e');
    }
  }

  /// Get list of available backups
  static Future<List<BackupInfo>> getBackupList() async {
    try {
      final backupDir = await getBackupDirectoryPath();
      final directory = Directory(backupDir);
      
      if (!await directory.exists()) {
        return [];
      }
      
      final backups = <BackupInfo>[];
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.endsWith('.yml')) {
          final fileName = entity.path.split('/').last.split('\\').last;
          final stat = await entity.stat();
          
          backups.add(BackupInfo(
            fileName: fileName,
            filePath: entity.path,
            createdAt: stat.modified,
            size: stat.size,
          ));
        }
      }
      
      // Sort by creation date (newest first)
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return backups;
    } catch (e) {
      throw Exception('Failed to get backup list: $e');
    }
  }

  /// Restore configuration from backup
  static Future<void> restoreFromBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      
      if (!await backupFile.exists()) {
        throw Exception('Backup file does not exist');
      }
      
      // Validate backup content
      final backupContent = await backupFile.readAsString();
      loadYaml(backupContent); // Throws if invalid YAML
      
      // Create backup of current config before restore
      final configPath = await getConfigPath();
      final configFile = File(configPath);
      if (await configFile.exists()) {
        await createAutoBackup();
      }
      
      // Restore from backup
      await backupFile.copy(configPath);
      
    } catch (e) {
      throw Exception('Failed to restore from backup: $e');
    }
  }

  /// Delete backup file
  static Future<void> deleteBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }

  /// Validate YAML configuration structure
  static Future<List<String>> validateConfig(String content) async {
    final errors = <String>[];
    
    try {
      final yaml = loadYaml(content);
      
      if (yaml is! Map) {
        errors.add('Configuration must be a YAML map/object');
        return errors;
      }
      
      // Validate routers section
      if (!yaml.containsKey('routers')) {
        errors.add('Missing required "routers" section');
      } else {
        final routers = yaml['routers'];
        if (routers is! YamlList) {
          errors.add('"routers" must be a list');
        } else {
          _validateRouters(routers, errors);
        }
      }
      
    } catch (e) {
      errors.add('YAML Syntax Error: ${e.toString()}');
    }
    
    return errors;
  }

  /// Validate routers configuration
  static void _validateRouters(YamlList routers, List<String> errors) {
    for (int i = 0; i < routers.length; i++) {
      final router = routers[i];
      final prefix = 'Router ${i + 1}';
      
      if (router is! Map) {
        errors.add('$prefix: Must be a map/object');
        continue;
      }
      
      // Required fields
      final requiredFields = ['name', 'host', 'port', 'username', 'password'];
      for (final field in requiredFields) {
        if (!router.containsKey(field)) {
          errors.add('$prefix: Missing required field "$field"');
        }
      }
      
      // Validate specific fields
      if (router.containsKey('port')) {
        final port = router['port'];
        if (port is int) {
          if (port < 1 || port > 65535) {
            errors.add('$prefix: Port must be between 1 and 65535');
          }
        } else {
          errors.add('$prefix: Port must be a number');
        }
      }
      
      if (router.containsKey('user_level')) {
        final userLevel = router['user_level'];
        if (userLevel is int) {
          if (userLevel < 1 || userLevel > 2) {
            errors.add('$prefix: user_level must be 1 or 2');
          }
        } else {
          errors.add('$prefix: user_level must be a number');
        }
      }
      
      if (router.containsKey('password_encrypted')) {
        final encrypted = router['password_encrypted'];
        if (encrypted is! bool) {
          errors.add('$prefix: password_encrypted must be true or false');
        }
      }
    }
  }

  /// Create default configuration content
  static Future<String> _createDefaultConfig() async {
    return '''
# MikroTik SSH Script Runner Configuration
# Copy this file to 'config.yml' and customize it for your routers

# Global application settings
app_settings:
  log_level: "INFO"
  cache_enabled: true
  cache_timeout_minutes: 30

# Default commands for all routers (can be overridden per router)
default_commands:
  # Command to get list of script names (optimized for performance)
  list_scripts: ":foreach s in=[/system script find] do={ :put [/system script get \$s name] }"
  # Command to get script comment/description
  get_comment: ":put [system/script/ get [find name=\"{script_name}\"] comment ]"

# Router configurations
routers:
  - name: "Example Router"
    host: "192.168.1.1"
    port: 22
    username: "admin"
    password: "your-password-here"
    password_encrypted: false  # Set to true for encrypted passwords
    user_level: 1  # 1 = access to mkt1_ and mkt2_ scripts, 2 = only mkt2_ scripts

# Add more routers as needed:
# - name: "Another Router"
#   host: "10.0.1.1"
#   port: 2222
#   username: "admin"
#   password: "encrypted-password"
#   password_encrypted: true
#   user_level: 2
''';
  }
}