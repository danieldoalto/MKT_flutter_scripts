import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/theme_config.dart';
import '../services/theme_service.dart';

/// Widget para seleção de temas
class ThemeSelector extends StatefulWidget {
  final bool showCustomThemes;
  final VoidCallback? onThemeChanged;

  const ThemeSelector({
    Key? key,
    this.showCustomThemes = true,
    this.onThemeChanged,
  }) : super(key: key);

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
  String _selectedCategory = 'predefined';

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        if (themeService.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryTabs(context),
            const SizedBox(height: 16),
            _buildThemeGrid(context, themeService),
          ],
        );
      },
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          _buildCategoryTab(
            context,
            'predefined',
            'Predefinidos',
            Icons.palette,
          ),
          if (widget.showCustomThemes)
            _buildCategoryTab(
              context,
              'custom',
              'Personalizados',
              Icons.brush,
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(
    BuildContext context,
    String category,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedCategory == category;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeGrid(BuildContext context, ThemeService themeService) {
    List<ThemeConfig> themes;
    
    switch (_selectedCategory) {
      case 'custom':
        themes = themeService.customThemes;
        break;
      case 'predefined':
      default:
        themes = PredefinedThemes.allThemes;
        break;
    }

    if (themes.isEmpty) {
      return _buildEmptyState(context);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        return _buildThemeCard(context, theme, themeService);
      },
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    ThemeConfig theme,
    ThemeService themeService,
  ) {
    final isSelected = themeService.currentTheme.id == theme.id;
    final themeData = theme.toThemeData();

    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () async {
          await themeService.setTheme(theme);
          widget.onThemeChanged?.call();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview das cores
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        themeData.colorScheme.primary,
                        themeData.colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Padrão de cores
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildColorDot(themeData.colorScheme.surface),
                            const SizedBox(width: 4),
                            _buildColorDot(themeData.colorScheme.background),
                          ],
                        ),
                      ),
                      // Ícone de seleção
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: themeData.colorScheme.onPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: themeData.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Nome do tema
              Text(
                theme.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Descrição
              Text(
                theme.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Badge para temas customizados
              if (theme.isCustom)
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedCategory == 'custom' ? Icons.brush_outlined : Icons.palette_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedCategory == 'custom'
                ? 'Nenhum tema personalizado'
                : 'Nenhum tema disponível',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedCategory == 'custom'
                ? 'Crie seu primeiro tema personalizado'
                : 'Verifique a configuração dos temas',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget compacto para seleção rápida de tema
class CompactThemeSelector extends StatelessWidget {
  final VoidCallback? onThemeChanged;

  const CompactThemeSelector({
    Key? key,
    this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return PopupMenuButton<ThemeConfig>(
          icon: Icon(
            Icons.palette,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: 'Selecionar tema',
          onSelected: (theme) async {
            await themeService.setTheme(theme);
            onThemeChanged?.call();
          },
          itemBuilder: (context) {
            return themeService.allThemes.map((theme) {
              final isSelected = themeService.currentTheme.id == theme.id;
              
              return PopupMenuItem<ThemeConfig>(
                value: theme,
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        theme.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }
}