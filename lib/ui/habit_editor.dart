import 'package:flutter/material.dart';

import '../models/habit.dart';

class HabitEditor extends StatefulWidget {
  const HabitEditor({super.key, this.existing});

  final Habit? existing;

  @override
  State<HabitEditor> createState() => _HabitEditorState();
}

class _HabitEditorState extends State<HabitEditor> {
  static const dayLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late HabitFrequency _frequency;
  late Set<int> _weekdays;
  late int _monthDay;
  late bool _hasReminder;
  late TimeOfDay _reminder;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _frequency = existing?.frequency ?? HabitFrequency.daily;
    _weekdays = {...?existing?.weekdays};
    if (_weekdays.isEmpty) _weekdays.add(DateTime.now().weekday);
    _monthDay = (existing?.monthDays.isNotEmpty ?? false)
        ? existing!.monthDays.first
        : DateTime.now().day;
    final minute = existing?.reminderMinuteOfDay;
    _hasReminder = minute != null;
    _reminder = minute == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : TimeOfDay(hour: minute ~/ 60, minute: minute % 60);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickReminder() async {
    final value = await showTimePicker(context: context, initialTime: _reminder);
    if (value == null || !mounted) return;
    setState(() => _reminder = value);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um nome para o hábito.')),
      );
      return;
    }
    if (_frequency == HabitFrequency.weekly && _weekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um dia da semana.')),
      );
      return;
    }
    final existing = widget.existing;
    final habit = Habit(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      notes: _notesController.text.trim(),
      frequency: _frequency,
      weekdays: _frequency == HabitFrequency.weekly
          ? (_weekdays.toList()..sort())
          : const <int>[],
      monthDays: _frequency == HabitFrequency.monthly
          ? <int>[_monthDay]
          : const <int>[],
      completedDates: existing?.completedDates ?? const <String>{},
      reminderMinuteOfDay:
          _hasReminder ? _reminder.hour * 60 + _reminder.minute : null,
    );
    Navigator.of(context).pop(habit);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: FractionallySizedBox(
        heightFactor: 0.88,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Editar hábito' : 'Criar hábito',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 18),
              TextField(
                key: const Key('habit-title'),
                controller: _titleController,
                maxLength: 80,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nome do hábito',
                  hintText: 'Ex.: Estudar inglês',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 2,
                maxLength: 240,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Text('Frequência', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final option in HabitFrequency.values)
                    ChoiceChip(
                      label: Text(switch (option) {
                        HabitFrequency.daily => 'Diário',
                        HabitFrequency.weekly => 'Semanal',
                        HabitFrequency.monthly => 'Mensal',
                      }),
                      selected: _frequency == option,
                      onSelected: (_) => setState(() => _frequency = option),
                    ),
                ],
              ),
              if (_frequency == HabitFrequency.weekly) ...[
                const SizedBox(height: 18),
                Text('Dias da semana', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  children: [
                    for (var index = 0; index < dayLabels.length; index++)
                      FilterChip(
                        label: Text(dayLabels[index]),
                        selected: _weekdays.contains(index + 1),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            _weekdays.add(index + 1);
                          } else {
                            _weekdays.remove(index + 1);
                          }
                        }),
                      ),
                  ],
                ),
              ],
              if (_frequency == HabitFrequency.monthly) ...[
                const SizedBox(height: 18),
                Text('Dia do mês', style: Theme.of(context).textTheme.titleMedium),
                DropdownButton<int>(
                  value: _monthDay,
                  isExpanded: true,
                  items: [
                    for (var day = 1; day <= 31; day++)
                      DropdownMenuItem(value: day, child: Text('Dia $day')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _monthDay = value);
                  },
                ),
                const Text(
                  'Se o mês não tiver esse dia, não haverá ocorrência naquele mês.',
                ),
              ],
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _hasReminder,
                onChanged: (value) => setState(() => _hasReminder = value),
                title: const Text('Guardar horário preferido'),
                subtitle: const Text(
                  'Ainda não dispara notificações automáticas.',
                ),
              ),
              if (_hasReminder)
                OutlinedButton.icon(
                  onPressed: _pickReminder,
                  icon: const Icon(Icons.schedule),
                  label: Text('Horário: ${_reminder.format(context)}'),
                ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check),
                label: Text(isEditing ? 'Salvar alterações' : 'Salvar hábito'),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
