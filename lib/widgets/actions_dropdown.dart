import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class ActionsDropdown extends StatefulWidget {
  const ActionsDropdown({super.key});

  @override
  State<ActionsDropdown> createState() => _ActionsDropdownState();
}

class _ActionsDropdownState extends State<ActionsDropdown> {
  String? _selectedAction;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Lista de ações disponíveis baseada no estado atual
    List<DropdownMenuItem<String>> getAvailableActions() {
      List<DropdownMenuItem<String>> actions = [];

      // Connect - disponível quando não conectado
      if (!appState.isConnected && appState.selectedRouter != null && !appState.isLoading) {
        actions.add(const DropdownMenuItem(
          value: 'connect',
          child: Row(
            children: [
              Icon(Icons.wifi, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Text('Connect'),
            ],
          ),
        ));
      }

      // Update Scripts - disponível quando conectado
      if (appState.isConnected && !appState.isLoading) {
        actions.add(const DropdownMenuItem(
          value: 'update_scripts',
          child: Row(
            children: [
              Icon(Icons.refresh, size: 16, color: Colors.blue),
              SizedBox(width: 8),
              Text('Update Scripts'),
            ],
          ),
        ));
      }

      // Execute - disponível quando conectado e script selecionado
      if (appState.isConnected && 
          appState.selectedMikrotikScript != null && 
          !appState.isLoading) {
        actions.add(const DropdownMenuItem(
          value: 'execute',
          child: Row(
            children: [
              Icon(Icons.play_arrow, size: 16, color: Colors.orange),
              SizedBox(width: 8),
              Text('Execute'),
            ],
          ),
        ));
      }

      // Disconnect - disponível quando conectado
      if (appState.isConnected && !appState.isLoading) {
        actions.add(const DropdownMenuItem(
          value: 'disconnect',
          child: Row(
            children: [
              Icon(Icons.close, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('Disconnect'),
            ],
          ),
        ));
      }

      return actions;
    }

    void _executeAction(String? action) {
      if (action == null) return;

      switch (action) {
        case 'connect':
          appState.connect();
          break;
        case 'update_scripts':
          appState.updateScripts();
          break;
        case 'execute':
          appState.executeScript();
          break;
        case 'disconnect':
          appState.disconnect();
          break;
      }

      // Reset selection after action
      setState(() {
        _selectedAction = null;
      });
    }

    final availableActions = getAvailableActions();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(Icons.settings, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<String>(
                value: _selectedAction,
                hint: Text(
                  availableActions.isEmpty 
                      ? 'No actions available' 
                      : 'Select action...',
                  style: TextStyle(
                    color: availableActions.isEmpty 
                        ? Colors.grey 
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                isExpanded: true,
                isDense: true,
                underline: Container(),
                items: availableActions,
                onChanged: availableActions.isEmpty ? null : _executeAction,
              ),
            ),
            if (appState.isLoading)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}