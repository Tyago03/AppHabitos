import 'package:flutter/material.dart';

import '../controllers/habit_controller.dart';
import '../data/habit_repository.dart';
import '../models/habit.dart';
import 'habit_editor.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.repository, this.demoMode = false, this.initialTab = 0});

  final HabitRepository repository;
  final bool demoMode;
  final int initialTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HabitController _controller;
  var _tab = 0;
  var _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _controller = HabitController(widget.repository);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _frequencyText(Habit habit) {
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return 'Todos os dias';
      case HabitFrequency.weekly:
        return 'Semanal: ${habit.weekdays.join(', ')} (seg=1)';
      case HabitFrequency.monthly:
        return 'Mensal: dia ${habit.monthDays.join(', ')}';
    }
  }

  String _dateText(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> _openEditor([Habit? habit]) async {
    final result = await showModalBottomSheet<Habit>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => HabitEditor(existing: habit),
    );
    if (result == null) return;
    try {
      if (habit == null) {
        await _controller.add(result);
      } else {
        await _controller.update(result);
      }
      _message(habit == null ? 'Hábito criado.' : 'Hábito atualizado.');
    } catch (_) {
      _message('Não foi possível salvar o hábito.');
    }
  }

  Future<void> _delete(Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir hábito?'),
        content: Text('"${habit.title}" e o histórico deste hábito serão removidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _controller.delete(habit.id);
      _message('Hábito excluído.');
    } catch (_) {
      _message('Não foi possível excluir o hábito.');
    }
  }

  Future<void> _toggle(Habit habit, bool checked) async {
    try {
      await _controller.toggle(habit.id, _selectedDate, checked);
    } catch (_) {
      _message('Não foi possível registrar a conclusão.');
    }
  }

  Future<void> _chooseDate() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (chosen != null && mounted) setState(() => _selectedDate = chosen);
  }

  Widget _habitCard(Habit habit) {
    final scheduled = habit.scheduledOn(_selectedDate);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.only(left: 14, right: 0),
              controlAffinity: ListTileControlAffinity.leading,
              value: scheduled && habit.completedOn(_selectedDate),
              onChanged: scheduled
                  ? (value) => _toggle(habit, value ?? false)
                  : null,
              title: Text(
                habit.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                habit.notes.isEmpty
                    ? _frequencyText(habit)
                    : '${_frequencyText(habit)} · ${habit.notes}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Opções do hábito',
            onSelected: (value) {
              if (value == 'edit') {
                _openEditor(habit);
              } else if (value == 'delete') {
                _delete(habit);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Excluir')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String title, String subtitle) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.spa_outlined, size: 56),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(subtitle, textAlign: TextAlign.center),
            ],
          ),
        ),
      );

  Widget _todayPage() {
    final todayHabits = _controller.habits
        .where((habit) => habit.scheduledOn(_selectedDate))
        .toList();
    final complete = todayHabits
        .where((habit) => habit.completedOn(_selectedDate))
        .length;
    final progress = todayHabits.isEmpty ? 0.0 : complete / todayHabits.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 100),
      children: [
        Text('Minha rotina', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 5),
        Text('Pequenas ações, grandes resultados.',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _chooseDate,
          icon: const Icon(Icons.calendar_today),
          label: Text('Data: ${_dateText(_selectedDate)}'),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progresso do dia', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('$complete de ${todayHabits.length} hábitos concluídos'),
                const SizedBox(height: 14),
                LinearProgressIndicator(value: progress, minHeight: 9),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Para esta data', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        if (todayHabits.isEmpty)
          _emptyState(
            'Nenhum hábito para esta data',
            'Crie um hábito no botão abaixo para começar.',
          )
        else
          for (final habit in todayHabits) _habitCard(habit),
      ],
    );
  }

  Widget _allPage() {
    final habits = _controller.habits;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
      children: [
        Text('Todos os hábitos', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text('Edite a frequência ou exclua hábitos pelo menu de cada cartão.'),
        const SizedBox(height: 18),
        if (habits.isEmpty)
          _emptyState('Sua lista está vazia', 'Crie seu primeiro hábito.')
        else
          for (final habit in habits) _habitCard(habit),
      ],
    );
  }

  Widget _summaryPage() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final habits = _controller.habits;
    final entries = <({DateTime date, int due, int completed})>[];

    for (var previousDays = 6; previousDays >= 0; previousDays--) {
      final date = today.subtract(Duration(days: previousDays));
      final scheduled = habits.where((habit) => habit.scheduledOn(date));
      entries.add((
        date: date,
        due: scheduled.length,
        completed: scheduled.where((habit) => habit.completedOn(date)).length,
      ));
    }

    final totalDue = entries.fold<int>(0, (sum, item) => sum + item.due);
    final totalDone =
        entries.fold<int>(0, (sum, item) => sum + item.completed);
    final progress = totalDue == 0 ? 0.0 : totalDone / totalDue;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
      children: [
        Text('Resumo', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text('Acompanhamento local das últimas 7 datas.'),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Conclusões da semana',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(
                  '$totalDone / $totalDue',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: progress, minHeight: 9),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Por dia', style: Theme.of(context).textTheme.titleLarge),
        for (final entry in entries)
          Card(
            child: ListTile(
              title: Text(_dateText(entry.date)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: LinearProgressIndicator(
                  value: entry.due == 0 ? 0 : entry.completed / entry.due,
                  minHeight: 7,
                ),
              ),
              trailing: Text('${entry.completed}/${entry.due}'),
            ),
          ),
        const SizedBox(height: 10),
        const Text(
          'Os registros permanecem no dispositivo; não há sincronização com '
          'Firebase nesta reconstrução. Exporte seus dados antes de limpar o app.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.spa, color: Color(0xFF35C9AB)),
            SizedBox(width: 10),
            Text('HabiTrack'),
          ],
        ),
        actions: widget.demoMode
            ? [const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Chip(label: Text('DEMO', style: TextStyle(fontSize: 10))),
              )]
            : null,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _controller.error!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return switch (_tab) {
            0 => _todayPage(),
            1 => _allPage(),
            _ => _summaryPage(),
          };
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Hoje'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Hábitos'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Resumo'),
        ],
      ),
      floatingActionButton: _tab == 2 || _controller.error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add),
              label: const Text('Novo hábito'),
            ),
    );
  }
}
