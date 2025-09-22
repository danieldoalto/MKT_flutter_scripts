import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class OutputPanel extends StatefulWidget {
  const OutputPanel({super.key});

  @override
  State<OutputPanel> createState() => _OutputPanelState();
}

class _OutputPanelState extends State<OutputPanel> {
  String _selectedView = 'Command Results'; // Default view

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown para alternar entre as views
            Row(
              children: [
                Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedView,
                  isDense: true,
                  underline: Container(),
                  style: Theme.of(context).textTheme.titleMedium,
                  items: const [
                    DropdownMenuItem(
                      value: 'Command Results',
                      child: Text('Command Results'),
                    ),
                    DropdownMenuItem(
                      value: 'Information Log',
                      child: Text('Information Log'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedView = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Área de conteúdo que alterna baseado na seleção
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                  color: Colors.black12,
                ),
                child: SingleChildScrollView(
                  child: _selectedView == 'Command Results'
                      ? Text(
                          appState.output.isEmpty ? 'No output yet...' : appState.output,
                          style: const TextStyle(fontFamily: 'monospace'),
                        )
                      : Text(
                          appState.infoLog.isEmpty ? 'Application started...' : appState.infoLog,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
