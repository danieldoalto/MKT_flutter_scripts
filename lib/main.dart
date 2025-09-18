import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:xterm/xterm.dart';

import 'app_state.dart';
import 'widgets/actions_panel.dart';
import 'widgets/connection_panel.dart';
import 'widgets/output_panel.dart';
import 'widgets/script_execution_panel.dart';
import 'widgets/status_bar.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MikrotikScriptRunner(),
    ),
  );
}

class MikrotikScriptRunner extends StatelessWidget {
  const MikrotikScriptRunner({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'MikroTik SSH Script Runner',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
          titleLarge: GoogleFonts.oswald(textStyle: textTheme.titleLarge),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MikroTik SSH Script Runner'),
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(child: ConnectionPanel()),
                SizedBox(width: 8),
                Expanded(child: ScriptExecutionPanel()),
              ],
            ),
          ),
          const ActionsPanel(),
          const Divider(height: 1, indent: 8, endIndent: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Consumer<AppState>(
                          builder: (context, appState, _) => TerminalView(appState.terminal),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Consumer<AppState>(
                      builder: (context, appState, _) => OutputPanel(
                        title: 'Information Log',
                        content: appState.informationLog,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const StatusBar(),
    );
  }
}
