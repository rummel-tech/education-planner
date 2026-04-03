import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/education_provider.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

class EducationPlannerApp extends StatelessWidget {
  const EducationPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EducationProvider(),
      child: MaterialApp(
        title: 'Artemis Knowledge',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const _AppLoader(),
      ),
    );
  }
}

/// Handles async provider initialization before showing the main UI.
class _AppLoader extends StatefulWidget {
  const _AppLoader();

  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EducationProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EducationProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const MainShell();
      },
    );
  }
}
