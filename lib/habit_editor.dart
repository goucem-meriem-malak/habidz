import 'package:flutter/material.dart';

import 'habit.dart';
import 'habit_repo.dart';
import 'l10n.dart';
import 'theme.dart';

Future<void> showHabitEditor(BuildContext context, {Habit? habit}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _Editor(habit: habit),
  );
}

class _Editor extends StatefulWidget {
  const _Editor({this.habit});
  final Habit? habit;
  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late final _name = TextEditingController(text: widget.habit?.name ?? '');
  late String _icon = widget.habit?.icon ?? 'check';
  late int? _color = widget.habit?.color;
  late bool _archived = widget.habit?.archived ?? false;
  bool _showErr = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      setState(() => _showErr = true);
      return;
    }
    final h = widget.habit;
    if (h == null) {
      habitRepo.createHabit(name: _name.text, icon: _icon, color: _color);
    } else {
      habitRepo.updateHabit(h, name: _name.text, icon: _icon, color: _color, archived: _archived);
    }
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(c.t('deleteHabitQ')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(c.t('cancel'))),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(c.t('delete'))),
        ],
      ),
    );
    if (ok == true && mounted) {
      habitRepo.deleteHabit(widget.habit!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.t(widget.habit == null ? 'addHabit' : 'editHabit'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            TextField(
              controller: _name,
              maxLength: 40,
              autofocus: widget.habit == null,
              decoration: InputDecoration(
                labelText: context.t('habitName'),
                errorText: _showErr ? context.t('errRequired') : null,
              ),
            ),
            Text(context.t('icon'), style: TextStyle(color: cs.secondary)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final e in habitIcons.entries)
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    setState(() => _icon = e.key);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: _icon == e.key ? cs.primary.withAlpha(40) : null,
                      border: Border.all(color: _icon == e.key ? cs.primary : cs.onSurface.withAlpha(30)),
                    ),
                    child: Icon(e.value),
                  ),
                ),
            ]),
            const SizedBox(height: 16),
            Text(context.t('color'), style: TextStyle(color: cs.secondary)),
            const SizedBox(height: 8),
            Wrap(spacing: 10, runSpacing: 10, children: [
              ChoiceChip(
                label: Text(context.t('auto')),
                selected: _color == null,
                onSelected: (_) => setState(() => _color = null),
              ),
              for (final c in habitPalette)
                GestureDetector(
                  onTap: () => setState(() => _color = c.toARGB32()),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _color == c.toARGB32() ? cs.onSurface : Colors.transparent, width: 2.5),
                    ),
                  ),
                ),
            ]),
            if (widget.habit != null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.t('archive')),
                value: _archived,
                onChanged: (v) => setState(() => _archived = v),
              ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: Text(context.t('save'))),
            if (widget.habit != null)
              TextButton(
                onPressed: _delete,
                child: Text(context.t('delete'), style: TextStyle(color: cs.error)),
              ),
          ],
        ),
      ),
    );
  }
}
