import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habittrack/data/habit_repository.dart';
import 'package:habittrack/main.dart';
import 'package:habittrack/models/habit.dart';

void main() {
  testWidgets('tela de início apresenta estado vazio', (tester) async {
    await tester.pumpWidget(
      HabitTrackApp(repository: MemoryHabitRepository()),
    );
    await tester.pumpAndSettle();
    expect(find.text('HabiTrack'), findsOneWidget);
    expect(find.text('Nenhum hábito para esta data'), findsOneWidget);
  });

  testWidgets('mostra hábito local existente e permite navegar', (tester) async {
    final habit = const Habit(id: 'x', title: 'Beber água');
    await tester.pumpWidget(
      HabitTrackApp(repository: MemoryHabitRepository([habit])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Beber água'), findsOneWidget);
    await tester.tap(find.text('Resumo'));
    await tester.pumpAndSettle();
    expect(find.text('Conclusões da semana'), findsOneWidget);
  });

  testWidgets('cria novo hábito pelo formulário', (tester) async {
    await tester.pumpWidget(
      HabitTrackApp(repository: MemoryHabitRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Novo hábito'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('habit-title')),
      'Estudar Python',
    );
    final save = find.text('Salvar hábito');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text('Estudar Python'), findsOneWidget);
  });
}
