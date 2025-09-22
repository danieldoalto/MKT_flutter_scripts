import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'services/theme_service.dart';
import 'layouts/layout_manager.dart';
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
          // Aplica adaptações de tema específicas da plataforma
          final baseTheme = themeService.currentTheme.toThemeData();
          final adaptedTheme = LayoutManager.adaptThemeForPlatform(baseTheme);
          
          return MaterialApp(
            title: 'MikroTik SSH Script Runner v${AppVersion.version}',
            theme: adaptedTheme,
            home: const LayoutManager(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
