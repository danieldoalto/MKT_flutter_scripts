import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:yaml/yaml.dart';

import 'models/router_config.dart' as router_models;
import 'models/script_info.dart';
import 'services/crypto_service.dart';
import 'services/script_service.dart';
import 'services/ssh_logger.dart';

class AppState with ChangeNotifier {
  // Private properties
  List<router_models.RouterConfig> _routers = [];
  List<ScriptInfo> _mikrotikScripts = [];
  router_models.RouterConfig? _selectedRouter;
  ScriptInfo? _selectedMikrotikScript;
  ScriptInfo? _scriptInfo;
  SSHClient? _sshClient;
  bool _isConnected = false;
  String _statusMessage = 'Initial';
  String _output = '';
  String _infoLog = '';
  bool _isLoading = false;

  // Error callback for showing dialogs
  Function(String, String)? _onError;
  
  // SSH Logger instance
  final SSHLogger _sshLogger = SSHLogger();
  
  void setErrorCallback(Function(String, String) callback) {
    _onError = callback;
  }
  
  void _showError(String title, String message) {
    _log('ERROR: $title - $message');
    if (_onError != null) {
      _onError!(title, message);
    }
  }

  // Public getters
  List<router_models.RouterConfig> get routers => _routers;
  List<ScriptInfo> get mikrotikScripts => _mikrotikScripts;
  router_models.RouterConfig? get selectedRouter => _selectedRouter;
  ScriptInfo? get selectedMikrotikScript => _selectedMikrotikScript;
  ScriptInfo? get scriptInfo => _scriptInfo;
  bool get isConnected => _isConnected;
  String get statusMessage => _statusMessage;
  String get output => _output;
  String get infoLog => _infoLog;
  bool get isLoading => _isLoading; // <<< NOVO: Getter para o estado

  AppState() {
    _loadConfig();
    // Clean old logs on startup
    _sshLogger.cleanOldLogs();
  }

  // --- Métodos de Lógica Principal ---

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    _infoLog += '[$timestamp] $message\n';
    notifyListeners();
  }

  Future<void> _loadConfig() async {
    try {
      _log("Loading configurations...");
      final configFile = File('config.yml');
      final content = await configFile.readAsString();
      final yaml = loadYaml(content);

      // Check if passwords are encrypted
      final passwordEncrypted = yaml['password_encrypted'] ?? true;
      
      CryptoService? cryptoService;
      if (passwordEncrypted) {
        // Initialize crypto service for encrypted passwords
        final key = yaml['encryption_key'] ?? Platform.environment['SCRIPT_RUNNER_KEY'];
        if (key == null || key.isEmpty) {
          throw Exception("Encryption key not found in config.yml or SCRIPT_RUNNER_KEY environment variable not set.");
        }
        cryptoService = CryptoService();
        cryptoService.setKey(key);
        _log("Using encrypted passwords with key from config.yml");
      } else {
        _log("Using plain text passwords (debug mode)");
      }

      _routers = (yaml['routers'] as YamlList)
          .map((routerData) => router_models.RouterConfig.fromYaml(routerData, yaml, cryptoService))
          .toList();

      if (_routers.isNotEmpty) {
        _selectedRouter = _routers.first;
      }
      _log("Configurations loaded successfully.");
    } catch (e) {
      _statusMessage = 'Error loading config';
      _showError('Configuration Error', 'Failed to load config.yml: $e');
    }
    notifyListeners();
  }

  Future<void> _loadScriptCache() async {
    if (_selectedRouter == null) return;
    
    try {
      _log("Loading script cache for ${_selectedRouter!.name}...");
      _mikrotikScripts = await ScriptService.loadScriptCache(_selectedRouter!.name);
      
      if (_mikrotikScripts.isNotEmpty) {
        _selectedMikrotikScript = _mikrotikScripts.first;
      }
      
      _log("Loaded ${_mikrotikScripts.length} scripts from cache.");
    } catch (e) {
      _log("Error loading script cache: $e");
    }
    notifyListeners();
  }

  Future<void> connect() async {
    if (_selectedRouter == null) return;

    _setLoading(true);
    _statusMessage = 'Connecting to ${_selectedRouter!.name}...';
    _log('Attempting to connect to ${_selectedRouter!.host}...');

    try {
      // Start SSH logging session
      await _sshLogger.startSession(_selectedRouter!.name, _selectedRouter!.host);
      await _sshLogger.logConnection('INIT', 'Initializing SSH connection to ${_selectedRouter!.host}:${_selectedRouter!.port}');
      
      final socket = await SSHSocket.connect(_selectedRouter!.host, _selectedRouter!.port);
      await _sshLogger.logConnection('SOCKET_CONNECTED', 'TCP socket established');

      _sshClient = SSHClient(
        socket,
        username: _selectedRouter!.username,
        onPasswordRequest: () {
          _sshLogger.logConnection('AUTH_REQUEST', 'Password requested for user: ${_selectedRouter!.username}');
          return _selectedRouter!.password;
        },
      );

      await _sshLogger.logConnection('AUTH_START', 'Starting authentication for user: ${_selectedRouter!.username}');
      await _sshClient!.authenticated;
      await _sshLogger.logConnection('AUTH_SUCCESS', 'Authentication successful');
      
      _isConnected = true;
      _statusMessage = 'Connected to ${_selectedRouter!.name}';
      _log('Connection successful!');
      await _sshLogger.logConnection('SESSION_ESTABLISHED', 'SSH session ready for commands');
      
      // Load script cache after successful connection
      await _loadScriptCache();
    } catch (e) {
      _isConnected = false;
      _statusMessage = 'Connection Failed';
      await _sshLogger.logError(e.toString(), 'connection');
      await _sshLogger.endSession();
      _showError('Connection Error', 'Failed to connect to ${_selectedRouter!.name}: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateScripts() async {
    if (_sshClient == null || !_isConnected || _selectedRouter == null) return;

    _setLoading(true);
    _statusMessage = 'Discovering scripts from router...';
    _log('Executing /system script print detail...');

    try {
      await _sshLogger.logCommand('/system script print detail');
      final scripts = await ScriptService.discoverScripts(_sshClient!, _selectedRouter!, _sshLogger);
      _mikrotikScripts = scripts;
      
      if (_mikrotikScripts.isNotEmpty) {
        _selectedMikrotikScript = _mikrotikScripts.first;
      }
      
      // Save to cache
      await ScriptService.saveScriptCache(_selectedRouter!.name, _mikrotikScripts);
      
      _statusMessage = 'Scripts updated successfully';
      _log('Discovered ${_mikrotikScripts.length} scripts and saved to cache.');
      await _sshLogger.logConnection('SCRIPT_DISCOVERY_COMPLETE', 'Found ${_mikrotikScripts.length} accessible scripts');
    } catch (e) {
      _statusMessage = 'Script discovery failed';
      await _sshLogger.logError(e.toString(), 'script discovery');
      _showError('Script Discovery Error', 'Failed to discover scripts from router: $e');
    } finally {
      _setLoading(false);
    }
  }
  Future<void> disconnect() async {
    _setLoading(true);
    
    await _sshLogger.logConnection('DISCONNECT_START', 'Initiating SSH session termination');
    
    if (_sshClient != null) {
      _sshClient!.close();
      _sshClient = null;
      await _sshLogger.logConnection('DISCONNECT_COMPLETE', 'SSH client closed');
    }
    
    _isConnected = false;
    _statusMessage = 'Disconnected';
    _output = '';
    _log('Disconnected.');
    
    // End SSH logging session
    await _sshLogger.endSession();
    
    _setLoading(false);
  }

  Future<void> executeScript() async {
    if (_sshClient == null || !_isConnected || _selectedMikrotikScript == null) return;

    _setLoading(true);
    _statusMessage = 'Executing script...';

    try {
      final command = '/system script run "${_selectedMikrotikScript!.name}"';
      
      _log('Executing command: $command');
      await _sshLogger.logCommand(command);
      await _sshLogger.logConnection('SCRIPT_EXEC_START', 'Starting execution of script: ${_selectedMikrotikScript!.name}');
      
      final result = await _sshClient!.run(command);
      final output = String.fromCharCodes(result);
      
      await _sshLogger.logResponse(output);
      
      _output = output;
      _statusMessage = 'Script executed successfully';
      _log('Script "${_selectedMikrotikScript!.name}" finished.');
      await _sshLogger.logConnection('SCRIPT_EXEC_COMPLETE', 'Script execution completed successfully. Output length: ${output.length} chars');
    } catch (e) {
      _statusMessage = 'Script execution failed';
      await _sshLogger.logError(e.toString(), 'script execution');
      _showError('Script Execution Error', 'Failed to execute script "${_selectedMikrotikScript!.name}": $e');
    } finally {
      _setLoading(false);
    }
  }

  void selectRouter(router_models.RouterConfig? router) {
    _selectedRouter = router;
    _selectedMikrotikScript = null; // Clear selected script when router changes
    _mikrotikScripts.clear(); // Clear scripts list
    if (router != null) {
      _loadScriptCache(); // Load cache for new router
    }
    notifyListeners();
  }

  void selectMikrotikScript(ScriptInfo? script) {
    _selectedMikrotikScript = script;
    notifyListeners();
  }
}