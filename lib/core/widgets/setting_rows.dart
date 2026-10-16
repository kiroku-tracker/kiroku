import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Пояснение под строками панели.
class SettingNote extends StatelessWidget {
  const SettingNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.muted, fontSize: 13),
      ),
    );
  }
}

/// Строка настройки с переключателем.
class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.title,
    required this.text,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.sub = false,
  });

  final String title;
  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;

  final bool enabled;

  final bool sub;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    return _RowLayout(
      title: title,
      text: text,
      sub: sub,
      control: Switch(value: value, onChanged: onChanged),
    );
  }
}

/// Строка настройки с выбором.
class ChoiceRow extends StatelessWidget {
  const ChoiceRow({
    super.key,
    required this.title,
    required this.text,
    required this.control,
    this.enabled = true,
    this.sub = false,
  });

  final String title;
  final String text;
  final Widget control;

  final bool enabled;

  final bool sub;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    return _RowLayout(title: title, text: text, sub: sub, control: control);
  }
}

/// Название, пояснение и элемент управления; поднастройка с отступом и
/// линией слева.
class _RowLayout extends StatelessWidget {
  const _RowLayout({
    required this.title,
    required this.text,
    required this.sub,
    required this.control,
  });

  final String title;
  final String text;
  final bool sub;
  final Widget control;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: EdgeInsets.fromLTRB(sub ? 14 : 8, 10, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: sub ? 14 : 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          control,
        ],
      ),
    );
    if (!sub) return row;
    return Padding(
      padding: const EdgeInsets.only(left: 18),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.panelBorder, width: 2),
          ),
        ),
        child: row,
      ),
    );
  }
}
