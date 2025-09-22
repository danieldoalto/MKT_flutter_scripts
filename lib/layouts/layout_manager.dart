import 'dart:io';
import 'package:flutter/material.dart';
import 'mobile_layout.dart';
import 'desktop_layout.dart';

/// Gerenciador de layouts que detecta a plataforma e carrega o layout apropriado
/// 
/// - Android: MobileLayout (navegação minimalista, densidade de informação)
/// - Windows: DesktopLayout (mantém UI atual)
class LayoutManager extends StatelessWidget {
  const LayoutManager({super.key});

  @override
  Widget build(BuildContext context) {
    // Detecta a plataforma e retorna o layout apropriado
    if (Platform.isAndroid) {
      return const MobileLayout();
    } else {
      // Windows, macOS, Linux, Web
      return const DesktopLayout();
    }
  }

  /// Verifica se está executando em plataforma móvel
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  
  /// Verifica se está executando em plataforma desktop
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  
  /// Obtém o padding específico da plataforma
  static EdgeInsets getPlatformPadding() {
    return isMobile 
        ? const EdgeInsets.all(8.0)
        : const EdgeInsets.all(16.0);
  }

  /// Obtém o tamanho da fonte específico da plataforma
  static double getPlatformFontSize({required double mobile, required double desktop}) {
    return isMobile ? mobile : desktop;
  }

  /// Obtém a altura do botão específica da plataforma
  static double getPlatformButtonHeight() {
    return isMobile ? 48.0 : 40.0;
  }

  /// Obtém configurações de tema específicas da plataforma
  static ThemeData adaptThemeForPlatform(ThemeData baseTheme) {
    if (isMobile) {
      return baseTheme.copyWith(
        // Densidade visual adaptativa para mobile
        visualDensity: VisualDensity.compact,
        
        // AppBar otimizada para mobile
        appBarTheme: baseTheme.appBarTheme.copyWith(
          toolbarHeight: 56.0, // Altura padrão Android
          elevation: 4.0,
          titleTextStyle: baseTheme.appBarTheme.titleTextStyle?.copyWith(
            fontSize: 18.0, // Menor para mobile
          ),
        ),
        
        // Cards com menos elevação para mobile
        cardTheme: baseTheme.cardTheme.copyWith(
          elevation: 2.0,
          margin: const EdgeInsets.all(4.0),
        ),
        
        // Botões otimizados para toque
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: baseTheme.elevatedButtonTheme.style?.copyWith(
            minimumSize: WidgetStateProperty.all(const Size(88, 48)),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            textStyle: WidgetStateProperty.all(
              baseTheme.textTheme.labelLarge?.copyWith(fontSize: 14.0),
            ),
          ),
        ),
        
        // Campos de entrada otimizados para mobile
        inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          isDense: true,
        ),
        
        // Texto otimizado para mobile
        textTheme: baseTheme.textTheme.copyWith(
          titleLarge: baseTheme.textTheme.titleLarge?.copyWith(fontSize: 20.0),
          titleMedium: baseTheme.textTheme.titleMedium?.copyWith(fontSize: 16.0),
          titleSmall: baseTheme.textTheme.titleSmall?.copyWith(fontSize: 14.0),
          bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(fontSize: 14.0),
          bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(fontSize: 12.0),
          labelLarge: baseTheme.textTheme.labelLarge?.copyWith(fontSize: 14.0),
        ),
        
        // Ícones menores para mobile
        iconTheme: baseTheme.iconTheme.copyWith(size: 20.0),
        
        // Bottom navigation bar otimizada
        bottomNavigationBarTheme: baseTheme.bottomNavigationBarTheme.copyWith(
          type: BottomNavigationBarType.fixed,
          selectedIconTheme: const IconThemeData(size: 24.0),
          unselectedIconTheme: const IconThemeData(size: 20.0),
        ),
      );
    } else {
      // Desktop mantém configurações originais com algumas otimizações
      return baseTheme.copyWith(
        visualDensity: VisualDensity.standard,
        
        // AppBar para desktop
        appBarTheme: baseTheme.appBarTheme.copyWith(
          toolbarHeight: 64.0, // Maior para desktop
        ),
        
        // Cards com mais elevação para desktop
        cardTheme: baseTheme.cardTheme.copyWith(
          elevation: 4.0,
          margin: const EdgeInsets.all(8.0),
        ),
        
        // Botões para desktop
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: baseTheme.elevatedButtonTheme.style?.copyWith(
            minimumSize: WidgetStateProperty.all(const Size(88, 40)),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      );
    }
  }
}