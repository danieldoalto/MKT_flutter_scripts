import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class ActionsPanel extends StatelessWidget {
  const ActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: appState.selectedScript != null && appState.status == AppStatus.connected
                ? appState.executeScript
                : null,
            child: const Text('Run Script'),
          ),
        ],
      ),
    );
  }
}
