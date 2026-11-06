import 'package:flutter/material.dart';

class Habit {
  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.order,
    required this.archived,
  });

  final String id;
  final String name;
  final String icon;
  final int? color; // ARGB int, null = automatic (theme accent)
  final int order;
  final bool archived;

  Color? get colorOrNull => color == null ? null : Color(color!);

  factory Habit.fromMap(String id, Map<String, dynamic> m) => Habit(
        id: id,
        name: (m['name'] ?? '') as String,
        icon: (m['icon'] ?? 'check') as String,
        color: m['color'] as int?,
        order: (m['order'] ?? 0) as int,
        archived: (m['archived'] ?? false) as bool,
      );
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

String two(int n) => n.toString().padLeft(2, '0');
String dayKey(DateTime d) => '${d.year}-${two(d.month)}-${two(d.day)}';

/// Current and best streak from a set of 'yyyy-MM-dd' keys.
({int current, int best}) computeStreaks(Set<String> days, DateTime today) {
  if (days.isEmpty) return (current: 0, best: 0);
  DateTime parse(String s) {
    final p = s.split('-');
    return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  final sorted = days.map(parse).toList()..sort();
  var best = 1, run = 1;
  for (var i = 1; i < sorted.length; i++) {
    if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
      run++;
    } else {
      run = 1;
    }
    if (run > best) best = run;
  }

  var cursor = DateTime.utc(today.year, today.month, today.day);
  if (!days.contains(dayKey(cursor))) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  var current = 0;
  while (days.contains(dayKey(cursor))) {
    current++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return (current: current, best: best);
}
