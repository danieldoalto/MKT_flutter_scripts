import 'dart:io';
import 'package:yaml/yaml.dart';
import 'lib/services/crypto_service.dart';
import 'lib/models/router_config.dart' as router_models;

void main() {
  print('🔍 Testing New Configuration System...\n');
  
  try {
    // Load config file
    final configFile = File('config.yml');
    final content = configFile.readAsStringSync();
    final yaml = loadYaml(content);
    
    // Check configuration
    final passwordEncrypted = yaml['password_encrypted'] ?? true;
    print('📋 Configuration:');
    print('   - password_encrypted: $passwordEncrypted');
    
    CryptoService? cryptoService;
    if (passwordEncrypted) {
      final key = yaml['encryption_key'] ?? Platform.environment['SCRIPT_RUNNER_KEY'];
      print('   - encryption_key: ${key != null ? "Found (${key.length} chars)" : "Not found"}');
      
      if (key == null || key.isEmpty) {
        print('❌ ERROR: No encryption key available!');
        return;
      }
      cryptoService = CryptoService();
      cryptoService.setKey(key);
    } else {
      print('   - Using plain text passwords (debug mode)');
    }
    
    // Test router loading
    print('\n🔗 Testing router configuration:');
    final routers = (yaml['routers'] as YamlList)
        .map((routerData) => router_models.RouterConfig.fromYaml(routerData, yaml, cryptoService))
        .toList();
    
    for (final router in routers) {
      print('✅ ${router.name}: ${router.username}@${router.host}:${router.port} (password: ${router.password.length} chars)');
    }
    
    print('\n🎉 Configuration loaded successfully!');
    print('💡 You can now run: flutter run -d windows');
    
  } catch (e) {
    print('❌ ERROR: $e');
  }
}