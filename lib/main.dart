import 'package:flutter/material.dart';

import 'data/habit_repository.dart';
import 'models/habit.dart';
import 'ui/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const demo = bool.fromEnvironment('HABITTRACK_DEMO', defaultValue: false);
  final tab = demo ? int.tryParse(Uri.base.queryParameters['tab'] ?? '0') ?? 0 : 0;
  runApp(HabitTrackApp(
    repository: demo ? MemoryHabitRepository(createDemoHabits()) : null,
    demoMode: demo,
    initialTab: tab.clamp(0, 2),
  ));
}

/// Reconstrução independente: funciona sem Firebase, contas ou credenciais.
class HabitTrackApp extends StatelessWidget {
  const HabitTrackApp({super.key, this.repository, this.demoMode = false, this.initialTab = 0});

  final HabitRepository? repository;
  final bool demoMode;
  final int initialTab;

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
      home: HomePage(repository: repository ?? LocalHabitRepository(), demoMode: demoMode, initialTab: initialTab),
    );
  }
}


/// Registros FICTÍCIOS exclusivos do build de demonstração.
List<Habit> createDemoHabits() {
  final today = DateTime.now();
  String key(int daysAgo) => Habit.dateKey(today.subtract(Duration(days: daysAgo)));
  return [
    Habit(id: 'demo-01', title: 'Estudar programação', notes: '45 minutos por dia',
      completedDates: {key(0), key(1), key(2), key(4), key(5), key(6)}),
    Habit(id: 'demo-02', title: 'Ler 20 páginas', notes: 'Antes de dormir',
      completedDates: {key(0), key(1), key(3), key(4), key(5)}),
    Habit(id: 'demo-03', title: 'Praticar inglês', notes: 'Conversação e vocabulário',
      completedDates: {key(0), key(2), key(3), key(6)}),
    Habit(id: 'demo-04', title: 'Exercício físico', notes: '30 minutos',
      completedDates: {key(1), key(2), key(4), key(5)}),
    Habit(id: 'demo-05', title: 'Beber água', notes: 'Acompanhar a hidratação',
      completedDates: {key(0), key(1), key(2), key(3), key(4), key(5), key(6)}),
  ];
}
