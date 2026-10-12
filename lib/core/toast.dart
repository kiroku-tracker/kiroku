import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

/// Подсказка внизу окна с кнопкой «Отменить».
class ToastMessage {
  const ToastMessage(this.id, this.text, this.undo);

  final int id;
  final String text;
  final Future<void> Function()? undo;
}

class ToastNotifier extends Notifier<ToastMessage?> {
  static const visibleFor = Duration(seconds: 5);

  Timer? _timer;
  int _counter = 0;

  @override
  ToastMessage? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  void show(String text, {Future<void> Function()? undo}) {
    state = ToastMessage(++_counter, text, undo);
    _startTimer();
  }

  void hide() {
    _timer?.cancel();
    state = null;
  }

  /// Не прятать подсказку.
  void hold() => _timer?.cancel();

  /// Спрятать подсказку через 2 секунды.
  void release() => _startTimer(const Duration(seconds: 2));

  Future<void> undo() async {
    final action = state?.undo;
    hide();
    await action?.call();
  }

  void _startTimer([Duration duration = visibleFor]) {
    _timer?.cancel();
    _timer = Timer(duration, hide);
  }
}

final toastProvider = NotifierProvider<ToastNotifier, ToastMessage?>(
  ToastNotifier.new,
);

/// Слой подсказки поверх окна.
class ToastHost extends ConsumerWidget {
  const ToastHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(toastProvider);
    return Stack(
      children: [
        child,
        Positioned(
          right: 20,
          bottom: 20,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.25),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: message == null
                ? const SizedBox.shrink()
                : _ToastCard(key: ValueKey(message.id), message: message),
          ),
        ),
      ],
    );
  }
}

class _ToastCard extends ConsumerWidget {
  const _ToastCard({super.key, required this.message});

  final ToastMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(toastProvider.notifier);
    return MouseRegion(
      onEnter: (_) => notifier.hold(),
      onExit: (_) => notifier.release(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.toast,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.toastBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x73000000),
              blurRadius: 48,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 8, 8, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        message.text,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (message.undo != null)
                    TextButton.icon(
                      onPressed: notifier.undo,
                      icon: const Icon(LucideIcons.undo2, size: 16),
                      label: const Text('Отменить'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.toastAction,
                        iconColor: AppColors.toastAction,
                        textStyle: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: notifier.hide,
                    tooltip: 'Закрыть',
                    iconSize: 16,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
