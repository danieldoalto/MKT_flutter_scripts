import 'package:flutter/material.dart';
import 'dart:io';

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

  Future<void> _loadLogFiles() async {
    setState(() => _isLoading = true);
    
    try {
      final logsDir = Directory('logs');
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

  Widget _buildLogList() {
    if (_logFiles.isEmpty) {
      return const Center(
        child: Text(
          'No SSH logs found.\nConnect to a router to start logging.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _logFiles.length,
      itemBuilder: (context, index) {
        final file = _logFiles[index] as File;
        final fileName = file.uri.pathSegments.last;
        final stat = file.statSync();
        final isSelected = _selectedLogFile?.path == file.path;
        
        return ListTile(
          dense: true,
          selected: isSelected,
          leading: const Icon(Icons.description, size: 16),
          title: Text(
            fileName,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${stat.modified.toString().substring(0, 19)} (${(stat.size / 1024).toStringAsFixed(1)} KB)',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          onTap: () => _loadLogContent(file),
        );
      },
    );
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
      padding: const EdgeInsets.all(8.0),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.terminal, size: 18),
                const SizedBox(width: 8),
                Text(
                  'SSH Communication Logs',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 16),
                  onPressed: _loadLogFiles,
                  tooltip: 'Refresh log files',
                ),
                IconButton(
                  icon: const Icon(Icons.folder_open, size: 16),
                  onPressed: () async {
                    // Open logs directory
                    try {
                      await Process.run('explorer', ['logs']);
                    } catch (e) {
                      print('Could not open logs directory: $e');
                    }
                  },
                  tooltip: 'Open logs folder',
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Row(
              children: [
                // Log files list
                SizedBox(
                  width: 250,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.black12,
                        child: const Row(
                          children: [
                            Icon(Icons.list, size: 14),
                            SizedBox(width: 4),
                            Text('Log Files', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _isLoading 
                            ? const Center(child: CircularProgressIndicator())
                            : _buildLogList(),
                      ),
                    ],
                  ),
                ),
                
                // Divider
                const VerticalDivider(width: 1),
                
                // Log content
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.black12,
                        child: Row(
                          children: [
                            const Icon(Icons.code, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _selectedLogFile != null 
                                  ? 'Content: ${_selectedLogFile!.uri.pathSegments.last}'
                                  : 'Log Content',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            if (_selectedLogFile != null)
                              Text(
                                '${_logContent.split('\n').length} lines',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.black87,
                          child: _buildLogContent(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}