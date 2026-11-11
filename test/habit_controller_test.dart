import 'package:flutter_test/flutter_test.dart';
import 'package:habittrack/controllers/habit_controller.dart';
import 'package:habittrack/data/habit_repository.dart';
import 'package:habittrack/models/habit.dart';

void main() {
  test('criação, marcação, edição e exclusão persistem', () async {
    final repository = MemoryHabitRepository();
    final controller = HabitController(repository);
    await controller.initialize();

    const habit = Habit(id: '1', title: 'Estudar');
    await controller.add(habit);
    expect(controller.habits.length, 1);

    final day = DateTime(2026, 11, 11);
    await controller.toggle('1', day, true);
    expect(controller.habits.single.completedOn(day), isTrue);

    await controller.update(controller.habits.single.copyWith(title: 'Ler'));
    expect(controller.habits.single.title, 'Ler');

    final otherController = HabitController(repository);
    await otherController.initialize();
    expect(otherController.habits.single.completedOn(day), isTrue);
    await otherController.delete('1');
    expect(otherController.habits, isEmpty);
    controller.dispose();
    otherController.dispose();
  });

  test('não permite concluir dia fora da recorrência', () async {
    final controller = HabitController(MemoryHabitRepository([
      const Habit(
        id: '2',
        title: 'Treino',
        frequency: HabitFrequency.weekly,
        weekdays: [1],
      ),
    ]));
    await controller.initialize();
    await expectLater(
      controller.toggle('2', DateTime(2026, 11, 10), true),
      throwsStateError,
    );
    controller.dispose();
  });
}
