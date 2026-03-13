import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../services/config_service.dart';
import '../app_state.dart';
import '../pages/theme_settings_page.dart';

/// Configuration editor panel for editing config.yml
/// Supports loading, editing, saving, backup, and restore operations
class ConfigEditorPanel extends StatefulWidget {
  const ConfigEditorPanel({super.key});
  
  @override
  State<ConfigEditorPanel> createState() => _ConfigEditorPanelState();
}

class _ConfigEditorPanelState extends State<ConfigEditorPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _textController;
  List<String> _validationErrors = [];
  String _statusMessage = '';
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isModified = false;
  bool _showToolbar = true;
  String? _backupPath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _textController = TextEditingController();
    _textController.addListener(_onTextChanged);
    _loadConfig();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isModified = true;
    });
  }

  Future<void> _loadConfig() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading configuration...';
    });

    try {
      final content = await ConfigService.loadConfigContent();
      _textController.text = content;
      await _validateConfig();
      setState(() {
        _isModified = false;
        _statusMessage = 'Configuration loaded successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading configuration: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SETTINGS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            _buildToolbar(),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                child: TextField(
                  controller: _textController,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: Platform.isAndroid ? 11 : 12,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  scrollPadding: EdgeInsets.zero,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter YAML configuration...',
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
            ),
            _buildStatusBar(),
          ],
        ),
      ),
    );
  }

  /// Save configuration to file
  Future<void> _saveConfig() async {
    setState(() {
      _isSaving = true;
      _statusMessage = 'Saving configuration...';
    });

    try {
      // Validate before saving
      await _validateConfig();
      
      if (_validationErrors.isNotEmpty) {
        final proceed = await _showConfirmDialog(
          'Validation Errors',
          'Configuration has validation errors. Save anyway?\n\n${_validationErrors.join('\n')}',
        );
        if (!proceed) {
          setState(() {
            _isSaving = false;
            _statusMessage = 'Save cancelled due to validation errors';
          });
          return;
        }
      }

      // Create backup before saving
      await ConfigService.createAutoBackup();
      
      // Save configuration
      await ConfigService.saveConfig(_textController.text);
      
      setState(() {
        _isModified = false;
        _statusMessage = 'Configuration saved successfully';
      });
      
      _showSuccessDialog('Save Successful', 'Configuration saved successfully.');
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

  /// Import configuration from file
  Future<void> _importConfig() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['yml', 'yaml'],
        allowMultiple: false,
        withData: true,
      );
      
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final content = await File(path).readAsString();
        
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

  /// Build toolbar with action buttons
  Widget _buildToolbar() {
    return Column(
      children: [
        // Action buttons row
        Row(
          children: [
            Text(
              'Actions:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                spacing: 8,
                children: [
                  _buildActionButton(
                    icon: Icons.refresh,
                    label: 'RELOAD',
                    onPressed: _isLoading ? null : _loadConfig,
                  ),
                  _buildActionButton(
                    icon: _isSaving ? null : Icons.save,
                    label: _isSaving ? 'Saving...' : 'SAVE',
                    onPressed: _isLoading || _isSaving ? null : _saveConfig,
                    isLoading: _isSaving,
                    isModified: _isModified,
                  ),
                  _buildActionButton(
                    icon: Icons.file_upload,
                    label: 'IMPORT',
                    onPressed: _importConfig,
                  ),
                  _buildActionButton(
                    icon: Icons.file_download,
                    label: 'EXPORT',
                    onPressed: _exportConfig,
                  ),
                  _buildActionButton(
                    icon: Icons.check_circle,
                    label: 'VALIDATE',
                    onPressed: _showValidationDialog,
                  ),
                  _buildActionButton(
                    icon: Icons.palette,
                    label: 'THEMES',
                    onPressed: _openThemeSettings,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData? icon,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isModified = false,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            )
          : Icon(icon, size: 14),
      label: Text(
        label,
        style: const TextStyle(fontSize: 11),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 28),
        backgroundColor: isModified ? Colors.orange.withOpacity(0.1) : null,
        side: BorderSide(
          color: isModified ? Colors.orange : Colors.grey,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    if (_statusMessage.isEmpty && !_isModified && _validationErrors.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          if (_isModified) ...[
            Icon(Icons.edit, size: 12, color: Colors.orange),
            const SizedBox(width: 4),
            Text(
              'Modified',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (_statusMessage.isNotEmpty)
            Expanded(
              child: Text(
                _statusMessage,
                style: const TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (_validationErrors.isNotEmpty) ...[
            const SizedBox(width: 8),
            Icon(Icons.error, size: 12, color: Colors.red),
            const SizedBox(width: 4),
            Text(
              '${_validationErrors.length} error(s)',
              style: TextStyle(
                color: Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Show validation dialog
  Future<void> _showValidationDialog() async {
    await _validateConfig();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configuration Validation'),
        content: _validationErrors.isEmpty
            ? Text('✅ Configuration is valid!')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('❌ Found ${_validationErrors.length} error(s):'),
                  const SizedBox(height: 8),
                  ...(_validationErrors.take(5).map((error) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $error', style: TextStyle(fontSize: 12)),
                      ))),
                  if (_validationErrors.length > 5)
                    Text('... and ${_validationErrors.length - 5} more errors'),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Open theme settings page
  void _openThemeSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ThemeSettingsPage(),
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}