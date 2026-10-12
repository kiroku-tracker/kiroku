import 'package:flutter/material.dart';

/// Окно с полем ввода.
Future<String?> askText(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String initial = '',
  String hint = '',
}) async {
  final controller = TextEditingController(text: initial)
    ..selection = TextSelection(baseOffset: 0, extentOffset: initial.length);
  void submit(BuildContext context) {
    final value = controller.text.trim();
    Navigator.of(context).pop(value.isEmpty ? null : value);
  }

  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 420,
        child: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 80,
          decoration: InputDecoration(hintText: hint, counterText: ''),
          onSubmitted: (_) => submit(context),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => submit(context),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}
