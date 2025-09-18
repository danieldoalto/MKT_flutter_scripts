import 'dart:io';
import '../lib/services/crypto_service.dart';

void main() async {
  print('=== MikroTik SSH Connection Troubleshooter ===\n');
  
  // Check environment variable
  final key = Platform.environment['SCRIPT_RUNNER_KEY'];
  if (key == null || key.isEmpty) {
    print('❌ ERROR: SCRIPT_RUNNER_KEY environment variable not set!');
    print('Set it with: \$env:SCRIPT_RUNNER_KEY="your-secret-key"');
    return;
  }
  print('✅ Environment variable SCRIPT_RUNNER_KEY is set (${key.length} chars)');
  
  // Test decryption with sample passwords from config.yml
  final cryptoService = CryptoService();
  cryptoService.setKey(key);
  
  final testPasswords = [
    '7Mi3zC6+rRYX1kh31KmoUQ==',  // Casa Daniel
    '44BCzGF5BXbeN88dAEukvw==',  // Router TF  
    'x/YypnPgfgm1Wp0t/NVAww==',  // Router borda
  ];
  
  print('\n=== Testing Password Decryption ===');
  for (int i = 0; i < testPasswords.length; i++) {
    try {
      final decrypted = cryptoService.decryptPassword(testPasswords[i]);
      print('✅ Password ${i + 1}: Successfully decrypted (length: ${decrypted.length})');
    } catch (e) {
      print('❌ Password ${i + 1}: Failed to decrypt - $e');
      print('   This means the SCRIPT_RUNNER_KEY is wrong!');
    }
  }
  
  print('\n=== Network Connectivity Test ===');
  final routers = [
    {'name': 'Casa Daniel', 'host': '192.168.10.1'},
    {'name': 'Router TF', 'host': '10.1.1.1'},
    {'name': 'Router borda', 'host': '192.168.0.254'},
  ];
  
  for (final router in routers) {
    try {
      print('Testing ${router['name']} (${router['host']})...');
      final result = await Process.run('ping', ['-n', '1', router['host']!]);
      if (result.exitCode == 0) {
        print('✅ ${router['name']}: Network reachable');
      } else {
        print('❌ ${router['name']}: Network unreachable');
      }
    } catch (e) {
      print('❌ ${router['name']}: Ping failed - $e');
    }
  }
  
  print('\n=== Troubleshooting Tips ===');
  print('1. Ensure SCRIPT_RUNNER_KEY matches the key used during encryption');
  print('2. Verify router IP addresses are correct and reachable');
  print('3. Check if SSH is enabled on MikroTik: /ip service enable ssh');
  print('4. Verify username/password are correct for MikroTik device');
  print('5. Try connecting manually: ssh admin@192.168.10.1');
}