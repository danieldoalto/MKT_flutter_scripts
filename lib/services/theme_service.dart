import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../models/theme_config.dart';

/// Serviço para gerenciar temas personalizados
class ThemeService extends ChangeNotifier {
  static const String _themeConfigFile = 'theme_config.json';
  
  ThemeConfig _currentTheme = PredefinedThemes.darkTheme;
  List<ThemeConfig> _customThemes = [];
  bool _isLoading = false;

  /// Tema atual
  ThemeConfig get currentTheme => _currentTheme;

  /// Lista de temas customizados
  List<ThemeConfig> get customThemes => List.unmodifiable(_customThemes);

  /// Lista de todos os temas (predefinidos + customizados)
  List<ThemeConfig> get allThemes => [
    ...PredefinedThemes.allThemes,
    ..._customThemes,
  ];

  /// Indica se está carregando
  bool get isLoading => _isLoading;

  /// Inicializa o serviço de temas
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadThemeConfig();
      await _loadCustomThemes();
    } catch (e) {
      debugPrint('Erro ao inicializar ThemeService: $e');
      // Em caso de erro, usa o tema padrão
      _currentTheme = PredefinedThemes.darkTheme;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Altera o tema atual
  Future<void> setTheme(ThemeConfig theme) async {
    if (_currentTheme.id == theme.id) return;

    _currentTheme = theme;
    notifyListeners();

    await _saveThemeConfig();
  }

  /// Adiciona um tema customizado
  Future<void> addCustomTheme(ThemeConfig theme) async {
    if (_customThemes.any((t) => t.id == theme.id)) {
      throw Exception('Tema com ID "${theme.id}" já existe');
    }

    _customThemes.add(theme.copyWith(isCustom: true));
    notifyListeners();

    await _saveCustomThemes();
  }

  /// Remove um tema customizado
  Future<void> removeCustomTheme(String themeId) async {
    _customThemes.removeWhere((theme) => theme.id == themeId);
    
    // Se o tema removido era o atual, volta para o tema padrão
    if (_currentTheme.id == themeId) {
      _currentTheme = PredefinedThemes.darkTheme;
    }
    
    notifyListeners();
    await _saveCustomThemes();
    await _saveThemeConfig();
  }

  /// Atualiza um tema customizado
  Future<void> updateCustomTheme(ThemeConfig updatedTheme) async {
    final index = _customThemes.indexWhere((t) => t.id == updatedTheme.id);
    if (index == -1) {
      throw Exception('Tema não encontrado');
    }

    _customThemes[index] = updatedTheme.copyWith(isCustom: true);
    
    // Se o tema atualizado é o atual, atualiza também
    if (_currentTheme.id == updatedTheme.id) {
      _currentTheme = updatedTheme;
    }
    
    notifyListeners();
    await _saveCustomThemes();
  }

  /// Busca um tema pelo ID
  ThemeConfig? getThemeById(String id) {
    return allThemes.cast<ThemeConfig?>().firstWhere(
      (theme) => theme?.id == id,
      orElse: () => null,
    );
  }

  /// Cria um tema customizado baseado em outro tema
  ThemeConfig createCustomTheme({
    required String id,
    required String name,
    required String description,
    required ThemeConfig baseTheme,
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    String? fontFamily,
    double? fontSize,
  }) {
    ColorScheme colorScheme = baseTheme.colorScheme;
    
    if (primaryColor != null || secondaryColor != null || backgroundColor != null || surfaceColor != null) {
      colorScheme = baseTheme.colorScheme.copyWith(
        primary: primaryColor ?? baseTheme.colorScheme.primary,
        secondary: secondaryColor ?? baseTheme.colorScheme.secondary,
        background: backgroundColor ?? baseTheme.colorScheme.background,
        surface: surfaceColor ?? baseTheme.colorScheme.surface,
      );
    }

    TextTheme textTheme = baseTheme.textTheme;
    if (fontFamily != null || fontSize != null) {
      textTheme = baseTheme.textTheme.copyWith(
        bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize,
        ),
        titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
          fontFamily: fontFamily,
        ),
        // Aplica para outros estilos também
      );
    }

    return baseTheme.copyWith(
      id: id,
      name: name,
      description: description,
      colorScheme: colorScheme,
      textTheme: textTheme,
      isCustom: true,
    );
  }

  /// Exporta configurações de tema
  Map<String, dynamic> exportThemeConfig() {
    return {
      'currentTheme': _currentTheme.id,
      'customThemes': _customThemes.map((theme) => theme.toMap()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Importa configurações de tema
  Future<void> importThemeConfig(Map<String, dynamic> config) async {
    try {
      // Importa temas customizados
      if (config['customThemes'] != null) {
        final List<dynamic> themesData = config['customThemes'];
        _customThemes = themesData
            .map((data) => ThemeConfig.fromMap(Map<String, dynamic>.from(data)))
            .toList();
      }

      // Define tema atual
      if (config['currentTheme'] != null) {
        final themeId = config['currentTheme'] as String;
        final theme = getThemeById(themeId);
        if (theme != null) {
          _currentTheme = theme;
        }
      }

      notifyListeners();
      await _saveThemeConfig();
      await _saveCustomThemes();
    } catch (e) {
      throw Exception('Erro ao importar configuração de tema: $e');
    }
  }

  /// Carrega configuração do tema atual
  Future<void> _loadThemeConfig() async {
    try {
      final file = File(_themeConfigFile);
      if (!await file.exists()) return;

      final content = await file.readAsString();
      final config = jsonDecode(content) as Map<String, dynamic>;
      
      final themeId = config['currentTheme'] as String?;
      if (themeId != null) {
        final theme = PredefinedThemes.allThemes
            .cast<ThemeConfig?>()
            .firstWhere((t) => t?.id == themeId, orElse: () => null);
        
        if (theme != null) {
          _currentTheme = theme;
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar configuração de tema: $e');
    }
  }

  /// Salva configuração do tema atual
  Future<void> _saveThemeConfig() async {
    try {
      final config = {
        'currentTheme': _currentTheme.id,
        'savedAt': DateTime.now().toIso8601String(),
      };

      final file = File(_themeConfigFile);
      await file.writeAsString(jsonEncode(config));
    } catch (e) {
      debugPrint('Erro ao salvar configuração de tema: $e');
    }
  }

  /// Carrega temas customizados
  Future<void> _loadCustomThemes() async {
    try {
      final file = File('custom_themes.json');
      if (!await file.exists()) return;

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      
      if (data['themes'] != null) {
        final List<dynamic> themesData = data['themes'];
        _customThemes = themesData
            .map((themeData) => ThemeConfig.fromMap(Map<String, dynamic>.from(themeData)))
            .toList();
      }
    } catch (e) {
      debugPrint('Erro ao carregar temas customizados: $e');
    }
  }

  /// Salva temas customizados
  Future<void> _saveCustomThemes() async {
    try {
      final data = {
        'themes': _customThemes.map((theme) => theme.toMap()).toList(),
        'savedAt': DateTime.now().toIso8601String(),
      };

      final file = File('custom_themes.json');
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Erro ao salvar temas customizados: $e');
    }
  }

  /// Reseta para configurações padrão
  Future<void> resetToDefault() async {
    _currentTheme = PredefinedThemes.darkTheme;
    _customThemes.clear();
    
    notifyListeners();
    
    await _saveThemeConfig();
    await _saveCustomThemes();
  }

  /// Valida se um tema é válido
  bool validateTheme(ThemeConfig theme) {
    try {
      // Tenta criar o ThemeData para validar
      theme.toThemeData();
      return true;
    } catch (e) {
      debugPrint('Tema inválido: $e');
      return false;
    }
  }
}