import 'package:flutter/material.dart';

import '../../models/habit.dart';
import '../app_theme.dart';

/// Item de agenda compacto; a decisão de salvar continua no controller.
class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.habit,
    required this.date,
    required this.recurrence,
    required this.onChecked,
    required this.onEdit,
    required this.onDelete,
  });

  final Habit habit;
  final DateTime date;
  final String recurrence;
  final ValueChanged<bool> onChecked;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheduled = habit.scheduledOn(date);
    final checked = scheduled && habit.completedOn(date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 11, 4, 11),
          child: Row(
            children: [
              Checkbox(
                key: Key('habit-check-${habit.id}'),
                shape: const CircleBorder(),
                activeColor: HabitPalette.sage,
                value: checked,
                onChanged: scheduled
                    ? (value) => onChecked(value ?? false)
                    : null,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: HabitPalette.ink,
                        decoration: checked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: HabitPalette.muted,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      habit.notes.isEmpty
                          ? recurrence
                          : '$recurrence · ${habit.notes}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: HabitPalette.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opções do hábito',
                icon: const Icon(Icons.more_horiz, color: HabitPalette.muted),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
