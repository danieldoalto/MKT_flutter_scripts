import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'widgets/connection_panel.dart';
import 'widgets/script_execution_panel.dart';
import 'widgets/actions_panel.dart';
import 'widgets/output_panel.dart';
import 'widgets/status_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'MikroTik SSH Script Runner',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.blueGrey.shade900,
          scaffoldBackgroundColor: Colors.grey.shade800,
          cardColor: Colors.blueGrey.shade900,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white70),
            titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.white70),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MikroTik SSH Script Runner'),
      ),
      body: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ConnectionPanel(),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ScriptExecutionPanel(),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ActionsPanel(),
                SizedBox(height: 8),
                Expanded(
                  flex: 3,
                  child: OutputPanel(),
                ),
              ],
            ),
          ),
          if (appState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const StatusBar(),
    );
  }
}
