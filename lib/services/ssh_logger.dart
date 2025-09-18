import 'dart:io';
import 'dart:convert';

class SSHLogger {
  static final SSHLogger _instance = SSHLogger._internal();
  factory SSHLogger() => _instance;
  SSHLogger._internal();

  File? _currentLogFile;
  String? _currentSession;
  final List<String> _sessionLogs = [];

  /// Initialize logging for a new SSH session
  Future<void> startSession(String routerName, String host) async {
    final timestamp = DateTime.now();
    final sessionId = '${timestamp.millisecondsSinceEpoch}';
    _currentSession = sessionId;
    
    // Create logs directory if it doesn't exist
    final logsDir = Directory('logs');
    if (!await logsDir.exists()) {
      await logsDir.create();
    }
    
    // Create session log file
    final fileName = 'ssh_${routerName.replaceAll(' ', '_')}_${_formatDateTime(timestamp)}.log';
    _currentLogFile = File('logs/$fileName');
    
    // Clear session buffer
    _sessionLogs.clear();
    
    // Write session header
    final header = '''
================================================================================
SSH Communication Log
================================================================================
Router: $routerName
Host: $host
Session ID: $sessionId
Started: ${timestamp.toIso8601String()}
================================================================================

''';
    
    await _writeToFile(header);
    _logToSession('SESSION_START', 'SSH session started for $routerName ($host)');
  }

  /// Log SSH command being sent
  Future<void> logCommand(String command) async {
    final timestamp = DateTime.now();
    final logEntry = '[${_formatTime(timestamp)}] >>> COMMAND: $command';
    
    await _writeToFile('$logEntry\n');
    _logToSession('COMMAND', command);
    
    // Also log to console for debugging
    print('🔴 SSH CMD: $command');
  }

  /// Log SSH response received
  Future<void> logResponse(String response) async {
    final timestamp = DateTime.now();
    
    // Format response for better readability
    final lines = response.split('\n');
    final formattedResponse = lines.map((line) => '    $line').join('\n');
    
    final logEntry = '[${_formatTime(timestamp)}] <<< RESPONSE:\n$formattedResponse';
    
    await _writeToFile('$logEntry\n\n');
    _logToSession('RESPONSE', response);
    
    // Also log to console for debugging (truncated)
    final truncated = response.length > 200 ? '${response.substring(0, 200)}...' : response;
    print('🔵 SSH RESP: ${truncated.replaceAll('\n', '\\n')}');
  }

  /// Log connection events
  Future<void> logConnection(String event, String details) async {
    final timestamp = DateTime.now();
    final logEntry = '[${_formatTime(timestamp)}] === CONNECTION: $event - $details';
    
    await _writeToFile('$logEntry\n');
    _logToSession('CONNECTION', '$event - $details');
    
    print('🟡 SSH CONN: $event - $details');
  }

  /// Log errors
  Future<void> logError(String error, String context) async {
    final timestamp = DateTime.now();
    final logEntry = '[${_formatTime(timestamp)}] !!! ERROR in $context: $error';
    
    await _writeToFile('$logEntry\n');
    _logToSession('ERROR', '$context: $error');
    
    print('🔴 SSH ERROR: $error');
  }

  /// End current SSH session
  Future<void> endSession() async {
    if (_currentLogFile == null) return;
    
    final timestamp = DateTime.now();
    final footer = '''
================================================================================
Session ended: ${timestamp.toIso8601String()}
Total operations: ${_sessionLogs.length}
================================================================================
''';
    
    await _writeToFile(footer);
    _logToSession('SESSION_END', 'SSH session ended');
    
    // Create session summary
    await _writeSummary();
    
    _currentLogFile = null;
    _currentSession = null;
    
    print('📋 SSH session logged to: ${_currentLogFile?.path}');
  }

  /// Get current session logs (for UI display)
  List<Map<String, String>> getSessionLogs() {
    return _sessionLogs.map((log) {
      final parts = log.split('|');
      return {
        'timestamp': parts[0],
        'type': parts[1],
        'message': parts.length > 2 ? parts[2] : '',
      };
    }).toList();
  }

  /// Write session summary
  Future<void> _writeSummary() async {
    if (_currentLogFile == null) return;
    
    final summaryFile = File('${_currentLogFile!.path}.summary.json');
    final summary = {
      'session_id': _currentSession,
      'started': DateTime.now().toIso8601String(),
      'total_operations': _sessionLogs.length,
      'operations': _sessionLogs.map((log) {
        final parts = log.split('|');
        return {
          'timestamp': parts[0],
          'type': parts[1],
          'message': parts.length > 2 ? parts[2] : '',
        };
      }).toList(),
    };
    
    await summaryFile.writeAsString(jsonEncode(summary));
  }

  /// Internal method to write to log file
  Future<void> _writeToFile(String content) async {
    if (_currentLogFile != null) {
      await _currentLogFile!.writeAsString(content, mode: FileMode.append);
    }
  }

  /// Internal method to add to session buffer
  void _logToSession(String type, String message) {
    final timestamp = DateTime.now().toIso8601String();
    _sessionLogs.add('$timestamp|$type|$message');
  }

  /// Format timestamp for log entries
  String _formatTime(DateTime timestamp) {
    return timestamp.toIso8601String().substring(11, 23); // HH:mm:ss.SSS
  }

  /// Format date for filename
  String _formatDateTime(DateTime timestamp) {
    return timestamp.toIso8601String().replaceAll(':', '-').split('.')[0];
  }

  /// Clean old log files (keep last 30 days)
  Future<void> cleanOldLogs() async {
    final logsDir = Directory('logs');
    if (!await logsDir.exists()) return;
    
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    
    await for (final entity in logsDir.list()) {
      if (entity is File && entity.path.endsWith('.log')) {
        final stat = await entity.stat();
        if (stat.modified.isBefore(cutoffDate)) {
          await entity.delete();
          print('🗑️ Deleted old log: ${entity.path}');
        }
      }
    }
  }
}