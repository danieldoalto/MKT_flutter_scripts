import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';

import '../models/script_info.dart';
import 'ssh_logger.dart';

import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';

import '../models/script_info.dart';
import '../models/router_config.dart' as router_models;
import 'ssh_logger.dart';

class ScriptService {
  /// Discovers scripts from MikroTik router via SSH using optimized commands
  static Future<List<ScriptInfo>> discoverScripts(SSHClient sshClient, router_models.RouterConfig routerConfig, [SSHLogger? logger]) async {
    try {
      // Step 1: Get list of script names using optimized command
      final listCommand = routerConfig.commands['list_scripts'] ?? 
          ":foreach s in=[/system script find] do={ :put [/system script get \$s name] }";
      
      if (logger != null) {
        await logger.logCommand(listCommand);
        await logger.logConnection('SCRIPT_LIST_START', 'Retrieving script names list');
      }
      
      final listResult = await sshClient.run(listCommand);
      final scriptNamesOutput = String.fromCharCodes(listResult);
      
      if (logger != null) {
        await logger.logResponse(scriptNamesOutput);
      }
      
      // Step 2: Parse script names from the simple output format
      final allScriptNames = parseScriptNames(scriptNamesOutput);
      
      if (logger != null) {
        await logger.logConnection('SCRIPT_NAMES_PARSED', 'Found ${allScriptNames.length} total scripts');
      }
      
      // Step 3: Filter script names by user level and naming convention
      final filteredScriptNames = filterScriptNames(allScriptNames, routerConfig.userLevel);
      
      if (logger != null) {
        await logger.logConnection('SCRIPT_NAMES_FILTERED', 'Filtered to ${filteredScriptNames.length} accessible scripts for user level ${routerConfig.userLevel}');
      }
      
      // Step 4: Retrieve comments/descriptions for filtered scripts
      final scripts = await _retrieveScriptComments(sshClient, routerConfig, filteredScriptNames, logger);
      
      if (logger != null) {
        await logger.logConnection('SCRIPT_DISCOVERY_COMPLETE', 'Successfully processed ${scripts.length} scripts with descriptions');
      }
      
      return scripts;
    } catch (e) {
      if (logger != null) {
        await logger.logError(e.toString(), 'script discovery');
      }
      throw Exception('Failed to discover scripts: $e');
    }
  }

  /// Parses script names from the simple output format (one name per line) - Public for testing
  static List<String> parseScriptNames(String output) {
    final scriptNames = <String>[];
    final lines = output.split('\n');
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isNotEmpty && !trimmedLine.startsWith('Flags:')) {
        scriptNames.add(trimmedLine);
      }
    }
    
    return scriptNames;
  }

  /// Filters script names based on user level and naming convention - Public for testing
  static List<String> filterScriptNames(List<String> scriptNames, int userLevel) {
    final filteredNames = <String>[];
    
    for (final name in scriptNames) {
      // Check if script follows the mkt<LEVEL>_ naming convention
      final levelMatch = RegExp(r'^mkt(\d+)_').firstMatch(name);
      if (levelMatch == null) {
        continue; // Skip scripts that don't follow the convention
      }
      
      final scriptLevel = int.parse(levelMatch.group(1)!);
      
      // Apply user level filtering
      // Level 1 users can access mkt1_ and mkt2_ scripts
      // Level 2 users can only access mkt2_ scripts
      if (userLevel == 1 && (scriptLevel == 1 || scriptLevel == 2)) {
        filteredNames.add(name);
      } else if (userLevel == 2 && scriptLevel == 2) {
        filteredNames.add(name);
      }
    }
    
    return filteredNames;
  }

  /// Retrieves script comments/descriptions for filtered script names
  static Future<List<ScriptInfo>> _retrieveScriptComments(SSHClient sshClient, router_models.RouterConfig routerConfig, List<String> scriptNames, SSHLogger? logger) async {
    final scripts = <ScriptInfo>[];
    final commentCommandTemplate = routerConfig.commands['get_comment'] ?? 
        ":put [system/script/ get [find name=\"{script_name}\"] comment ]";
    
    for (final scriptName in scriptNames) {
      try {
        // Replace {script_name} placeholder with actual script name
        final commentCommand = commentCommandTemplate.replaceAll('{script_name}', scriptName);
        
        if (logger != null) {
          await logger.logCommand(commentCommand);
        }
        
        final commentResult = await sshClient.run(commentCommand);
        final commentOutput = String.fromCharCodes(commentResult).trim();
        
        if (logger != null) {
          await logger.logResponse(commentOutput);
        }
        
        // Extract script level from name
        final levelMatch = RegExp(r'^mkt(\d+)_').firstMatch(scriptName);
        final scriptLevel = levelMatch != null ? int.parse(levelMatch.group(1)!) : 1;
        
        // Use comment as description, or provide default
        final description = commentOutput.isEmpty ? 'No description available' : commentOutput;
        
        final scriptInfo = ScriptInfo(
          name: scriptName,
          description: description,
          level: scriptLevel,
        );
        
        scripts.add(scriptInfo);
        
        if (logger != null) {
          await logger.logConnection('SCRIPT_COMMENT_RETRIEVED', 'Got comment for script: $scriptName');
        }
        
      } catch (e) {
        if (logger != null) {
          await logger.logError(e.toString(), 'retrieving comment for script: $scriptName');
        }
        
        // Add script with default description if comment retrieval fails
        final levelMatch = RegExp(r'^mkt(\d+)_').firstMatch(scriptName);
        final scriptLevel = levelMatch != null ? int.parse(levelMatch.group(1)!) : 1;
        
        final scriptInfo = ScriptInfo(
          name: scriptName,
          description: 'Error retrieving description: $e',
          level: scriptLevel,
        );
        
        scripts.add(scriptInfo);
      }
    }
    
    return scripts;
  }

  /// Saves script cache to JSON file
  static Future<void> saveScriptCache(String routerName, List<ScriptInfo> scripts) async {
    try {
      final fileName = 'scripts_${routerName.replaceAll(' ', '_')}.json';
      final file = File(fileName);
      
      final jsonList = scripts.map((script) => script.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      await file.writeAsString(jsonString);
    } catch (e) {
      throw Exception('Failed to save script cache: $e');
    }
  }

  /// Loads script cache from JSON file
  static Future<List<ScriptInfo>> loadScriptCache(String routerName) async {
    try {
      final fileName = 'scripts_${routerName.replaceAll(' ', '_')}.json';
      final file = File(fileName);
      
      if (!await file.exists()) {
        return [];
      }
      
      final jsonString = await file.readAsString();
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      
      return jsonList.map((json) => ScriptInfo.fromJson(json)).toList();
    } catch (e) {
      return []; // Return empty list if loading fails
    }
  }
}