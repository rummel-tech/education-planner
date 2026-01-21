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
        title: 'Education Planner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const MainShell(),
      ),
    );
  }
}
