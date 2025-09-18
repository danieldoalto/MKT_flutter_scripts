import '../services/crypto_service.dart';

class RouterConfig {
  final String name;
  final String host;
  final int port;
  final String username;
  final String password;
  final int userLevel;
  final Map<String, String> commands;

  RouterConfig({
    required this.name,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    required this.userLevel,
    required this.commands,
  });

  factory RouterConfig.fromYaml(Map<dynamic, dynamic> yaml, Map<dynamic, dynamic> config, CryptoService? cryptoService) {
    final passwordEncrypted = config['password_encrypted'] ?? true; // Default to encrypted for safety
    final rawPassword = yaml['password'] as String;
    
    String decryptedPassword;
    if (passwordEncrypted) {
      // Encrypted password - decrypt it
      if (cryptoService == null) {
        throw Exception('CryptoService required for encrypted passwords');
      }
      decryptedPassword = cryptoService.decryptPassword(rawPassword);
    } else {
      // Plain text password - use as is
      decryptedPassword = rawPassword;
    }
    
    // Get commands - use router-specific commands or fall back to defaults
    final defaultCommands = config['default_commands'] as Map<dynamic, dynamic>? ?? {};
    final routerCommands = yaml['commands'] as Map<dynamic, dynamic>? ?? {};
    
    final commands = <String, String>{};
    // Add default commands
    defaultCommands.forEach((key, value) {
      commands[key.toString()] = value.toString();
    });
    // Override with router-specific commands
    routerCommands.forEach((key, value) {
      commands[key.toString()] = value.toString();
    });
    
    return RouterConfig(
      name: yaml['name'],
      host: yaml['host'],
      port: yaml['port'],
      username: yaml['username'],
      password: decryptedPassword,
      userLevel: yaml['user_level'],
      commands: commands,
    );
  }
}
