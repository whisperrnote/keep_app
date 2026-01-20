import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/landing_screen.dart';

void main() {
  runApp(const WhisperrKeepApp());
}

class WhisperrKeepApp extends StatelessWidget {
  const WhisperrKeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhisperrKeep',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LandingScreen(),
    );
  }
}
