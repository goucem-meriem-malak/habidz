import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'habit.dart';

class HabitsSnapshot {
  HabitsSnapshot(this.habits, this.fromCache);
  final List<Habit> habits;
  final bool fromCache; // true while offline / not yet confirmed by server
}

/// All Firestore access for habits. Writes are NOT awaited by the UI: when
/// offline, Firestore applies them locally at once and syncs later (a write
/// Future only completes once the server confirms).
class HabitRepo {
  final _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _user => _db.collection('users').doc(_uid);
  CollectionReference<Map<String, dynamic>> get _habits => _user.collection('habits');

  Stream<HabitsSnapshot> watchHabits() => _habits.orderBy('order').snapshots(includeMetadataChanges: true).map(
        (s) => HabitsSnapshot(
          s.docs.map((d) => Habit.fromMap(d.id, d.data())).toList(),
          s.metadata.isFromCache,
        ),
      );

  /// Completed days of one year as full 'yyyy-MM-dd' keys.
  Stream<Set<String>> watchYear(String habitId, int year) =>
      _habits.doc(habitId).collection('years').doc('$year').snapshots().map((s) {
        final days = (s.data()?['days'] as Map<String, dynamic>?) ?? {};
        return days.keys.map((k) => '$year-$k').toSet();
      });

  void createHabit({required String name, required String icon, int? color}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    _habits.doc().set({
      'name': name.trim(),
      'icon': icon,
      'color': color,
      'order': now,
      'archived': false,
      'createdAt': now,
      'updatedAt': now,
    }).catchError((_) {});
  }

  void updateHabit(Habit h, {required String name, required String icon, int? color, required bool archived}) {
    _habits.doc(h.id).set({
      'name': name.trim(),
      'icon': icon,
      'color': color,
      'order': h.order,
      'archived': archived,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true)).catchError((_) {});
  }

  void setDay(String habitId, DateTime date, bool done) {
    final key = '${two(date.month)}-${two(date.day)}';
    _habits.doc(habitId).collection('years').doc('${date.year}').set({
      'days': {key: done ? true : FieldValue.delete()},
    }, SetOptions(merge: true)).catchError((_) {});
  }

  void deleteHabit(String habitId) {
    // Fire-and-forget; years docs are removed too.
    () async {
      final years = await _habits.doc(habitId).collection('years').get();
      final b = _db.batch();
      for (final y in years.docs) {
        b.delete(y.reference);
      }
      b.delete(_habits.doc(habitId));
      await b.commit();
    }();
  }

  void saveDisplayName(String name) {
    _user.set({'displayName': name, 'schemaVersion': 1}, SetOptions(merge: true)).catchError((_) {});
  }

  void createUserDoc(String name) {
    _user.set({
      'displayName': name,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'schemaVersion': 1,
    }).catchError((_) {});
  }

  /// Everything the user owns, as plain JSON-able data (needs data in cache or network).
  Future<Map<String, dynamic>> exportAll() async {
    final user = FirebaseAuth.instance.currentUser!;
    final out = <String, dynamic>{
      'email': user.email,
      'displayName': user.displayName,
      'exportedAt': DateTime.now().toIso8601String(),
      'habits': <Map<String, dynamic>>[],
    };
    final hs = await _habits.get();
    for (final h in hs.docs) {
      final ys = await h.reference.collection('years').get();
      out['habits'].add({
        ...h.data(),
        'id': h.id,
        'years': {for (final y in ys.docs) y.id: (y.data()['days'] as Map?)?.keys.toList() ?? []},
      });
    }
    return out;
  }

  /// Deletes ALL cloud data of the current user (not the Auth user). Needs network.
  Future<void> deleteAllUserData() async {
    final hs = await _habits.get(const GetOptions(source: Source.server));
    for (final h in hs.docs) {
      final ys = await h.reference.collection('years').get(const GetOptions(source: Source.server));
      final b = _db.batch();
      for (final y in ys.docs) {
        b.delete(y.reference);
      }
      b.delete(h.reference);
      await b.commit();
    }
    await _user.delete();
  }
}

final habitRepo = HabitRepo();
