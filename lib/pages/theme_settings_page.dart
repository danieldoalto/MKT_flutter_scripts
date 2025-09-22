import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';

import '../models/theme_config.dart';
import '../services/theme_service.dart';
import '../widgets/theme_selector.dart';
import '../widgets/theme_editor.dart';

/// Página de configurações de temas
class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({Key? key}) : super(key: key);

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Tema'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'create',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Criar Tema'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_upload),
                    SizedBox(width: 8),
                    Text('Importar Temas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Exportar Temas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restore),
                    SizedBox(width: 8),
                    Text('Restaurar Padrão'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          if (themeService.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentThemeSection(context, themeService),
                const SizedBox(height: 32),
                _buildThemeSelectorSection(context),
                const SizedBox(height: 32),
                _buildCustomThemesSection(context, themeService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentThemeSection(BuildContext context, ThemeService themeService) {
    final currentTheme = themeService.currentTheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tema Atual',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        currentTheme.colorScheme.primary,
                        currentTheme.colorScheme.secondary,
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTheme.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        currentTheme.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      if (currentTheme.isCustom)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Personalizado',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (currentTheme.isCustom)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editTheme(currentTheme),
                    tooltip: 'Editar tema',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelectorSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.color_lens,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Selecionar Tema',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const ThemeSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomThemesSection(BuildContext context, ThemeService themeService) {
    final customThemes = themeService.customThemes;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.brush,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Temas Personalizados',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _createTheme(),
                  icon: const Icon(Icons.add),
                  label: const Text('Criar Tema'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (customThemes.isEmpty)
              _buildEmptyCustomThemes(context)
            else
              _buildCustomThemesList(context, customThemes, themeService),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCustomThemes(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.brush_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum tema personalizado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie seu primeiro tema personalizado para deixar a aplicação com sua cara',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _createTheme(),
            icon: const Icon(Icons.add),
            label: const Text('Criar Primeiro Tema'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomThemesList(
    BuildContext context,
    List<ThemeConfig> themes,
    ThemeService themeService,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: themes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isSelected = themeService.currentTheme.id == theme.id;
        
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
          ),
          title: Text(theme.name),
          subtitle: Text(theme.description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Ativo',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (action) => _handleThemeAction(action, theme, themeService),
                itemBuilder: (context) => [
                  if (!isSelected)
                    const PopupMenuItem(
                      value: 'apply',
                      child: Row(
                        children: [
                          Icon(Icons.check),
                          SizedBox(width: 8),
                          Text('Aplicar'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy),
                        SizedBox(width: 8),
                        Text('Duplicar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Excluir', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: isSelected ? null : () => themeService.setTheme(theme),
        );
      },
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'create':
        _createTheme();
        break;
      case 'import':
        _importThemes();
        break;
      case 'export':
        _exportThemes();
        break;
      case 'reset':
        _resetToDefault();
        break;
    }
  }

  void _handleThemeAction(String action, ThemeConfig theme, ThemeService themeService) {
    switch (action) {
      case 'apply':
        themeService.setTheme(theme);
        break;
      case 'edit':
        _editTheme(theme);
        break;
      case 'duplicate':
        _duplicateTheme(theme);
        break;
      case 'delete':
        _deleteTheme(theme, themeService);
        break;
    }
  }

  void _createTheme() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThemeEditor(
          onSaved: () => Navigator.of(context).pop(),
          onCancelled: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _editTheme(ThemeConfig theme) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThemeEditor(
          initialTheme: theme,
          onSaved: () => Navigator.of(context).pop(),
          onCancelled: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _duplicateTheme(ThemeConfig theme) {
    final duplicatedTheme = theme.copyWith(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: '${theme.name} (Cópia)',
    );
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThemeEditor(
          initialTheme: duplicatedTheme,
          onSaved: () => Navigator.of(context).pop(),
          onCancelled: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _deleteTheme(ThemeConfig theme, ThemeService themeService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Tema'),
        content: Text('Tem certeza que deseja excluir o tema "${theme.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              themeService.removeCustomTheme(theme.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tema excluído')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _importThemes() {
    // TODO: Implementar importação de temas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _exportThemes() {
    // TODO: Implementar exportação de temas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _resetToDefault() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Padrão'),
        content: const Text(
          'Tem certeza que deseja restaurar as configurações de tema para o padrão? '
          'Todos os temas personalizados serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final themeService = Provider.of<ThemeService>(context, listen: false);
              themeService.resetToDefault();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configurações restauradas')),
              );
            },
            child: const Text('Restaurar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}