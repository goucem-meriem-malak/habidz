import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'auth_screen.dart' show authError;
import 'habit_repo.dart';
import 'l10n.dart';
import 'settings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User get _user => FirebaseAuth.instance.currentUser!;

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<List<String>?> _ask(String title, List<String> labels, {bool obscure = true, List<String>? initial}) {
    final ctrls = [for (var i = 0; i < labels.length; i++) TextEditingController(text: initial?[i] ?? '')];
    return showDialog<List<String>>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < labels.length; i++) ...[
              TextField(
                controller: ctrls[i],
                obscureText: obscure,
                decoration: InputDecoration(labelText: labels[i]),
              ),
              const SizedBox(height: 10),
            ]
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(c.t('cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(c, ctrls.map((e) => e.text).toList()),
              child: Text(c.t('confirm'))),
        ],
      ),
    );
  }

  Future<void> _editName() async {
    final r = await _ask(context.t('name'), [context.t('name')], obscure: false, initial: [_user.displayName ?? '']);
    final name = r?.first.trim() ?? '';
    if (name.isEmpty) return;
    try {
      await _user.updateDisplayName(name);
      habitRepo.saveDisplayName(name);
      if (mounted) setState(() {});
    } catch (e) {
      _snack(authError(context, e));
    }
  }

  Future<void> _changePw() async {
    final r = await _ask(context.t('changePw'), [context.t('currentPw'), context.t('newPw')]);
    if (r == null) return;
    if (r[1].length < 8) return _snack(context.t('errWeak'));
    try {
      await _user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: _user.email!, password: r[0]));
      await _user.updatePassword(r[1]);
      _snack(context.t('pwChanged'));
    } catch (e) {
      _snack(authError(context, e));
    }
  }

  Future<void> _export() async {
    try {
      final data = await habitRepo.exportAll();
      await Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('  ').convert(data)));
      _snack(context.t('exported'));
    } catch (_) {
      _snack(context.t('errGeneric'));
    }
  }

  Future<void> _deleteAccount() async {
    final r = await _ask(context.t('deleteAcc'), [context.t('password')]);
    if (r == null || r[0].isEmpty) return;
    final sure = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(c.t('deleteAcc')),
        content: Text(c.t('deleteWarn')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(c.t('cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(c.t('delete'), style: TextStyle(color: Theme.of(c).colorScheme.error))),
        ],
      ),
    );
    if (sure != true) return;
    try {
      // 1) Re-authenticate first: needs network, so an offline attempt aborts before any deletion.
      await _user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: _user.email!, password: r[0]));
      // 2) Delete all cloud data, 3) then the Auth user. Safe to retry if interrupted.
      await habitRepo.deleteAllUserData();
      await _user.delete();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      _snack(authError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget section(String k) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
          child: Text(context.t(k), style: TextStyle(color: cs.secondary, fontWeight: FontWeight.w700)),
        );
    final themes = {'system': 'tSystem', 'light': 'tLight', 'dark': 'tDark', 'purple': 'tPurple'};
    const langs = {'en': 'English', 'fr': 'Français', 'ar': 'العربية'};
    return Scaffold(
      appBar: AppBar(title: Text(context.t('profile'))),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => ListView(
          children: [
            section('accountSection'),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(_user.displayName ?? ''),
              subtitle: Text(_user.email ?? ''),
              trailing: IconButton(icon: const Icon(Icons.edit_outlined), tooltip: context.t('edit'), onPressed: _editName),
            ),
            section('appearance'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                for (final e in themes.entries)
                  ChoiceChip(
                    label: Text(context.t(e.value)),
                    selected: settings.theme == e.key,
                    onSelected: (_) => settings.setTheme(e.key),
                  ),
              ]),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                for (final e in langs.entries)
                  ChoiceChip(
                    label: Text(e.value),
                    selected: settings.lang == e.key,
                    onSelected: (_) => settings.setLang(e.key),
                  ),
              ]),
            ),
            const Divider(height: 32),
            ListTile(leading: const Icon(Icons.lock_outline), title: Text(context.t('changePw')), onTap: _changePw),
            ListTile(leading: const Icon(Icons.ios_share), title: Text(context.t('export')), onTap: _export),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(context.t('logout')),
              onTap: () async {
                Navigator.of(context).popUntil((r) => r.isFirst);
                await FirebaseAuth.instance.signOut();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_forever_outlined, color: cs.error),
              title: Text(context.t('deleteAcc'), style: TextStyle(color: cs.error)),
              onTap: _deleteAccount,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
