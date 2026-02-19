import 'package:flutter/material.dart';
import '../screen/splash_screen.dart';

class GradeVaultApp extends StatelessWidget {
  const GradeVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GradeVault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080B14),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFBB38),
          secondary: Color(0xFF38D9FF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}