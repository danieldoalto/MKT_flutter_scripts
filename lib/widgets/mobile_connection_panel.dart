import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/router_config.dart' as router_models;
import '../layouts/layout_manager.dart';

/// Painel de conexão otimizado para mobile
/// 
/// Características:
/// - Interface touch-friendly
/// - Densidade de informação maximizada
/// - Títulos reduzidos
/// - Botões maiores para toque
class MobileConnectionPanel extends StatelessWidget {
  const MobileConnectionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Card(
      margin: const EdgeInsets.all(4.0),
      child: Padding(
        padding: LayoutManager.getPlatformPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título compacto
            Row(
              children: [
                Icon(
                  Icons.router,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Router',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: LayoutManager.getPlatformFontSize(mobile: 12.0, desktop: 14.0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Status de conexão visual
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appState.isConnected ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Dropdown com altura otimizada para touch
            Container(
              height: LayoutManager.getPlatformButtonHeight(),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<router_models.RouterConfig>(
                  isExpanded: true,
                  value: appState.selectedRouter,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Select router',
                      style: TextStyle(
                        fontSize: LayoutManager.getPlatformFontSize(mobile: 12.0, desktop: 14.0),
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                  onChanged: (router) => appState.selectRouter(router),
                  selectedItemBuilder: (BuildContext context) {
                    return appState.routers.map<Widget>((router_models.RouterConfig router) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            router.name,
                            style: TextStyle(
                              fontSize: LayoutManager.getPlatformFontSize(mobile: 12.0, desktop: 14.0),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  items: appState.routers.map<DropdownMenuItem<router_models.RouterConfig>>((router_models.RouterConfig router) {
                    return DropdownMenuItem<router_models.RouterConfig>(
                      value: router,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              router.name,
                              style: TextStyle(
                                fontSize: LayoutManager.getPlatformFontSize(mobile: 12.0, desktop: 14.0),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (router.host.isNotEmpty)
                              Text(
                                router.host,
                                style: TextStyle(
                                  fontSize: LayoutManager.getPlatformFontSize(mobile: 10.0, desktop: 12.0),
                                  color: Theme.of(context).hintColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            // Informações do router selecionado (densidade de informação)
            if (appState.selectedRouter != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.selectedRouter!.host,
                            style: TextStyle(
                              fontSize: LayoutManager.getPlatformFontSize(mobile: 11.0, desktop: 13.0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (appState.selectedRouter!.port != 22)
                            Text(
                              'Port: ${appState.selectedRouter!.port}',
                              style: TextStyle(
                                fontSize: LayoutManager.getPlatformFontSize(mobile: 10.0, desktop: 12.0),
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      appState.isConnected ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 16,
                      color: appState.isConnected ? Colors.green : Theme.of(context).hintColor,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}