import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'habit.dart';

/// GitHub-style grid: 53 week-columns x 7 weekday-rows, newest on the right.
/// Always laid out left-to-right (oldest -> newest), even in RTL languages.
///
/// Performance: all 371 squares are drawn by ONE CustomPainter inside a
/// RepaintBoundary (instead of 371 widgets), so vertical list scrolling stays smooth.
class HabitGrid extends StatelessWidget {
  const HabitGrid({
    super.key,
    required this.days,
    required this.accent,
    required this.onToggle,
    this.semanticLabel,
  });

  final Set<String> days;
  final Color accent;
  final void Function(DateTime date, bool currentlyDone) onToggle;
  final String? semanticLabel;

  static const double cell = 14, gap = 3, step = cell + gap, labelH = 18;
  static const int weeks = 53;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final empty = cs.onSurface.withAlpha(26);
    final today = dateOnly(DateTime.now());
    final thisMonday = addDays(today, -(today.weekday - 1));
    final firstMonday = addDays(thisMonday, -(weeks - 1) * 7);
    final monthFmt = DateFormat.MMM(Localizations.localeOf(context).toString());

    final labels = <Widget>[];
    int? lastMonth;
    for (var c = 0; c < weeks; c++) {
      final start = addDays(firstMonday, c * 7);
      if (start.month != lastMonth) {
        labels.add(Positioned(
          left: c * step,
          top: 0,
          child: Text(monthFmt.format(start),
              softWrap: false, style: TextStyle(fontSize: 10, color: cs.secondary)),
        ));
      }
      lastMonth = start.month;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true, // opens scrolled to today (right end)
        child: SizedBox(
          width: weeks * step + 16,
          height: labelH + 7 * step,
          child: Stack(
            children: [
              ...labels,
              Positioned(
                left: 0,
                top: labelH,
                width: weeks * step,
                height: 7 * step,
                child: Semantics(
                  label: semanticLabel,
                  child: RepaintBoundary(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (d) {
                        final c = d.localPosition.dx ~/ step;
                        final r = d.localPosition.dy ~/ step;
                        if (c < 0 || c >= weeks || r < 0 || r > 6) return;
                        final date = addDays(firstMonday, c * 7 + r);
                        if (date.isAfter(today)) return;
                        onToggle(date, days.contains(dayKey(date)));
                      },
                      child: CustomPaint(
                        painter: _GridPainter(
                          days: days,
                          firstMonday: firstMonday,
                          today: today,
                          accent: accent,
                          empty: empty,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({
    required this.days,
    required this.firstMonday,
    required this.today,
    required this.accent,
    required this.empty,
  });

  final Set<String> days;
  final DateTime firstMonday, today;
  final Color accent, empty;

  @override
  void paint(Canvas canvas, Size size) {
    const cell = HabitGrid.cell, step = HabitGrid.step;
    final fill = Paint();
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = accent;
    for (var c = 0; c < HabitGrid.weeks; c++) {
      for (var r = 0; r < 7; r++) {
        final d = addDays(firstMonday, c * 7 + r);
        if (d.isAfter(today)) continue;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(c * step, r * step, cell, cell),
          const Radius.circular(4),
        );
        fill.color = days.contains(dayKey(d)) ? accent : empty;
        canvas.drawRRect(rect, fill);
        if (d == today) canvas.drawRRect(rect, ring);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.days != days ||
      old.accent != accent ||
      old.empty != empty ||
      old.today != today ||
      old.firstMonday != firstMonday;
}
