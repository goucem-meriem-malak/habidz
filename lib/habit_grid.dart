import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'habit.dart';

/// GitHub-style grid: 53 week-columns x 7 weekday-rows, newest on the right.
/// Always laid out left-to-right (oldest -> newest), even in RTL languages.
class HabitGrid extends StatelessWidget {
  const HabitGrid({
    super.key,
    required this.days,
    required this.accent,
    required this.onToggle,
  });

  final Set<String> days;
  final Color accent;
  final void Function(DateTime date, bool currentlyDone) onToggle;

  static const double cell = 14, gap = 3;
  static const int weeks = 53;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final empty = cs.onSurface.withAlpha(26);
    final today = dateOnly(DateTime.now());
    final thisMonday = addDays(today, -(today.weekday - 1));
    final firstMonday = addDays(thisMonday, -(weeks - 1) * 7);
    final locale = Localizations.localeOf(context).toString();
    final monthFmt = DateFormat.MMM(locale);
    const step = cell + gap;

    final columns = <Widget>[];
    final labels = <Widget>[];
    int? lastMonth;
    for (var c = 0; c < weeks; c++) {
      final start = addDays(firstMonday, c * 7);
      final label = start.month != lastMonth ? monthFmt.format(start) : '';
      lastMonth = start.month;
      labels.add(SizedBox(
        width: step,
        child: Text(label,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: TextStyle(fontSize: 10, color: cs.secondary)),
      ));

      final cells = <Widget>[];
      for (var r = 0; r < 7; r++) {
        final d = addDays(start, r);
        final future = d.isAfter(today);
        if (future) {
          cells.add(const SizedBox(width: step, height: step));
          continue;
        }
        final done = days.contains(dayKey(d));
        final isToday = d == today;
        cells.add(Semantics(
          label: '${DateFormat.yMMMMd(locale).format(d)}${done ? ", ✓" : ""}',
          button: true,
          child: GestureDetector(
            onTap: () => onToggle(d, done),
            child: Container(
              width: cell,
              height: cell,
              margin: const EdgeInsets.only(right: gap, bottom: gap),
              decoration: BoxDecoration(
                color: done ? accent : empty,
                borderRadius: BorderRadius.circular(4),
                border: isToday ? Border.all(color: accent, width: 1.6) : null,
              ),
            ),
          ),
        ));
      }
      columns.add(Column(children: cells));
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true, // opens scrolled to today (right end)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: labels),
            const SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: columns),
          ],
        ),
      ),
    );
  }
}
