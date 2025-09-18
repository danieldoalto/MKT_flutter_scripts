import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../lib/services/crypto_service.dart';

void main() async {
  final configFile = File('config.yml');
  if (!await configFile.exists()) {
    print('Error: config.yml not found!');
    return;
  }

  final configContent = await configFile.readAsString();
  final yamlEditor = YamlEditor(configContent);
  final config = loadYaml(configContent);

  // Get encryption key from config file or environment
  final keyFromConfig = config['encryption_key'];
  final keyFromEnv = Platform.environment['SCRIPT_RUNNER_KEY'];
  final key = keyFromConfig ?? keyFromEnv;
  
  if (key == null || key.isEmpty) {
    print('Error: No encryption key found!');
    print('Either set encryption_key in config.yml or SCRIPT_RUNNER_KEY environment variable.');
    return;
  }

  final cryptoService = CryptoService();
  cryptoService.setKey(key);

  final List<dynamic> routers = config['routers'];
  bool hasChanges = false;

  for (var i = 0; i < routers.length; i++) {
    final router = routers[i];
    final plainPassword = router['password'];

    if (plainPassword != null && !isEncrypted(plainPassword, cryptoService)) {
      final encryptedPassword = cryptoService.encryptPassword(plainPassword);
      yamlEditor.update(['routers', i, 'password'], encryptedPassword);
      print('Encrypted password for: ${router['name']}');
      hasChanges = true;
    }
  }

  if (hasChanges) {
    // Set password_encrypted to true
    yamlEditor.update(['password_encrypted'], true);
    
    await configFile.writeAsString(yamlEditor.toString());
    print('\nconfig.yml has been updated with encrypted passwords.');
    print('password_encrypted flag set to true.');
  } else {
    print('\nNo passwords needed encryption.');
  }
}

bool isEncrypted(String password, CryptoService cryptoService) {
  try {
    cryptoService.decryptPassword(password);
    return true;
  } catch (e) {
    return false;
  }
}
