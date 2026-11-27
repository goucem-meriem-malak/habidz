import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'auth_screen.dart' show authError;
import 'brand.dart';
import 'glass.dart';
import 'habit.dart';
import 'habit_card.dart';
import 'habit_editor.dart';
import 'habit_repo.dart';
import 'l10n.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Stream<HabitsSnapshot> _stream = habitRepo.watchHabits();

  /// Order shown right after a drag, until Firestore confirms it (prevents a flicker back).
  List<String>? _localOrder;

  List<Habit> _applyLocalOrder(List<Habit> server) {
    final lo = _localOrder;
    if (lo == null) return server;
    final idx = {for (var i = 0; i < lo.length; i++) lo[i]: i};
    final sorted = [...server];
    sorted.sort((a, b) {
      final ia = idx[a.id], ib = idx[b.id];
      if (ia != null && ib != null) return ia.compareTo(ib);
      if (ia != null) return -1;
      if (ib != null) return 1;
      return a.order.compareTo(b.order);
    });
    return sorted;
  }

  void _onReorder(List<Habit> current, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final list = [...current];
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);
    setState(() => _localOrder = list.map((h) => h.id).toList());
    habitRepo.reorder(list);
  }

  Future<void> _resend() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('sent'))));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authError(context, e))));
    }
  }

  Future<void> _refreshVerified() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
    } catch (_) {}
    if (!mounted) return;
    setState(() {});
    if (!(FirebaseAuth.instance.currentUser?.emailVerified ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('verifyBanner'))));
    }
  }

  void _showVerify() {
    showGlassSheet<void>(
      context: context,
      builder: (c) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(c.t('verifyBanner'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(c.t('checkSpam')),
              const SizedBox(height: 16),
              FilledButton(onPressed: _resend, child: Text(c.t('resend'))),
              const SizedBox(height: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: () async {
                  await _refreshVerified();
                  if (c.mounted && (FirebaseAuth.instance.currentUser?.emailVerified ?? false)) {
                    Navigator.pop(c);
                  }
                },
                child: Text(c.t('iVerified')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    return GlassScaffold(
      appBar: AppBar(
        title: const BrandName(size: 15),
        actions: [
          IconButton(
            tooltip: context.t('profile'),
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      floatingActionButton: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: cs.primary.withAlpha(80), blurRadius: 24, spreadRadius: 1)],
        ),
        child: FloatingActionButton(
          tooltip: context.t('addHabit'),
          elevation: 0,
          highlightElevation: 0,
          onPressed: () => showHabitEditor(context),
          child: const Icon(Icons.add),
        ),
      ),
      body: Column(
        children: [
          if (user != null && !user.emailVerified)
            GlassCard(
              radius: 14,
              padding: EdgeInsets.zero,
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showVerify,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(children: [
                      Icon(Icons.mark_email_unread_outlined, size: 18, color: cs.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(context.t('verifyShort'),
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                      ),
                      Icon(Icons.chevron_right, size: 18, color: cs.secondary),
                    ]),
                  ),
                ),
              ),
            ),
          Expanded(
            child: StreamBuilder<HabitsSnapshot>(
              stream: _stream,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text(context.t('errGeneric')));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final visible = snap.data!.habits.where((h) => !h.archived).toList();
                final habits = _applyLocalOrder(visible);
                if (_localOrder != null &&
                    habits.map((h) => h.id).join(',') == visible.map((h) => h.id).join(',')) {
                  // the server caught up with our drag: stop overriding
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _localOrder != null) setState(() => _localOrder = null);
                  });
                }
                return Column(
                  children: [
                    _OfflineBanner(fromCache: snap.data!.fromCache),
                    Expanded(
                      child: habits.isEmpty
                          ? Center(
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.grid_view_rounded, size: 56, color: cs.secondary),
                                const SizedBox(height: 12),
                                Text(context.t('emptyTitle'),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(context.t('emptySub'), style: TextStyle(color: cs.secondary)),
                              ]),
                            )
                          : ReorderableListView.builder(
                              padding: const EdgeInsets.only(bottom: 96),
                              buildDefaultDragHandles: false,
                              itemCount: habits.length,
                              onReorderStart: (_) => HapticFeedback.mediumImpact(),
                              onReorder: (o, n) => _onReorder(habits, o, n),
                              proxyDecorator: (child, index, animation) =>
                                  Material(type: MaterialType.transparency, child: child),
                              itemBuilder: (_, i) => ReorderableDelayedDragStartListener(
                                key: ValueKey(habits[i].id),
                                index: i,
                                child: HabitCard(habit: habits[i], index: i),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows "offline / syncing" only if data stays unconfirmed for 3+ seconds,
/// so it does not flash on every normal app start.
class _OfflineBanner extends StatefulWidget {
  const _OfflineBanner({required this.fromCache});
  final bool fromCache;
  @override
  State<_OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<_OfflineBanner> {
  Timer? _timer;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _OfflineBanner old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (!widget.fromCache) {
      _timer?.cancel();
      _timer = null;
      _show = false;
    } else if (_timer == null && !_show) {
      _timer = Timer(const Duration(seconds: 3), () {
        _timer = null;
        if (mounted && widget.fromCache) setState(() => _show = true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(children: [
        Icon(Icons.cloud_off_outlined, size: 16, color: cs.secondary),
        const SizedBox(width: 6),
        Expanded(child: Text(context.t('offline'), style: TextStyle(fontSize: 12, color: cs.secondary))),
      ]),
    );
  }
}
