'''
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:yaml/yaml.dart';

import 'models/router_config.dart';
import 'models/script.dart';
import 'models/script_info.dart';
import 'services/crypto_service.dart';

class AppState with ChangeNotifier {
  // Private properties
  List<RouterConfig> _routers = [];
  List<Script> _scripts = [];
  RouterConfig? _selectedRouter;
  Script? _selectedScript;
  ScriptInfo? _scriptInfo;
  SSHClient? _sshClient;
  bool _isConnected = false;
  String _statusMessage = 'Initial';
  String _output = '';
  String _infoLog = '';
  bool _isLoading = false; // <<< NOVO: Estado de carregamento

  final CryptoService _cryptoService = CryptoService();

  // Public getters
  List<RouterConfig> get routers => _routers;
  List<Script> get scripts => _scripts;
  RouterConfig? get selectedRouter => _selectedRouter;
  Script? get selectedScript => _selectedScript;
  ScriptInfo? get scriptInfo => _scriptInfo;
  bool get isConnected => _isConnected;
  String get statusMessage => _statusMessage;
  String get output => _output;
  String get infoLog => _infoLog;
  bool get isLoading => _isLoading; // <<< NOVO: Getter para o estado

  AppState() {
    _loadConfig();
    _loadScripts();
  }

  // --- Métodos de Lógica Principal ---

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    _infoLog += '[$timestamp] $message
';
    notifyListeners();
  }

  Future<void> _loadConfig() async {
    try {
      _log("Loading configurations...");
      final configFile = File('config.yml');
      final content = await configFile.readAsString();
      final yaml = loadYaml(content);

      final key = Platform.environment['SCRIPT_RUNNER_KEY'];
      if (key == null || key.isEmpty) {
        throw Exception("SCRIPT_RUNNER_KEY environment variable not set.");
      }
      _cryptoService.setKey(key);

      _routers = (yaml['routers'] as YamlList)
          .map((routerData) => RouterConfig.fromYaml(routerData, _cryptoService))
          .toList();

      if (_routers.isNotEmpty) {
        _selectedRouter = _routers.first;
      }
      _log("Configurations loaded successfully.");
    } catch (e) {
      _statusMessage = 'Error loading config';
      _log("Error loading config.yml: $e");
    }
    notifyListeners();
  }

  Future<void> _loadScripts() async {
    try {
      _log("Loading scripts...");
      final scriptsDir = Directory('scripts');
      _scripts = await scriptsDir
          .list()
          .where((item) => item.path.endsWith('.txt'))
          .map((item) => Script(name: item.uri.pathSegments.last, path: item.path))
          .toList();

      if (_scripts.isNotEmpty) {
        _selectedScript = _scripts.first;
      }
      _log("Scripts loaded successfully.");
    } catch (e) {
      _statusMessage = 'Error loading scripts';
      _log("Error loading scripts: $e");
    }
    notifyListeners();
  }

  Future<void> connect() async {
    if (_selectedRouter == null) return;

    _setLoading(true);
    _statusMessage = 'Connecting to ${_selectedRouter!.name}...';
    _log('Attempting to connect to ${_selectedRouter!.host}...');

    try {
      final socket = await SSHSocket.connect(_selectedRouter!.host, _selectedRouter!.port);

      _sshClient = SSHClient(
        socket,
        username: _selectedRouter!.username,
        onPasswordRequest: () => _selectedRouter!.password,
      );

      await _sshClient!.authenticated;
      _isConnected = true;
      _statusMessage = 'Connected to ${_selectedRouter!.name}';
      _log('Connection successful!');
    } catch (e) {
      _isConnected = false;
      _statusMessage = 'Connection Failed';
      _log('Connection failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> disconnect() async {
    _setLoading(true);
    if (_sshClient != null) {
      _sshClient!.close();
      _sshClient = null;
    }
    _isConnected = false;
    _statusMessage = 'Disconnected';
    _output = '';
    _log('Disconnected.');
    _setLoading(false);
  }

  Future<void> executeScript() async {
    if (_sshClient == null || !_isConnected || _selectedScript == null) return;

    _setLoading(true);
    _statusMessage = 'Executing script...';

    try {
      final scriptFile = File(_selectedScript!.path);
      final command = await scriptFile.readAsString();

      _log('Executing command: $command');
      final result = await _sshClient!.run(command);
      _output = String.fromCharCodes(result);
      _statusMessage = 'Script executed successfully';
      _log('Script finished.');
    } catch (e) {
      _statusMessage = 'Script execution failed';
      _log('Script error: $e');
    } finally {
      _setLoading(false);
    }
  }

  void selectRouter(RouterConfig? router) {
    _selectedRouter = router;
    notifyListeners();
  }

  void selectScript(Script? script) {
    _selectedScript = script;
    notifyListeners();
  }
}
''