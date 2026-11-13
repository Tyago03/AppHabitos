import 'package:flutter/material.dart';

import '../controllers/habit_controller.dart';
import '../data/habit_repository.dart';
import '../models/habit.dart';
import 'app_theme.dart';
import 'habit_editor.dart';
import 'widgets/habit_tile.dart';
import 'widgets/week_strip.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.repository,
    this.demoMode = false,
    this.initialTab = 0,
  });

  final HabitRepository repository;
  final bool demoMode;
  final int initialTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _months = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];
  static const _weekdays = [
    'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira',
    'Sexta-feira', 'Sábado', 'Domingo',
  ];
  static const _weekdayShort = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

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
        final days = habit.weekdays
            .where((day) => day >= 1 && day <= 7)
            .map((day) => _weekdayShort[day - 1])
            .join(', ');
        return 'Toda semana · $days';
      case HabitFrequency.monthly:
        return 'Todo mês · dia ${habit.monthDays.join(', ')}';
    }
  }

  String _dateText(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _longDate(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, ${date.day} de ${_months[date.month - 1]}';

  Widget _scroll(List<Widget> content) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 112),
            children: content,
          ),
        ),
      );

  Widget _sectionHeading(String title, {String? subtitle}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: HabitPalette.muted,
                fontSize: 13,
              ),
            ),
          ],
        ],
      );

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
      backgroundColor: HabitPalette.paper,
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

  Widget _habitTile(Habit habit) => HabitTile(
        habit: habit,
        date: _selectedDate,
        recurrence: _frequencyText(habit),
        onChecked: (value) => _toggle(habit, value),
        onEdit: () => _openEditor(habit),
        onDelete: () => _delete(habit),
      );

  Widget _emptyState(String title, String subtitle) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
        decoration: BoxDecoration(
          color: HabitPalette.white,
          border: Border.all(color: HabitPalette.line),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.local_florist_outlined,
              size: 40,
              color: HabitPalette.sage,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: HabitPalette.muted),
            ),
          ],
        ),
      );

  Widget _progressPanel(int done, int total) {
    final progress = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: HabitPalette.sageWash,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.spa_outlined, color: HabitPalette.sage),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Progresso do dia',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: HabitPalette.sage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$done de $total hábitos concluídos',
            style: const TextStyle(color: HabitPalette.muted, fontSize: 13),
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: HabitPalette.white,
              color: HabitPalette.sage,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Cada pequeno passo também conta.',
            style: TextStyle(color: HabitPalette.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _todayPage() {
    final scheduled = _controller.habits
        .where((habit) => habit.scheduledOn(_selectedDate))
        .toList();
    final complete = scheduled
        .where((habit) => habit.completedOn(_selectedDate))
        .length;

    return _scroll([
      const Text(
        'MINHA AGENDA',
        style: TextStyle(
          color: HabitPalette.terracotta,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 2,
        ),
      ),
      const SizedBox(height: 9),
      Text('Um dia de cada vez.', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Text(
        _longDate(_selectedDate),
        style: const TextStyle(color: HabitPalette.muted, fontSize: 14),
      ),
      const SizedBox(height: 26),
      Row(
        children: [
          Expanded(child: _sectionHeading('Sua semana')),
          IconButton(
            key: const Key('week-previous'),
            tooltip: 'Semana anterior',
            onPressed: () => setState(
              () => _selectedDate = _selectedDate.subtract(const Duration(days: 7)),
            ),
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            key: const Key('week-next'),
            tooltip: 'Próxima semana',
            onPressed: () => setState(
              () => _selectedDate = _selectedDate.add(const Duration(days: 7)),
            ),
            icon: const Icon(Icons.chevron_right),
          ),
          IconButton(
            tooltip: 'Escolher data',
            onPressed: _chooseDate,
            icon: const Icon(Icons.calendar_month_outlined, size: 21),
          ),
        ],
      ),
      const SizedBox(height: 11),
      WeekStrip(
        selectedDate: _selectedDate,
        habits: _controller.habits,
        onSelected: (date) => setState(() => _selectedDate = date),
      ),
      const SizedBox(height: 23),
      _progressPanel(complete, scheduled.length),
      const SizedBox(height: 25),
      _sectionHeading(
        'Para esta data',
        subtitle: 'Marque seus hábitos à medida que o dia acontece.',
      ),
      const SizedBox(height: 13),
      if (scheduled.isEmpty)
        _emptyState(
          'Nenhum hábito para esta data',
          'Comece criando um hábito no botão abaixo.',
        )
      else
        for (final habit in scheduled) _habitTile(habit),
    ]);
  }

  Widget _allPage() {
    final habits = _controller.habits;
    return _scroll([
      const Text(
        'SEU CANTINHO',
        style: TextStyle(
          color: HabitPalette.terracotta,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 2,
        ),
      ),
      const SizedBox(height: 10),
      Text('Todos os hábitos', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      const Text(
        'Organize o que faz bem e ajuste sua rotina com calma.',
        style: TextStyle(color: HabitPalette.muted),
      ),
      const SizedBox(height: 24),
      _sectionHeading(
        'Seus hábitos',
        subtitle: 'Edite a frequência ou exclua pelo menu de cada item.',
      ),
      const SizedBox(height: 13),
      if (habits.isEmpty)
        _emptyState('Sua lista está vazia', 'Crie seu primeiro hábito.')
      else
        for (final habit in habits) _habitTile(habit),
    ]);
  }

  Widget _summaryPage() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final habits = _controller.habits;
    final entries = <({DateTime date, int due, int completed})>[];

    for (var previousDays = 6; previousDays >= 0; previousDays--) {
      final date = today.subtract(Duration(days: previousDays));
      final scheduled = habits.where((habit) => habit.scheduledOn(date)).toList();
      entries.add((
        date: date,
        due: scheduled.length,
        completed: scheduled.where((habit) => habit.completedOn(date)).length,
      ));
    }

    final totalDue = entries.fold<int>(0, (sum, entry) => sum + entry.due);
    final totalDone = entries.fold<int>(0, (sum, entry) => sum + entry.completed);
    final progress = totalDue == 0 ? 0.0 : totalDone / totalDue;

    return _scroll([
      const Text(
        'OLHANDO PARA TRÁS',
        style: TextStyle(
          color: HabitPalette.terracotta,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 2,
        ),
      ),
      const SizedBox(height: 10),
      Text('Seu resumo', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      const Text(
        'Celebre o que conseguiu nos últimos sete dias.',
        style: TextStyle(color: HabitPalette.muted),
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: HabitPalette.peach,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conclusões da semana', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 11),
            Text(
              '$totalDone de $totalDue',
              style: const TextStyle(
                color: HabitPalette.terracotta,
                fontWeight: FontWeight.w700,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                color: HabitPalette.terracotta,
                backgroundColor: HabitPalette.white,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      _sectionHeading('Dia após dia', subtitle: 'Uma visão simples da sua constância.'),
      const SizedBox(height: 12),
      for (final entry in entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(
                      _dateText(entry.date),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: HabitPalette.ink,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: entry.due == 0 ? 0 : entry.completed / entry.due,
                        minHeight: 8,
                        backgroundColor: HabitPalette.sageWash,
                        color: HabitPalette.sage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    '${entry.completed}/${entry.due}',
                    style: const TextStyle(
                      color: HabitPalette.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      const SizedBox(height: 16),
      const Text(
        'Seus registros ficam neste dispositivo. Apagar os dados do aplicativo pode removê-los.',
        style: TextStyle(color: HabitPalette.muted, fontSize: 12),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories_outlined, color: HabitPalette.terracotta),
            SizedBox(width: 10),
            Text(
              'HabiTrack',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: widget.demoMode
            ? [
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Chip(label: Text('DEMO', style: TextStyle(fontSize: 10))),
                ),
              ]
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
                child: Text(_controller.error!, textAlign: TextAlign.center),
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
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), label: 'Hoje'),
          NavigationDestination(icon: Icon(Icons.checklist_rounded), label: 'Hábitos'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Resumo'),
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
