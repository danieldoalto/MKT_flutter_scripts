import 'dart:io';
import 'lib/services/script_service.dart';
import 'lib/models/router_config.dart' as router_models;

void main() async {
  print('🧪 Testing Optimized Script Discovery System...\n');
  
  // Test the new script name parsing
  print('📋 Testing script name parsing:');
  final testScriptOutput = '''
PCDan_Hibernate
PCDan_Suspend
PCDan_ShutDown
PCDan_Stop
pc_hibernate
pc_suspend
pc_shutdown
mkt1_ping_test
mkt1_backup_config
mkt2_reboot_device
mkt2_system_update
''';
  
  final scriptNames = ScriptService.parseScriptNames(testScriptOutput);
  print('   Found ${scriptNames.length} script names:');
  for (final name in scriptNames) {
    print('   - $name');
  }
  
  // Test filtering for different user levels
  print('\n🔍 Testing script filtering:');
  
  print('\n   User Level 1 (can access mkt1_ and mkt2_):');
  final level1Scripts = ScriptService.filterScriptNames(scriptNames, 1);
  for (final name in level1Scripts) {
    print('   ✅ $name');
  }
  
  print('\n   User Level 2 (can access only mkt2_):');
  final level2Scripts = ScriptService.filterScriptNames(scriptNames, 2);
  for (final name in level2Scripts) {
    print('   ✅ $name');
  }
  
  // Test command template replacement
  print('\n🔧 Testing command templates:');
  
  final testCommands = {
    'list_scripts': ':foreach s in=[/system script find] do={ :put [/system script get \$s name] }',
    'get_comment': ':put [system/script/ get [find name="{script_name}"] comment ]',
  };
  
  final mockConfig = router_models.RouterConfig(
    name: 'Test Router',
    host: '192.168.1.1',
    port: 22,
    username: 'admin',
    password: 'test',
    userLevel: 1,
    commands: testCommands,
  );
  
  print('   List Scripts Command: ${mockConfig.commands['list_scripts']}');
  
  final commentTemplate = mockConfig.commands['get_comment']!;
  final testScriptName = 'mkt1_ping_test';
  final commentCommand = commentTemplate.replaceAll('{script_name}', testScriptName);
  print('   Comment Command for "$testScriptName": $commentCommand');
  
  print('\n✅ Optimized script discovery system tests completed!');
  print('\n📝 Summary of improvements:');
  print('   🚀 Faster: Uses simple script name list instead of detailed output');
  print('   🎯 Efficient: Filters by level before retrieving comments');
  print('   🔧 Flexible: Commands configurable per router in config.yml');
  print('   📋 Clean: Separates script discovery from description retrieval');
  print('   📊 Better logging: More granular logging of each step');
}