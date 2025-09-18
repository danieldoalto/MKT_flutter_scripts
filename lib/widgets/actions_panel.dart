import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class ActionsPanel extends StatelessWidget {
  const ActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Connect Button
            ElevatedButton(
              onPressed: !appState.isConnected && appState.selectedRouter != null && !appState.isLoading
                  ? appState.connect
                  : null,
              child: const Text('Connect'),
            ),
            
            // Update Scripts Button (visible only when connected)
            if (appState.isConnected)
              ElevatedButton(
                onPressed: !appState.isLoading ? appState.updateScripts : null,
                child: const Text('Update Scripts'),
              ),
            
            // Execute Button
            ElevatedButton(
              onPressed: appState.isConnected && 
                         appState.selectedMikrotikScript != null && 
                         !appState.isLoading
                  ? appState.executeScript
                  : null,
              child: const Text('Execute'),
            ),
            
            // Close/Disconnect Button
            ElevatedButton(
              onPressed: appState.isConnected && !appState.isLoading
                  ? appState.disconnect
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
