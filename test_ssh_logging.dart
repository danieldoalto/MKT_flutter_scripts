import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'lib/services/ssh_logger.dart';

void main() async {
  print('🧪 Testing SSH Logger...\n');
  
  final logger = SSHLogger();
  
  // Simulate an SSH session
  await logger.startSession('Test Router', '192.168.1.1');
  
  // Simulate connection events
  await logger.logConnection('INIT', 'Initializing SSH connection');
  await logger.logConnection('SOCKET_CONNECTED', 'TCP socket established');
  await logger.logConnection('AUTH_START', 'Starting authentication');
  await logger.logConnection('AUTH_SUCCESS', 'Authentication successful');
  
  // Simulate some commands and responses
  await logger.logCommand('/system resource print');
  await logger.logResponse('''architecture-name: x86_64
board-name: CHR
cpu: QEMU Virtual CPU version 2.5+
cpu-count: 2
cpu-frequency: 2992MHz
cpu-load: 1%
free-memory: 387.5MiB
total-memory: 512.0MiB
uptime: 1w2d3h45m
version: 7.6 (stable)
''');
  
  await logger.logCommand('/system script print detail');
  await logger.logResponse('''Flags: I - invalid 
 0   name="mkt1_backup" owner="admin" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon 
     source=# Backup router configuration
         /system backup save name=("backup-" . [/system clock get date])
         :log info "Backup completed successfully"
 
 1   name="mkt2_reboot" owner="admin" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon 
     source=# Safely reboot the router
         :log info "Reboot initiated by script"
         /system reboot
''');
  
  await logger.logCommand('/system script run "mkt1_backup"');
  await logger.logResponse('''backup completed successfully
''');
  
  // Simulate an error
  await logger.logError('Connection timeout', 'command execution');
  
  // End session
  await logger.endSession();
  
  print('✅ SSH logging test completed!');
  print('📁 Check the logs/ directory for generated files.');
  
  // List generated files
  String logsPath;
  if (Platform.isAndroid || Platform.isIOS) {
    final appDir = await getApplicationDocumentsDirectory();
    logsPath = '${appDir.path}/logs';
  } else {
    logsPath = 'logs';
  }
  
  final logsDir = Directory(logsPath);
  if (await logsDir.exists()) {
    print('\n📋 Generated log files:');
    await for (final entity in logsDir.list()) {
      if (entity is File) {
        final stat = await entity.stat();
        print('   ${entity.uri.pathSegments.last} (${(stat.size / 1024).toStringAsFixed(1)} KB)');
      }
    }
  }
}