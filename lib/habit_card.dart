import 'dart:async';
import 'package:flutter/material.dart';

import 'habit.dart';
import 'habit_editor.dart';
import 'habit_grid.dart';
import 'habit_repo.dart';
import 'l10n.dart';
import 'theme.dart';

/// Listens to this year's and last year's day documents of one habit.
class _DaysWatcher extends ChangeNotifier {
  _DaysWatcher(String habitId) {
    final y = DateTime.now().year;
    for (final yr in [y - 1, y]) {
      _subs.add(habitRepo.watchYear(habitId, yr).listen((s) {
        _byYear[yr] = s;
        days = _byYear.values.expand((e) => e).toSet();
        notifyListeners();
      }));
    }
  }
  final _subs = <StreamSubscription>[];
  final _byYear = <int, Set<String>>{};
  Set<String> days = {};

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}

class HabitCard extends StatefulWidget {
  const HabitCard({super.key, required this.habit});
  final Habit habit;
  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  late final _DaysWatcher _w = _DaysWatcher(widget.habit.id);

  @override
  void dispose() {
    _w.dispose();
    super.dispose();
  }

  void _toggle(DateTime d, bool done) => habitRepo.setDay(widget.habit.id, d, !done);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final h = widget.habit;
    final accent = h.colorOrNull ?? cs.primary;
    return ListenableBuilder(
      listenable: _w,
      builder: (context, _) {
        final today = dateOnly(DateTime.now());
        final doneToday = _w.days.contains(dayKey(today));
        final st = computeStreaks(_w.days, today);
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.onSurface.withAlpha(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => showHabitEditor(context, habit: h),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [
                          Icon(habitIcons[h.icon] ?? Icons.check_circle_outline, color: accent),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(h.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                                Text('${context.t('streak')} ${st.current}  ·  ${context.t('best')} ${st.best}',
                                    style: TextStyle(fontSize: 12, color: cs.secondary)),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: h.name,
                    child: InkResponse(
                      radius: 28,
                      onTap: () => _toggle(today, doneToday),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: doneToday ? accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: accent, width: 2),
                        ),
                        child: Icon(Icons.check,
                            color: doneToday
                                ? (ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
                                    ? Colors.white
                                    : Colors.black)
                                : accent.withAlpha(110)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              HabitGrid(days: _w.days, accent: accent, onToggle: _toggle),
            ],
          ),
        );
      },
    );
  }
}
