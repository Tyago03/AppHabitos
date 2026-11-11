import 'dart:convert';

/// Recorrência do hábito. A conclusão é registrada por dia, não por booleano global.
enum HabitFrequency { daily, weekly, monthly }

class Habit {
  final String id;
  final String title;
  final String notes;
  final HabitFrequency frequency;
  final List<int> weekdays; // 1 (segunda-feira) a 7 (domingo).
  final List<int> monthDays; // 1 a 31.
  final Set<String> completedDates; // yyyy-MM-dd no fuso local.
  final int? reminderMinuteOfDay; // Preferência visual; ainda não agenda alarmes.

  const Habit({
    required this.id,
    required this.title,
    this.notes = '',
    this.frequency = HabitFrequency.daily,
    this.weekdays = const [],
    this.monthDays = const [],
    this.completedDates = const {},
    this.reminderMinuteOfDay,
  });

  static String dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  bool scheduledOn(DateTime date) {
    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        return weekdays.contains(date.weekday);
      case HabitFrequency.monthly:
        return monthDays.contains(date.day);
    }
  }

  bool completedOn(DateTime date) => completedDates.contains(dateKey(date));

  Habit copyWith({
    String? title,
    String? notes,
    HabitFrequency? frequency,
    List<int>? weekdays,
    List<int>? monthDays,
    Set<String>? completedDates,
    int? reminderMinuteOfDay,
    bool removeReminder = false,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      frequency: frequency ?? this.frequency,
      weekdays: weekdays ?? this.weekdays,
      monthDays: monthDays ?? this.monthDays,
      completedDates: completedDates ?? this.completedDates,
      reminderMinuteOfDay:
          removeReminder ? null : (reminderMinuteOfDay ?? this.reminderMinuteOfDay),
    );
  }

  Habit setCompleted(DateTime date, bool completed) {
    final updated = <String>{...completedDates};
    final key = dateKey(date);
    if (completed) {
      updated.add(key);
    } else {
      updated.remove(key);
    }
    return copyWith(completedDates: updated);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'frequency': frequency.name,
        'weekdays': weekdays,
        'monthDays': monthDays,
        'completedDates': completedDates.toList()..sort(),
        'reminderMinuteOfDay': reminderMinuteOfDay,
      };

  factory Habit.fromJson(Map<String, dynamic> data) {
    final id = data['id'];
    final title = data['title'];
    if (id is! String || id.isEmpty || title is! String || title.trim().isEmpty) {
      throw const FormatException('Registro de hábito inválido.');
    }
    final frequencyName = data['frequency'] as String? ?? 'daily';
    final frequency = HabitFrequency.values.firstWhere(
      (value) => value.name == frequencyName,
      orElse: () => HabitFrequency.daily,
    );
    final rawWeekdays = data['weekdays'];
    final rawMonthDays = data['monthDays'];
    final rawCompletions = data['completedDates'];

    List<int> validNumbers(dynamic source, int min, int max) {
      if (source is! List) return <int>[];
      return source.whereType<int>().where((n) => n >= min && n <= max).toSet().toList()..sort();
    }

    return Habit(
      id: id,
      title: title.trim(),
      notes: data['notes'] is String ? data['notes'] as String : '',
      frequency: frequency,
      weekdays: validNumbers(rawWeekdays, 1, 7),
      monthDays: validNumbers(rawMonthDays, 1, 31),
      completedDates: rawCompletions is List
          ? rawCompletions.whereType<String>().toSet()
          : <String>{},
      reminderMinuteOfDay: data['reminderMinuteOfDay'] is int &&
              (data['reminderMinuteOfDay'] as int) >= 0 &&
              (data['reminderMinuteOfDay'] as int) < 1440
          ? data['reminderMinuteOfDay'] as int
          : null,
    );
  }

  static String encodeAll(List<Habit> habits) =>
      jsonEncode(habits.map((habit) => habit.toJson()).toList());

  static List<Habit> decodeAll(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! List) throw const FormatException('Lista de hábitos inválida.');
    return decoded
        .map((item) => Habit.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
