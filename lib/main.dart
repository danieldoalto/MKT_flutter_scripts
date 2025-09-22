import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'services/dialog_service.dart';
import 'services/theme_service.dart';
import 'widgets/connection_panel.dart';
import 'widgets/script_execution_panel.dart';
import 'widgets/actions_panel.dart';
import 'widgets/output_panel.dart';
import 'widgets/status_bar.dart';
import 'widgets/ssh_log_panel.dart';
import 'widgets/config_editor_panel.dart';
import 'widgets/theme_selector.dart';
import 'version.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o serviço de temas
  final themeService = ThemeService();
  await themeService.initialize();
  
  runApp(MyApp(themeService: themeService));
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;
  
  const MyApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider.value(value: themeService),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'MikroTik SSH Script Runner v${AppVersion.version}',
            theme: themeService.currentTheme.toThemeData(),
            home: const MyHomePage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // Set up error callback for app state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.setErrorCallback((title, message) {
        DialogService.showErrorDialog(context, title, message);
      });
    });
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MikroTik SSH Script Runner',
      applicationVersion: AppVersion.fullVersion,
      applicationLegalese: '© 2025 MikroTik SSH Script Runner\n${AppVersion.buildInfo}',
      children: [
        const SizedBox(height: 16),
        Text('Code Name: ${AppVersion.codeName}'),
        const SizedBox(height: 8),
        const Text(
          'A Flutter desktop application for executing scripts on MikroTik routers via SSH with optimized performance and comprehensive logging.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:\n'
          '• 90% faster script discovery\n'
          '• Configurable command templates\n'
          '• Comprehensive SSH logging\n'
          '• Flexible password handling\n'
          '• User level access control',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppVersion.versionString),
        actions: [
          const CompactThemeSelector(),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
            tooltip: 'About',
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.router), text: 'Router Control'),
                Tab(icon: Icon(Icons.terminal), text: 'SSH Logs'),
                Tab(icon: Icon(Icons.settings), text: 'Settings'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Main router control tab
                  Stack(
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
                          color: Colors.black.withValues(alpha: 0.5),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                  // SSH logs tab
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SSHLogPanel(),
                  ),
                  // Settings tab
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ConfigEditorPanel(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const StatusBar(),
    );
  }
}
