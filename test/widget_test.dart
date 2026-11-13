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
    await tester.scrollUntilVisible(
      find.text('Nenhum hábito para esta data'),
      160,
    );
    expect(find.text('Nenhum hábito para esta data'), findsOneWidget);
  });

  testWidgets('agenda semanal navega e mantém o visual acolhedor', (tester) async {
    await tester.pumpWidget(
      HabitTrackApp(repository: MemoryHabitRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Um dia de cada vez.'), findsOneWidget);
    expect(find.text('Sua semana'), findsOneWidget);
    final nextWeek = DateTime.now().add(const Duration(days: 7));
    await tester.tap(find.byKey(const Key('week-next')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(Key('week-day-${Habit.dateKey(nextWeek)}')),
      findsOneWidget,
    );
  });

  testWidgets('marcar hábito salva conclusão no repositório', (tester) async {
    final repository = MemoryHabitRepository([
      const Habit(id: 'toggle', title: 'Tomar água'),
    ]);
    await tester.pumpWidget(HabitTrackApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('habit-check-toggle')),
      160,
    );
    await tester.tap(find.byKey(const Key('habit-check-toggle')));
    await tester.pumpAndSettle();
    expect((await repository.load()).single.completedOn(DateTime.now()), isTrue);
  });

  testWidgets('mostra hábito local existente e permite navegar', (tester) async {
    final habit = const Habit(id: 'x', title: 'Beber água');
    await tester.pumpWidget(
      HabitTrackApp(repository: MemoryHabitRepository([habit])),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Beber água'), 160);
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

    await tester.scrollUntilVisible(find.text('Estudar Python'), 160);
    expect(find.text('Estudar Python'), findsOneWidget);
  });
}
