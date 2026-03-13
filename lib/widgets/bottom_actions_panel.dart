import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class BottomActionsPanel extends StatelessWidget {
  const BottomActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Connect Button
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton.icon(
                onPressed: !appState.isConnected && 
                           appState.selectedRouter != null && 
                           !appState.isLoading
                    ? appState.connect
                    : null,
                icon: const Icon(Icons.wifi, size: 16),
                label: const Text('Connect', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  backgroundColor: Colors.green.shade700,
                ),
              ),
            ),
          ),
          
          // Update Scripts Button (visible only when connected)
          if (appState.isConnected)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ElevatedButton.icon(
                  onPressed: !appState.isLoading ? appState.updateScripts : null,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Update', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    backgroundColor: Colors.blue.shade700,
                  ),
                ),
              ),
            ),
          
          // Execute Button (when connected) or Close APP Button (when disconnected)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: appState.isConnected
                  ? ElevatedButton.icon(
                      onPressed: appState.selectedMikrotikScript != null && 
                                 !appState.isLoading
                          ? appState.executeScript
                          : null,
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Execute', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        backgroundColor: Colors.orange.shade700,
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      icon: const Icon(Icons.exit_to_app, size: 16),
                      label: const Text('Close APP', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        backgroundColor: Colors.red.shade700,
                      ),
                    ),
            ),
          ),
          
          // Close/Disconnect Button
          if (appState.isConnected)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ElevatedButton.icon(
                  onPressed: appState.isConnected && !appState.isLoading
                      ? appState.disconnect
                      : null,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Close', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    backgroundColor: Colors.red.shade700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}