import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SSHLogPanel extends StatefulWidget {
  const SSHLogPanel({super.key});

  @override
  State<SSHLogPanel> createState() => _SSHLogPanelState();
}

class _SSHLogPanelState extends State<SSHLogPanel> {
  final ScrollController _scrollController = ScrollController();
  List<FileSystemEntity> _logFiles = [];
  File? _selectedLogFile;
  String _logContent = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLogFiles();
  }

  /// Get the appropriate logs directory path for the current platform
  Future<String> _getLogsDirectoryPath() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Use app documents directory on mobile platforms
      final appDir = await getApplicationDocumentsDirectory();
      return '${appDir.path}/logs';
    } else {
      // Use local directory on desktop platforms
      return 'logs';
    }
  }

  Future<void> _loadLogFiles() async {
    setState(() => _isLoading = true);
    
    try {
      final logsPath = await _getLogsDirectoryPath();
      final logsDir = Directory(logsPath);
      if (await logsDir.exists()) {
        final files = await logsDir.list().toList();
        files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
        
        setState(() {
          _logFiles = files.where((f) => f.path.endsWith('.log')).toList();
        });
      }
    } catch (e) {
      print('Error loading log files: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLogContent(File logFile) async {
    setState(() => _isLoading = true);
    
    try {
      final content = await logFile.readAsString();
      setState(() {
        _selectedLogFile = logFile;
        _logContent = content;
      });
      
      // Auto-scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Error loading log content: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Clear all log files from the logs directory
  Future<void> _clearAllLogs() async {
    try {
      final logsPath = await _getLogsDirectoryPath();
      final logsDir = Directory(logsPath);
      
      if (await logsDir.exists()) {
        final files = await logsDir.list().toList();
        
        for (final file in files) {
          if (file is File && file.path.endsWith('.log')) {
            await file.delete();
          }
        }
        
        // Clear current state
        setState(() {
          _logFiles.clear();
          _selectedLogFile = null;
          _logContent = '';
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All log files cleared successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error clearing log files: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing logs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show confirmation dialog before clearing logs
  Future<void> _showClearLogsDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Clear All Logs'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all log files?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _clearAllLogs();
    }
  }



  Widget _buildLogContent() {
    if (_selectedLogFile == null) {
      return const Center(
        child: Text(
          'Select a log file to view its content',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (_logContent.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com informações do arquivo
          Row(
            children: [
              Text(
                'Content: ${_selectedLogFile!.uri.pathSegments.last}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Text(
                '${_logContent.split('\n').length} lines',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 8),
          // Conteúdo do log
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: SelectableText(
                  _logContent,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título consolidado com fonte menor (seguindo padrão RouterActionsPanel)
            Row(
              children: [
                Text(
                  'SSH LOGS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 16),
                  onPressed: _loadLogFiles,
                  tooltip: 'Refresh log files',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep, size: 16),
                  onPressed: _showClearLogsDialog,
                  tooltip: 'Clear all log files',
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Seção de seleção de arquivo (seguindo padrão Row layout)
            Row(
              children: [
                Text(
                  'Log File:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _logFiles.isEmpty
                      ? const Text(
                          'No SSH logs found - Connect to a router to start logging',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        )
                      : DropdownButton<File>(
                          isExpanded: true,
                          value: _selectedLogFile,
                          hint: const Text('Select a log file'),
                          onChanged: (file) => file != null ? _loadLogContent(file) : null,
                          items: _logFiles.map<DropdownMenuItem<File>>((entity) {
                            final file = entity as File;
                            final fileName = file.uri.pathSegments.last;
                            final stat = file.statSync();
                            return DropdownMenuItem<File>(
                              value: file,
                              child: Text(
                                '$fileName (${(stat.size / 1024).toStringAsFixed(1)} KB)',
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Conteúdo do log
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : _buildLogContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}