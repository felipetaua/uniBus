import 'package:bus_attendance_app/core/theme/app_theme.dart';
import 'package:bus_attendance_app/features/splash_screen.dart';
import 'package:flutter/material.dart';
import 'core/utils/device_orientation.dart';

void main() async {
  await setPortraitOrientation();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unibus',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
