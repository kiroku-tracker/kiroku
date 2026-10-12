import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/panel.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';

/// Заметка о тайтле.
class NotePanel extends ConsumerStatefulWidget {
  const NotePanel({super.key, required this.entry});

  final LibraryEntry entry;

  @override
  ConsumerState<NotePanel> createState() => _NotePanelState();
}

class _NotePanelState extends ConsumerState<NotePanel> {
  static const _saveDelay = Duration(milliseconds: 800);

  late final TextEditingController _note = TextEditingController(
    text: widget.entry.note,
  );
  final _focus = FocusNode();
  Timer? _saveTimer;
  bool _saved = false;

  @override
  void didUpdateWidget(NotePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus && widget.entry.note != _note.text) {
      _note.text = widget.entry.note;
    }
  }

  @override
  void dispose() {
    if (_saveTimer?.isActive ?? false) {
      _saveTimer!.cancel();
      _saveNote();
    }
    _note.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    _saveTimer?.cancel();
    setState(() => _saved = false);
    _saveTimer = Timer(_saveDelay, () async {
      await _saveNote();
      if (mounted) setState(() => _saved = true);
    });
  }

  Future<void> _saveNote() => ref
      .read(libraryRepositoryProvider)
      .setNote(widget.entry.animeId, _note.text.trim());

  @override
  Widget build(BuildContext context) {
    return Panel(
      title: 'Заметка',
      trailing: AnimatedOpacity(
        opacity: _saved ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: const Text(
          'Сохранено',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ),
      child: TextField(
        controller: _note,
        focusNode: _focus,
        onChanged: _onChanged,
        minLines: 3,
        maxLines: 10,
        decoration: const InputDecoration(
          hintText: 'Мысли о тайтле, с кем смотреть, на чём остановились',
        ),
      ),
    );
  }
}
