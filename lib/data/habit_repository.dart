import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

abstract class HabitRepository {
  Future<List<Habit>> load();
  Future<void> save(List<Habit> habits);
}

/// Persistência simples em JSON, sem servidor nem conta de usuário.
///
/// shared_preferences não é um banco transacional ou armazenamento crítico.
class LocalHabitRepository implements HabitRepository {
  LocalHabitRepository({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const _key = 'habittrack_habits_v1';
  final SharedPreferencesAsync _preferences;

  @override
  Future<List<Habit>> load() async {
    final value = await _preferences.getString(_key);
    return value == null ? <Habit>[] : Habit.decodeAll(value);
  }

  @override
  Future<void> save(List<Habit> habits) =>
      _preferences.setString(_key, Habit.encodeAll(habits));
}

/// Implementação em memória usada em testes; não grava dados pessoais.
class MemoryHabitRepository implements HabitRepository {
  MemoryHabitRepository([List<Habit> initial = const []])
      : _items = List<Habit>.of(initial);

  List<Habit> _items;

  @override
  Future<List<Habit>> load() async => List<Habit>.of(_items);

  @override
  Future<void> save(List<Habit> habits) async {
    _items = List<Habit>.of(habits);
  }
}
