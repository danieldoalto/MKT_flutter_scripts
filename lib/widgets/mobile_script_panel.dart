import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/script_info.dart';
import '../layouts/layout_manager.dart';

/// Painel de scripts otimizado para mobile
/// 
/// Características:
/// - Botões maiores para toque
/// - Layout vertical compacto
/// - Densidade de informação maximizada
/// - Títulos reduzidos
class MobileScriptPanel extends StatelessWidget {
  const MobileScriptPanel({super.key});

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
            // Título compacto com contador
            Row(
              children: [
                Icon(
                  Icons.code,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Scripts',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: LayoutManager.getPlatformFontSize(mobile: 12.0, desktop: 14.0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Contador de scripts
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${appState.mikrotikScripts.length}',
                    style: TextStyle(
                      fontSize: LayoutManager.getPlatformFontSize(mobile: 10.0, desktop: 12.0),
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
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
                child: DropdownButton<ScriptInfo>(
                  isExpanded: true,
                  value: appState.selectedMikrotikScript,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      appState.mikrotikScripts.isEmpty 
                          ? 'Connect first'
                          : 'Select script',
                      style: TextStyle(
                        fontSize: LayoutManager.getPlatformFontSize(mobile: 12.0, desktop: 14.0),
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                  onChanged: appState.mikrotikScripts.isEmpty 
                      ? null 
                      : (script) => appState.selectMikrotikScript(script),
                  selectedItemBuilder: (BuildContext context) {
                    return appState.mikrotikScripts.map<Widget>((ScriptInfo script) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            script.name,
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
                  items: appState.mikrotikScripts.map<DropdownMenuItem<ScriptInfo>>((ScriptInfo script) {
                    return DropdownMenuItem<ScriptInfo>(
                      value: script,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    script.name,
                                    style: TextStyle(
                                      fontSize: LayoutManager.getPlatformFontSize(mobile: 12.0, desktop: 14.0),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Level badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: _getLevelColor(script.level),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'L${script.level}',
                                    style: TextStyle(
                                      fontSize: LayoutManager.getPlatformFontSize(mobile: 9.0, desktop: 10.0),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (script.description.isNotEmpty)
                              Text(
                                script.description,
                                style: TextStyle(
                                  fontSize: LayoutManager.getPlatformFontSize(mobile: 10.0, desktop: 12.0),
                                  color: Theme.of(context).hintColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            // Descrição do script selecionado (densidade de informação)
            if (appState.selectedMikrotikScript != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getLevelColor(appState.selectedMikrotikScript!.level),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Level ${appState.selectedMikrotikScript!.level}',
                            style: TextStyle(
                              fontSize: LayoutManager.getPlatformFontSize(mobile: 10.0, desktop: 12.0),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Theme.of(context).hintColor,
                        ),
                      ],
                    ),
                    if (appState.selectedMikrotikScript!.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        appState.selectedMikrotikScript!.description,
                        style: TextStyle(
                          fontSize: LayoutManager.getPlatformFontSize(mobile: 11.0, desktop: 13.0),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Retorna a cor apropriada para o nível do script
  Color _getLevelColor(int level) {
    switch (level) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}