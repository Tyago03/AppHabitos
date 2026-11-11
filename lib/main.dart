import 'package:flutter/material.dart';

import 'data/habit_repository.dart';
import 'ui/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HabitTrackApp());
}

/// Reconstrução independente: funciona sem Firebase, contas ou credenciais.
class HabitTrackApp extends StatelessWidget {
  const HabitTrackApp({super.key, this.repository});

  final HabitRepository? repository;

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.fromSeed(
      seedColor: const Color(0xFF35C9AB),
      brightness: Brightness.dark,
    );
    return MaterialApp(
      title: 'HabiTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colors,
        scaffoldBackgroundColor: const Color(0xFF101719),
        cardTheme: CardThemeData(
          color: const Color(0xFF1B292B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101719),
          centerTitle: false,
        ),
      ),
      home: HomePage(repository: repository ?? LocalHabitRepository()),
    );
  }
}
