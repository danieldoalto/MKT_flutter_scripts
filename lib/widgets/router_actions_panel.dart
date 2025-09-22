import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/router_config.dart' as router_models;
import '../models/script_info.dart';

class RouterActionsPanel extends StatelessWidget {
  const RouterActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título consolidado com fonte menor
            Text(
              'ROUTER Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Seção Router
            Row(
              children: [
                Text(
                  'Router:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<router_models.RouterConfig>(
                    isExpanded: true,
                    value: appState.selectedRouter,
                    hint: const Text('Select a router'),
                    onChanged: (router) => appState.selectRouter(router),
                    items: appState.routers.map<DropdownMenuItem<router_models.RouterConfig>>((router_models.RouterConfig router) {
                      return DropdownMenuItem<router_models.RouterConfig>(
                        value: router,
                        child: Text(router.name),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Seção MKT Scripts
            Row(
              children: [
                Text(
                  'MKT Scripts:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<ScriptInfo>(
                    isExpanded: true,
                    value: appState.selectedMikrotikScript,
                    hint: Text(appState.mikrotikScripts.isEmpty 
                        ? 'No scripts available - Connect and update scripts first'
                        : 'Select a script'),
                    onChanged: (script) => appState.selectMikrotikScript(script),
                    items: appState.mikrotikScripts.map<DropdownMenuItem<ScriptInfo>>((ScriptInfo script) {
                      return DropdownMenuItem<ScriptInfo>(
                        value: script,
                        child: Text('${script.name} (Level ${script.level})'),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Seção Description
            Text(
              'Description:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                appState.selectedMikrotikScript?.description ?? 'No script selected',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 13.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}