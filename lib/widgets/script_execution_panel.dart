import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/script_info.dart';

class ScriptExecutionPanel extends StatelessWidget {
  const ScriptExecutionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MikroTik Scripts', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButton<ScriptInfo>(
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
            const SizedBox(height: 16),
            Text('Description:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                appState.selectedMikrotikScript?.description ?? 'No script selected',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
