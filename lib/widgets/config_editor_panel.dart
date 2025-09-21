import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/config_service.dart';

/// Configuration editor panel for editing config.yml
/// Supports loading, editing, saving, backup, and restore operations
class ConfigEditorPanel extends StatefulWidget {
  const ConfigEditorPanel({Key? key}) : super(key: key);
  
  @override
  _ConfigEditorPanelState createState() => _ConfigEditorPanelState();
}

class _ConfigEditorPanelState extends State<ConfigEditorPanel> with SingleTickerProviderStateMixin {
  late TextEditingController _textController;
  late TabController _tabController;
  
  bool _isLoading = false;
  bool _isModified = false;
  bool _isSaving = false;
  List<String> _validationErrors = [];
  List<BackupInfo> _backups = [];
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    
    // Initialize text editor
    _textController = TextEditingController(text: '');
    
    // Initialize tab controller for editor sections
    _tabController = TabController(length: 3, vsync: this);
    
    // Listen for text changes to track modifications
    _textController.addListener(_onTextChanged);
    
    // Load configuration content
    _loadConfig();
    _loadBackups();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// Handle text changes to track modifications
  void _onTextChanged() {
    if (!_isModified) {
      setState(() {
        _isModified = true;
      });
    }
    
    // Validate on change with debouncing
    _validateConfigDebounced();
  }

  /// Load configuration content from file
  Future<void> _loadConfig() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading configuration...';
    });
    
    try {
      final content = await ConfigService.loadConfigContent();
      _textController.text = content;
      
      setState(() {
        _isModified = false;
        _statusMessage = 'Configuration loaded successfully';
      });
      
      // Validate loaded content
      await _validateConfig();
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading configuration: $e';
        _validationErrors = [e.toString()];
      });
      
      _showErrorDialog('Load Error', 'Failed to load configuration: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Save configuration to file
  Future<void> _saveConfig() async {
    if (!_isModified) {
      _showInfoDialog('No Changes', 'No changes to save.');
      return;
    }
    
    // Validate before saving
    await _validateConfig();
    if (_validationErrors.isNotEmpty) {
      final save = await _showConfirmDialog(
        'Validation Errors',
        'Configuration has validation errors. Save anyway?\n\n${_validationErrors.join('\n')}',
      );
      if (!save) return;
    }
    
    setState(() {
      _isSaving = true;
      _statusMessage = 'Saving configuration...';
    });
    
    try {
      await ConfigService.saveConfig(_textController.text);
      
      setState(() {
        _isModified = false;
        _statusMessage = 'Configuration saved successfully';
      });
      
      // Reload backups after save
      await _loadBackups();
      
      _showSuccessDialog('Save Successful', 'Configuration has been saved successfully.');
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Error saving configuration: $e';
      });
      
      _showErrorDialog('Save Error', 'Failed to save configuration: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// Validate configuration content
  Future<void> _validateConfig() async {
    try {
      final errors = await ConfigService.validateConfig(_textController.text);
      setState(() {
        _validationErrors = errors;
      });
    } catch (e) {
      setState(() {
        _validationErrors = ['Validation error: $e'];
      });
    }
  }

  /// Debounced validation to avoid excessive validation calls
  void _validateConfigDebounced() {
    // Simple debouncing - validate after short delay
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        _validateConfig();
      }
    });
  }

  /// Load list of available backups
  Future<void> _loadBackups() async {
    try {
      final backups = await ConfigService.getBackupList();
      setState(() {
        _backups = backups;
      });
    } catch (e) {
      // Silent error for backup loading
      setState(() {
        _backups = [];
      });
    }
  }

  /// Create manual backup
  Future<void> _createBackup() async {
    final name = await _showInputDialog(
      'Create Backup',
      'Enter backup name:',
      'manual_backup',
    );
    
    if (name == null || name.isEmpty) return;
    
    try {
      await ConfigService.createManualBackup(name);
      await _loadBackups();
      
      _showSuccessDialog('Backup Created', 'Backup \"$name\" created successfully.');
    } catch (e) {
      _showErrorDialog('Backup Error', 'Failed to create backup: $e');
    }
  }

  /// Restore configuration from backup
  Future<void> _restoreFromBackup(BackupInfo backup) async {
    final confirm = await _showConfirmDialog(
      'Restore Backup',
      'This will replace the current configuration with the backup "${backup.fileName}". Continue?',
    );
    
    if (!confirm) return;
    
    try {
      final content = await File(backup.filePath).readAsString();
      setState(() {
        _textController.text = content;
        _isModified = true;
      });
      
      _showSuccessDialog('Restore Successful', 'Configuration restored from backup.');
      
    } catch (e) {
      _showErrorDialog('Restore Error', 'Failed to restore backup: $e');
    }
  }

  /// Delete backup
  Future<void> _deleteBackup(BackupInfo backup) async {
    final confirm = await _showConfirmDialog(
      'Delete Backup',
      'Delete backup \"${backup.fileName}\"?\nThis action cannot be undone.',
    );
    
    if (!confirm) return;
    
    try {
      await ConfigService.deleteBackup(backup.filePath);
      await _loadBackups();
      
      _showSuccessDialog('Backup Deleted', 'Backup deleted successfully.');
    } catch (e) {
      _showErrorDialog('Delete Error', 'Failed to delete backup: $e');
    }
  }

  /// Import configuration from file
  Future<void> _importConfig() async {
    if (_isModified) {
      final discard = await _showConfirmDialog(
        'Unsaved Changes',
        'You have unsaved changes. Importing will discard them. Continue?',
      );
      if (!discard) return;
    }
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['yml', 'yaml'],
        withData: true,
      );
      
      if (result != null && result.files.single.bytes != null) {
        final content = String.fromCharCodes(result.files.single.bytes!);
        
        // Validate imported content
        final errors = await ConfigService.validateConfig(content);
        if (errors.isNotEmpty) {
          final proceed = await _showConfirmDialog(
            'Import Validation Errors',
            'Imported configuration has validation errors. Import anyway?\n\n${errors.join('\n')}',
          );
          if (!proceed) return;
        }
        
        _textController.text = content;
        await _validateConfig();
        
        _showSuccessDialog('Import Successful', 'Configuration imported successfully.');
      }
    } catch (e) {
      _showErrorDialog('Import Error', 'Failed to import configuration: $e');
    }
  }

  /// Export configuration to file
  Future<void> _exportConfig() async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Configuration',
        fileName: 'config.yml',
        type: FileType.custom,
        allowedExtensions: ['yml', 'yaml'],
      );
      
      if (result != null) {
        final path = result;
        await File(path).writeAsString(_textController.text);
        _showSuccessDialog('Export Successful', 'Configuration exported to $path');
      }
    } catch (e) {
      _showErrorDialog('Export Error', 'Failed to export configuration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildToolbar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEditorTab(),
                _buildBackupTab(),
                _buildValidationTab(),
              ],
            ),
          ),
          _buildStatusBar(),
        ],
      ),
    );
  }

  /// Build toolbar with tabs and action buttons
  Widget _buildToolbar() {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading || _isSaving ? null : _saveConfig,
                  icon: _isSaving 
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isModified ? Colors.orange : null,
                  ),
                ),
                SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _loadConfig,
                  icon: Icon(Icons.refresh),
                  label: Text('Reload'),
                ),
                SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _createBackup,
                  icon: Icon(Icons.backup),
                  label: Text('Backup'),
                ),
                Spacer(),
                if (Platform.isAndroid || Platform.isIOS) ...[  
                  IconButton(
                    onPressed: _importConfig,
                    icon: Icon(Icons.file_upload),
                    tooltip: 'Import Config',
                  ),
                  IconButton(
                    onPressed: _exportConfig,
                    icon: Icon(Icons.file_download),
                    tooltip: 'Export Config',
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    onPressed: _importConfig,
                    icon: Icon(Icons.file_upload),
                    label: Text('Import'),
                  ),
                  SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _exportConfig,
                    icon: Icon(Icons.file_download),
                    label: Text('Export'),
                  ),
                ],
              ],
            ),
          ),
          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.edit), text: 'Editor'),
              Tab(icon: Icon(Icons.backup), text: 'Backups'),
              Tab(icon: Icon(Icons.check_circle), text: 'Validation'),
            ],
          ),
        ],
      ),
    );
  }

  /// Build editor tab
  Widget _buildEditorTab() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(_statusMessage),
              ],
            ),
          )
        : Expanded(
            child: TextField(
              controller: _textController,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: Platform.isAndroid ? 12 : 14,
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter YAML configuration...',
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
    );
  }

  /// Build backup management tab
  Widget _buildBackupTab() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuration Backups',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          Expanded(
            child: _backups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.backup, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No backups available',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Backups are created automatically when saving\nor you can create manual backups.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _backups.length,
                  itemBuilder: (context, index) {
                    final backup = _backups[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.description),
                        title: Text(backup.fileName),
                        subtitle: Text(
                          '${backup.formattedDate} • ${backup.formattedSize}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _restoreFromBackup(backup),
                              icon: Icon(Icons.restore),
                              tooltip: 'Restore',
                            ),
                            IconButton(
                              onPressed: () => _deleteBackup(backup),
                              icon: Icon(Icons.delete),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  /// Build validation tab
  Widget _buildValidationTab() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuration Validation',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          if (_validationErrors.isEmpty)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Configuration is valid',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Configuration has errors:',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ..._validationErrors.map((error) => Padding(
                    padding: EdgeInsets.only(left: 32, bottom: 4),
                    child: Text(
                      '• $error',
                      style: TextStyle(color: Colors.red),
                    ),
                  )),
                ],
              ),
            ),
          SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuration Requirements',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  _buildRequirementCard(
                    'Required Sections',
                    'Configuration must contain a \"routers\" section with at least one router.',
                    Icons.list,
                  ),
                  _buildRequirementCard(
                    'Router Fields',
                    'Each router must have: name, host, port, username, password.',
                    Icons.router,
                  ),
                  _buildRequirementCard(
                    'Port Range',
                    'Port numbers must be between 1 and 65535.',
                    Icons.network_check,
                  ),
                  _buildRequirementCard(
                    'User Level',
                    'user_level must be 1 or 2 (1 = mkt1_+mkt2_ scripts, 2 = mkt2_ only).',
                    Icons.security,
                  ),
                  _buildRequirementCard(
                    'Password Encryption',
                    'password_encrypted must be true or false. Use encryption for production.',
                    Icons.lock,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build requirement info card
  Widget _buildRequirementCard(String title, String description, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(description),
        isThreeLine: true,
      ),
    );
  }

  /// Build status bar
  Widget _buildStatusBar() {
    return Container(
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          if (_isModified)
            Icon(Icons.edit, size: 16, color: Colors.orange),
          if (_isModified)
            SizedBox(width: 4),
          Text(
            _isModified ? 'Modified' : 'Saved',
            style: TextStyle(
              color: _isModified ? Colors.orange : Colors.green,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_validationErrors.isNotEmpty)
            Row(
              children: [
                Icon(Icons.error, size: 16, color: Colors.red),
                SizedBox(width: 4),
                Text(
                  '${_validationErrors.length} error(s)',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Dialog helper methods
  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<String?> _showInputDialog(String title, String hint, String defaultValue) async {
    final controller = TextEditingController(text: defaultValue);
    
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}