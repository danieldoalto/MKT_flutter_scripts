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

  final List<dynamic> routers = config['routers'];

  for (var i = 0; i < routers.length; i++) {
    final router = routers[i];
    final plainPassword = router['password'];

    if (plainPassword != null && !isEncrypted(plainPassword)) {
      final encryptedPassword = CryptoService.encryptPassword(plainPassword);
      yamlEditor.update(['routers', i, 'password'], encryptedPassword);
      print('Encrypted password for: ${router['name']}');
    }
  }

  await configFile.writeAsString(yamlEditor.toString());
  print('\nconfig.yml has been updated with encrypted passwords.');
}

bool isEncrypted(String password) {
  try {
    CryptoService.decryptPassword(password);
    return true;
  } catch (e) {
    return false;
  }
}
