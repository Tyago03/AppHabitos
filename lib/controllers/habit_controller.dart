import 'package:flutter/foundation.dart';

import '../data/habit_repository.dart';
import '../models/habit.dart';

class HabitController extends ChangeNotifier {
  HabitController(this.repository);

  final HabitRepository repository;
  List<Habit> _habits = <Habit>[];
  bool _loading = true;
  String? _error;

  List<Habit> get habits => List<Habit>.unmodifiable(_habits);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> initialize() async {
    try {
      _habits = await repository.load();
      _error = null;
    } catch (_) {
      // Não sobrescreve dados antigos corrompidos com um estado vazio.
      _error = 'Não foi possível abrir os dados locais. Nenhuma alteração foi feita.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> add(Habit habit) async {
    if (habit.title.trim().isEmpty) throw ArgumentError('Título obrigatório.');
    if (_habits.any((existing) => existing.id == habit.id)) {
      throw StateError('Hábito com identificador repetido.');
    }
    await _persist(<Habit>[..._habits, habit]);
  }

  Future<void> update(Habit habit) async {
    final index = _habits.indexWhere((existing) => existing.id == habit.id);
    if (index < 0) throw StateError('Hábito não encontrado.');
    final next = <Habit>[..._habits];
    next[index] = habit;
    await _persist(next);
  }

  Future<void> delete(String id) async {
    await _persist(_habits.where((habit) => habit.id != id).toList());
  }

  Future<void> toggle(String id, DateTime date, bool completed) async {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index < 0) throw StateError('Hábito não encontrado.');
    final current = _habits[index];
    if (!current.scheduledOn(date)) {
      throw StateError('Hábito não agendado para esta data.');
    }
    final next = <Habit>[..._habits];
    next[index] = current.setCompleted(date, completed);
    await _persist(next);
  }

  Future<void> _persist(List<Habit> next) async {
    if (_error != null) throw StateError(_error!);
    await repository.save(next); // Em falha, mantém o estado anterior na tela.
    _habits = next;
    notifyListeners();
  }
}
