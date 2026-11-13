import 'package:flutter/material.dart';

import '../../models/habit.dart';
import '../app_theme.dart';

/// Semana de segunda a domingo, navegável sem alterar o histórico dos hábitos.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.selectedDate,
    required this.habits,
    required this.onSelected,
  });

  final DateTime selectedDate;
  final List<Habit> habits;
  final ValueChanged<DateTime> onSelected;

  static const _labels = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];

  @override
  Widget build(BuildContext context) {
    final monday = DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
        .subtract(Duration(days: selectedDate.weekday - 1));

    return Row(
      children: [
        for (var index = 0; index < 7; index++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == 6 ? 0 : 5),
              child: _Day(
                day: monday.add(Duration(days: index)),
                label: _labels[index],
                selectedDate: selectedDate,
                habits: habits,
                onSelected: onSelected,
              ),
            ),
          ),
      ],
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({
    required this.day,
    required this.label,
    required this.selectedDate,
    required this.habits,
    required this.onSelected,
  });

  final DateTime day;
  final String label;
  final DateTime selectedDate;
  final List<Habit> habits;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = DateUtils.isSameDay(day, selectedDate);
    final today = DateUtils.isSameDay(day, DateTime.now());
    final scheduled = habits.where((habit) => habit.scheduledOn(day)).toList();
    final completed = scheduled.isNotEmpty &&
        scheduled.every((habit) => habit.completedOn(day));
    final dayKey = Habit.dateKey(day);

    return Semantics(
      label: '$label, ${day.day}; ${scheduled.length} hábitos planejados',
      button: true,
      selected: selected,
      child: Material(
        color: selected ? HabitPalette.terracotta : HabitPalette.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          key: Key('week-day-$dayKey'),
          onTap: () => onSelected(day),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected
                    ? HabitPalette.terracotta
                    : today
                        ? HabitPalette.sage
                        : HabitPalette.line,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white70 : HabitPalette.muted,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : HabitPalette.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white
                        : completed
                            ? HabitPalette.sage
                            : scheduled.isNotEmpty
                                ? HabitPalette.honey
                                : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
