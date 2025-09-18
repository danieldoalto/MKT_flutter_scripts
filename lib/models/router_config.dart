class RouterConfig {
  final String name;
  final String host;
  final int port;
  final String username;
  final String password;
  final int userLevel;

  RouterConfig({
    required this.name,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    required this.userLevel,
  });

  factory RouterConfig.fromYaml(Map<dynamic, dynamic> yaml, String decryptedPassword) {
    return RouterConfig(
      name: yaml['name'],
      host: yaml['host'],
      port: yaml['port'],
      username: yaml['username'],
      password: decryptedPassword,
      userLevel: yaml['user_level'],
    );
  }
}
