import 'package:flutter/material.dart';
import 'screens/morse_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SurviLink',
      theme: base.copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F12),
        colorScheme: base.colorScheme.copyWith(
          primary: const Color(0xFFFF8C42), // orange unique
          secondary: const Color(0xFFFF8C42),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0F12),
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF8C42),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      routes: {
        '/': (context) => const HomeScreen(),
        '/morse': (context) => const MorseScreen(),
      },
      initialRoute: '/',
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SurviLink – Accueil')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/morse'),
          icon: const Icon(Icons.radio),
          label: const Text('Clavier Morse'),
        ),
      ),
    );
  }
}
