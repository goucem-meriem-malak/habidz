import 'package:flutter_test/flutter_test.dart';
import 'package:habidz/habit.dart';

void main() {
  test('dayKey pads', () => expect(dayKey(DateTime(2026, 3, 4)), '2026-03-04'));

  test('streaks: current counts back from today', () {
    final today = DateTime(2026, 10, 26);
    final days = {'2026-10-26', '2026-10-25', '2026-10-24', '2026-10-20', '2026-10-19'};
    final s = computeStreaks(days, today);
    expect(s.current, 3);
    expect(s.best, 3);
  });

  test('streak survives if today not yet done', () {
    final s = computeStreaks({'2026-10-25', '2026-10-24'}, DateTime(2026, 10, 26));
    expect(s.current, 2);
  });

  test('streak broken after a gap', () {
    final s = computeStreaks({'2026-10-20'}, DateTime(2026, 10, 26));
    expect(s.current, 0);
    expect(s.best, 1);
  });
}
