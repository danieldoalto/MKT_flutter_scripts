import 'package:flutter/material.dart';

/// Configuração de tema personalizado
class ThemeConfig {
  final String id;
  final String name;
  final String description;
  final ThemeType type;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppBarTheme appBarTheme;
  final CardThemeData cardTheme;
  final ElevatedButtonThemeData elevatedButtonTheme;
  final OutlinedButtonThemeData outlinedButtonTheme;
  final InputDecorationTheme inputDecorationTheme;
  final IconThemeData iconTheme;
  final DividerThemeData dividerTheme;
  final bool isCustom;

  const ThemeConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.colorScheme,
    required this.textTheme,
    required this.appBarTheme,
    required this.cardTheme,
    required this.elevatedButtonTheme,
    required this.outlinedButtonTheme,
    required this.inputDecorationTheme,
    required this.iconTheme,
    required this.dividerTheme,
    this.isCustom = false,
  });

  /// Converte para ThemeData do Flutter
  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: appBarTheme,
      cardTheme: cardTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      inputDecorationTheme: inputDecorationTheme,
      iconTheme: iconTheme,
      dividerTheme: dividerTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkRipple.splashFactory,
    );
  }

  /// Cria uma cópia com modificações
  ThemeConfig copyWith({
    String? id,
    String? name,
    String? description,
    ThemeType? type,
    ColorScheme? colorScheme,
    TextTheme? textTheme,
    AppBarTheme? appBarTheme,
    CardThemeData? cardTheme,
    ElevatedButtonThemeData? elevatedButtonTheme,
    OutlinedButtonThemeData? outlinedButtonTheme,
    InputDecorationTheme? inputDecorationTheme,
    IconThemeData? iconTheme,
    DividerThemeData? dividerTheme,
    bool? isCustom,
  }) {
    return ThemeConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      colorScheme: colorScheme ?? this.colorScheme,
      textTheme: textTheme ?? this.textTheme,
      appBarTheme: appBarTheme ?? this.appBarTheme,
      cardTheme: cardTheme ?? this.cardTheme,
      elevatedButtonTheme: elevatedButtonTheme ?? this.elevatedButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme ?? this.outlinedButtonTheme,
      inputDecorationTheme: inputDecorationTheme ?? this.inputDecorationTheme,
      iconTheme: iconTheme ?? this.iconTheme,
      dividerTheme: dividerTheme ?? this.dividerTheme,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  /// Converte para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'isCustom': isCustom,
      // Cores principais
      'primaryColor': colorScheme.primary.value,
      'secondaryColor': colorScheme.secondary.value,
      'backgroundColor': colorScheme.surface.value,
      'errorColor': colorScheme.error.value,
      // Configurações de texto
      'fontFamily': textTheme.bodyMedium?.fontFamily,
      'fontSize': textTheme.bodyMedium?.fontSize,
    };
  }

  /// Cria ThemeConfig a partir de Map
  static ThemeConfig fromMap(Map<String, dynamic> map) {
    final type = ThemeType.values.firstWhere(
      (t) => t.name == map['type'],
      orElse: () => ThemeType.dark,
    );
    
    return _createThemeFromType(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      type: type,
      isCustom: map['isCustom'] ?? false,
      primaryColor: map['primaryColor'] != null ? Color(map['primaryColor']) : null,
      secondaryColor: map['secondaryColor'] != null ? Color(map['secondaryColor']) : null,
      backgroundColor: map['backgroundColor'] != null ? Color(map['backgroundColor']) : null,
      errorColor: map['errorColor'] != null ? Color(map['errorColor']) : null,
      fontFamily: map['fontFamily'],
      fontSize: map['fontSize']?.toDouble(),
    );
  }

  static ThemeConfig _createThemeFromType({
    required String id,
    required String name,
    required String description,
    required ThemeType type,
    bool isCustom = false,
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? errorColor,
    String? fontFamily,
    double? fontSize,
  }) {
    // Implementação será feita nos temas predefinidos
    switch (type) {
      case ThemeType.light:
        return PredefinedThemes.lightTheme.copyWith(
          id: id,
          name: name,
          description: description,
          isCustom: isCustom,
        );
      case ThemeType.dark:
        return PredefinedThemes.darkTheme.copyWith(
          id: id,
          name: name,
          description: description,
          isCustom: isCustom,
        );
      case ThemeType.mikrotik:
        return PredefinedThemes.mikrotikTheme.copyWith(
          id: id,
          name: name,
          description: description,
          isCustom: isCustom,
        );
      case ThemeType.terminal:
        return PredefinedThemes.terminalTheme.copyWith(
          id: id,
          name: name,
          description: description,
          isCustom: isCustom,
        );
    }
  }
}

/// Tipos de tema disponíveis
enum ThemeType {
  light('Light', 'Tema claro e moderno'),
  dark('Dark', 'Tema escuro elegante'),
  mikrotik('MikroTik', 'Tema inspirado no MikroTik'),
  terminal('Terminal', 'Tema estilo terminal');

  const ThemeType(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Temas predefinidos
class PredefinedThemes {
  static const String _defaultFontFamily = 'Roboto';

  /// Tema claro moderno
  static ThemeConfig get lightTheme => ThemeConfig(
    id: 'light',
    name: 'Light Modern',
    description: 'Tema claro e moderno com cores suaves',
    type: ThemeType.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3),
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: _defaultFontFamily, fontSize: 32, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontFamily: _defaultFontFamily, fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: _defaultFontFamily, fontSize: 18, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontFamily: _defaultFontFamily, fontSize: 16),
      bodyMedium: TextStyle(fontFamily: _defaultFontFamily, fontSize: 14),
      labelLarge: TextStyle(fontFamily: _defaultFontFamily, fontSize: 14, fontWeight: FontWeight.w500),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(fontFamily: _defaultFontFamily, fontSize: 20, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    iconTheme: const IconThemeData(size: 24),
    dividerTheme: const DividerThemeData(thickness: 1),
  );

  /// Tema escuro elegante
  static ThemeConfig get darkTheme => ThemeConfig(
    id: 'dark',
    name: 'Dark Elegant',
    description: 'Tema escuro elegante para uso prolongado',
    type: ThemeType.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1976D2),
      brightness: Brightness.dark,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: _defaultFontFamily, fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: TextStyle(fontFamily: _defaultFontFamily, fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: TextStyle(fontFamily: _defaultFontFamily, fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white70),
      bodyLarge: TextStyle(fontFamily: _defaultFontFamily, fontSize: 16, color: Colors.white70),
      bodyMedium: TextStyle(fontFamily: _defaultFontFamily, fontSize: 14, color: Colors.white70),
      labelLarge: TextStyle(fontFamily: _defaultFontFamily, fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 4,
      centerTitle: true,
      backgroundColor: Color(0xFF1E1E1E),
      titleTextStyle: TextStyle(fontFamily: _defaultFontFamily, fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 8,
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: const TextStyle(color: Colors.white70),
    ),
    iconTheme: const IconThemeData(size: 24, color: Colors.white70),
    dividerTheme: const DividerThemeData(thickness: 1, color: Colors.white24),
  );

  /// Tema MikroTik
  static ThemeConfig get mikrotikTheme => ThemeConfig(
    id: 'mikrotik',
    name: 'MikroTik Professional',
    description: 'Tema inspirado nas cores do MikroTik',
    type: ThemeType.mikrotik,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF293B7A), // Azul MikroTik
      brightness: Brightness.dark,
      primary: const Color(0xFF293B7A),
      secondary: const Color(0xFF4CAF50),
      surface: const Color(0xFF1A1A1A),
      background: const Color(0xFF121212),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: _defaultFontFamily, fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: TextStyle(fontFamily: _defaultFontFamily, fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: TextStyle(fontFamily: _defaultFontFamily, fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFFE0E0E0)),
      bodyLarge: TextStyle(fontFamily: _defaultFontFamily, fontSize: 16, color: Color(0xFFE0E0E0)),
      bodyMedium: TextStyle(fontFamily: _defaultFontFamily, fontSize: 14, color: Color(0xFFE0E0E0)),
      labelLarge: TextStyle(fontFamily: _defaultFontFamily, fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 4,
      centerTitle: true,
      backgroundColor: Color(0xFF293B7A),
      titleTextStyle: TextStyle(fontFamily: _defaultFontFamily, fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 6,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF293B7A), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF293B7A),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF293B7A),
        side: const BorderSide(color: Color(0xFF293B7A)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF293B7A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: const TextStyle(color: Color(0xFFE0E0E0)),
    ),
    iconTheme: const IconThemeData(size: 24, color: Color(0xFFE0E0E0)),
    dividerTheme: const DividerThemeData(thickness: 1, color: Color(0xFF293B7A)),
  );

  /// Tema Terminal
  static ThemeConfig get terminalTheme => ThemeConfig(
    id: 'terminal',
    name: 'Terminal Hacker',
    description: 'Tema estilo terminal para desenvolvedores',
    type: ThemeType.terminal,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00FF00), // Verde terminal
      brightness: Brightness.dark,
      primary: const Color(0xFF00FF00),
      secondary: const Color(0xFF00FFFF),
      surface: const Color(0xFF000000),
      background: const Color(0xFF000000),
      onPrimary: const Color(0xFF000000),
      onSecondary: const Color(0xFF000000),
      onSurface: const Color(0xFF00FF00),
      onBackground: const Color(0xFF00FF00),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Courier New', fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF00FF00)),
      titleLarge: TextStyle(fontFamily: 'Courier New', fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF00FF00)),
      titleMedium: TextStyle(fontFamily: 'Courier New', fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF00FFFF)),
      bodyLarge: TextStyle(fontFamily: 'Courier New', fontSize: 16, color: Color(0xFF00FF00)),
      bodyMedium: TextStyle(fontFamily: 'Courier New', fontSize: 14, color: Color(0xFF00FF00)),
      labelLarge: TextStyle(fontFamily: 'Courier New', fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF00FFFF)),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF000000),
      titleTextStyle: TextStyle(fontFamily: 'Courier New', fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF00FF00)),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Color(0xFF00FF00), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF000000),
        foregroundColor: const Color(0xFF00FF00),
        side: const BorderSide(color: Color(0xFF00FF00)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF00FF00),
        side: const BorderSide(color: Color(0xFF00FF00)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0xFF00FF00)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0xFF00FFFF), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: const TextStyle(color: Color(0xFF00FF00)),
    ),
    iconTheme: const IconThemeData(size: 24, color: Color(0xFF00FF00)),
    dividerTheme: const DividerThemeData(thickness: 1, color: Color(0xFF00FF00)),
  );

  /// Lista de todos os temas predefinidos
  static List<ThemeConfig> get allThemes => [
    lightTheme,
    darkTheme,
    mikrotikTheme,
    terminalTheme,
  ];
}