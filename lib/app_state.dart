import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:xterm/xterm.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

import 'models/router_config.dart';
import 'models/script.dart';
import 'services/crypto_service.dart';

enum AppStatus {
  initial,
  connecting,
  connected,
  loadingScripts,
  executingScript,
  error,
}

class AppState with ChangeNotifier {
  List<RouterConfig> _routers = [];
  RouterConfig? _selectedRouter;
  List<Script> _scripts = [];
  Script? _selectedScript;
  AppStatus _status = AppStatus.initial;
  String _informationLog = "";
  SSHClient? _sshClient;
  final Terminal _terminal = Terminal();

  List<RouterConfig> get routers => _routers;
  RouterConfig? get selectedRouter => _selectedRouter;
  List<Script> get scripts => _scripts;
  Script? get selectedScript => _selectedScript;
  AppStatus get status => _status;
  String get informationLog => _informationLog;
  Terminal get terminal => _terminal;

  AppState() {
    _init();
  }

  @override
  void dispose() {
    disconnectSsh();
    super.dispose();
  }

  void _init() async {
    _logInfo("Log manager initialized successfully");
    await _loadConfig();
    await _loadScripts();
  }

  void _logInfo(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(0, 19).replaceFirst('T', ' ');
    _informationLog += "[$timestamp] $message\n";
    notifyListeners();
  }

  void _logError(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(0, 19).replaceFirst('T', ' ');
    _informationLog += "[$timestamp] ERROR: $message\n";
    _status = AppStatus.error;
    notifyListeners();
  }

  Future<void> _loadConfig() async {
    try {
      const String configFileName = 'config.yml';
      final String executablePath = path.dirname(Platform.resolvedExecutable);
      final String configPath = path.join(executablePath, configFileName);
      File configFile = File(configPath);

      if (!await configFile.exists()) {
        configFile = File(configFileName);
        if (!await configFile.exists()) {
          throw Exception('config.yml not found in the executable directory or the project root.');
        }
      }

      final configContent = await configFile.readAsString();
      final dynamic yamlMap = loadYaml(configContent);

      if (yamlMap == null || yamlMap['routers'] == null) {
        throw Exception('Invalid config.yml format.');
      }

      final List<dynamic> routerList = yamlMap['routers'];
      _routers = routerList.map((routerData) {
        final String encryptedPassword = routerData['password'];
        final String decryptedPassword = CryptoService.decryptPassword(encryptedPassword);
        return RouterConfig.fromYaml(routerData, decryptedPassword);
      }).toList();

      _logInfo("Configuration loaded successfully");
      notifyListeners();
    } catch (e) {
      _logError("Failed to load config.yml: ${e.toString()}");
    }
  }

  Future<void> _loadScripts() async {
    try {
      final scriptDir = Directory('scripts');
      if (!await scriptDir.exists()) {
        _logInfo('Script directory not found.');
        _scripts = [];
        return;
      }

      final scriptFiles = scriptDir.listSync().whereType<File>().toList();
      _scripts = scriptFiles.map((file) {
        return Script(name: path.basename(file.path), path: file.path);
      }).toList();

      _logInfo('Loaded ${_scripts.length} scripts.');
      notifyListeners();
    } catch (e) {
      _logError('Failed to load scripts: $e');
    }
  }

  Future<void> selectRouter(RouterConfig? router) async {
    if (_selectedRouter != router) {
      await disconnectSsh();
      _selectedRouter = router;
      _selectedScript = null;
      if (router != null) {
        _logInfo("Selected router: ${router.name}");
        await connectSsh();
      }
      notifyListeners();
    }
  }

  void selectScript(Script? script) {
    if (_selectedScript != script) {
      _selectedScript = script;
      notifyListeners();
    }
  }

  Future<void> connectSsh() async {
    if (_selectedRouter == null) return;

    _status = AppStatus.connecting;
    _logInfo('Connecting to ${_selectedRouter!.name}...');
    notifyListeners();

    try {
      _sshClient = await SSHClient(
        host: _selectedRouter!.host,
        port: _selectedRouter!.port,
        username: _selectedRouter!.username,
        onPasswordRequest: () => _selectedRouter!.password,
      );
      _status = AppStatus.connected;
      _logInfo('Connected to ${_selectedRouter!.name}');
      notifyListeners();
    } catch (e) {
      _logError('Failed to connect: $e');
    }
  }

  Future<void> disconnectSsh() async {
    if (_sshClient != null) {
      _sshClient!.close();
      _sshClient = null;
      _status = AppStatus.initial;
      _logInfo('Disconnected.');
      notifyListeners();
    }
  }

  Future<void> executeScript() async {
    if (_sshClient == null || _selectedScript == null) return;

    _status = AppStatus.executingScript;
    _logInfo('Executing script: ${_selectedScript!.name}');
    _terminal.clear();
    notifyListeners();

    try {
      final scriptContent = await File(_selectedScript!.path).readAsString();
      final session = await _sshClient!.shell();
      
      final scriptCompleter = Completer();

      session.stdout.transform(utf8.decoder).listen((data) {
        _terminal.write(data);
      });

      session.stderr.transform(utf8.decoder).listen((data) {
        _terminal.write(data);
      });

      session.write(utf8.encode(scriptContent));
      await session.close();

      _logInfo('Script execution finished.');
    } catch (e) {
      _logError('Script execution failed: $e');
    }
    _status = AppStatus.connected;
    notifyListeners();
  }
}
