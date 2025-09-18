import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/script.dart';

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
            Text('Select Script', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButton<Script>(
              isExpanded: true,
              value: appState.selectedScript,
              hint: const Text('Select a script'),
              onChanged: (script) => appState.selectScript(script),
              items: appState.scripts.map<DropdownMenuItem<Script>>((Script script) {
                return DropdownMenuItem<Script>(
                  value: script,
                  child: Text(script.name),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
