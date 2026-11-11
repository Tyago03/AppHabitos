import 'package:flutter_test/flutter_test.dart';
import 'package:habittrack/models/habit.dart';

void main() {
  test('hábito diário ocorre todos os dias', () {
    const habit = Habit(id: 'a', title: 'Água');
    expect(habit.scheduledOn(DateTime(2026, 11, 10)), isTrue);
    expect(habit.scheduledOn(DateTime(2026, 11, 11)), isTrue);
  });

  test('hábito semanal respeita os dias selecionados', () {
    const habit = Habit(
      id: 'b',
      title: 'Exercício',
      frequency: HabitFrequency.weekly,
      weekdays: [1, 3],
    );
    expect(habit.scheduledOn(DateTime(2026, 11, 9)), isTrue); // Segunda
    expect(habit.scheduledOn(DateTime(2026, 11, 10)), isFalse); // Terça
    expect(habit.scheduledOn(DateTime(2026, 11, 11)), isTrue); // Quarta
  });

  test('hábito mensal respeita a duração do mês', () {
    const habit = Habit(
      id: 'c',
      title: 'Revisão',
      frequency: HabitFrequency.monthly,
      monthDays: [31],
    );
    expect(habit.scheduledOn(DateTime(2026, 1, 31)), isTrue);
    expect(habit.scheduledOn(DateTime(2026, 2, 28)), isFalse);
  });

  test('conclusão diária é reversível e isolada por data', () {
    const habit = Habit(id: 'a', title: 'Ler');
    final day = DateTime(2026, 11, 11);
    final finished = habit.setCompleted(day, true);
    expect(habit.completedOn(day), isFalse);
    expect(finished.completedOn(day), isTrue);
    expect(finished.completedOn(DateTime(2026, 11, 12)), isFalse);
    expect(finished.setCompleted(day, false).completedOn(day), isFalse);
  });

  test('roundtrip JSON preserva recorrência e conclusões', () {
    const original = Habit(
      id: 'd',
      title: 'Estudar',
      notes: '30 minutos',
      frequency: HabitFrequency.weekly,
      weekdays: [3, 5],
      reminderMinuteOfDay: 540,
      completedDates: {'2026-11-11'},
    );
    final saved = Habit.encodeAll([original]);
    final restored = Habit.decodeAll(saved).single;
    expect(restored.toJson(), original.toJson());
  });

  test('registro inválido não passa como hábito', () {
    expect(
      () => Habit.decodeAll('[{"id":"","title":""}]'),
      throwsFormatException,
    );
  });
}
