import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../services/dialog_service.dart';
import '../widgets/router_actions_panel.dart';
import '../widgets/output_panel.dart';
import '../widgets/ssh_log_panel.dart';
import '../widgets/bottom_actions_panel.dart';
import '../widgets/config_editor_panel.dart';
import '../widgets/theme_selector.dart';
import '../version.dart';
import 'layout_manager.dart';

/// Layout otimizado para Android com navegação minimalista e densidade de informação
/// 
/// Características:
/// - Navegação por bottom navigation (mais acessível no mobile)
/// - Densidade de informação maximizada
/// - Títulos reduzidos, foco nos dados
/// - Interface touch-friendly
class MobileLayout extends StatefulWidget {
  const MobileLayout({super.key});

  @override
  State<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout> {
  int _currentIndex = 0;

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
      applicationName: 'MikroTik SSH Runner',
      applicationVersion: AppVersion.version,
      applicationLegalese: '© 2025 MikroTik SSH Runner',
      children: [
        Text('v${AppVersion.version}', style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        const Text(
          'SSH script execution for MikroTik routers with optimized mobile interface.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      // AppBar minimalista - apenas essencial
      appBar: AppBar(
        title: Text(
          'MikroTik SSH',
          style: TextStyle(
            fontSize: LayoutManager.getPlatformFontSize(mobile: 16.0, desktop: 18.0),
          ),
        ),
        actions: [
          const CompactThemeSelector(),
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            onPressed: () => _showAboutDialog(context),
            tooltip: 'About',
          ),
        ],
        elevation: 1,
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              // Aba 1: Controle do Router (layout vertical para mobile)
              Padding(
                padding: LayoutManager.getPlatformPadding(),
                child: Column(
                  children: [
                    // ROUTER Actions - painel consolidado para melhor uso do espaço
                    const RouterActionsPanel(),
                    const SizedBox(height: 6),
                    // Output ocupa o espaço restante
                    const Expanded(
                      child: OutputPanel(),
                    ),
                    // Botões de ação apenas na tela de controle
                    const BottomActionsPanel(),
                  ],
                ),
              ),
              // Aba 2: SSH Logs
              Padding(
                padding: LayoutManager.getPlatformPadding(),
                child: const SSHLogPanel(),
              ),
              // Aba 3: Settings
              Padding(
                padding: LayoutManager.getPlatformPadding(),
                child: ConfigEditorPanel(),
              ),
            ],
          ),
          // Loading overlay
          if (appState.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      // Bottom Navigation - mais acessível no mobile que tabs no topo
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status bar compacto
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Consumer<AppState>(
              builder: (context, appState, child) {
                return Row(
                  children: [
                    // Status de conexão
                    Icon(
                      appState.isConnected ? Icons.wifi : Icons.wifi_off,
                      size: 12,
                      color: appState.isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        appState.statusMessage.isNotEmpty 
                            ? appState.statusMessage 
                            : (appState.isConnected ? 'Connected' : 'Disconnected'),
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Indicador de loading compacto
                    if (appState.isLoading)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 1),
                      ),
                  ],
                );
              },
            ),
          ),
          // Navigation bar
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 10,
            unselectedFontSize: 9,
            iconSize: 20,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.router),
                label: 'Control',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.terminal),
                label: 'Logs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}