import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Text('Status: ${appState.statusMessage}'),
          const Spacer(),
          Text('Routers: ${appState.routers.length}'),
        ],
      ),
    );
  }
}
