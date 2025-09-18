import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/router_config.dart';

class ConnectionPanel extends StatelessWidget {
  const ConnectionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Router', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButton<RouterConfig>(
              isExpanded: true,
              value: appState.selectedRouter,
              hint: const Text('Select a router'),
              onChanged: (router) => appState.selectRouter(router),
              items: appState.routers.map<DropdownMenuItem<RouterConfig>>((RouterConfig router) {
                return DropdownMenuItem<RouterConfig>(
                  value: router,
                  child: Text(router.name),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
