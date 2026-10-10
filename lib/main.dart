import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(const RentEasyApp());
}

class RentEasyApp extends StatelessWidget {
  const RentEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RentEasy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.light,
      home: const AuthScreen(),
    );
  }
}
