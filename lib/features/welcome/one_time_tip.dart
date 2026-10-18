import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_section.dart';
import '../../core/theme/app_colors.dart';
import 'welcome_state.dart';

/// Разовая подсказка рядом с элементом: показывается один раз, по одной за
/// раз и только на открытом экране, после знакомства с Kiroku.
class OneTimeTip extends ConsumerStatefulWidget {
  const OneTimeTip({
    super.key,
    required this.id,
    required this.text,
    required this.child,
    this.targetAnchor = Alignment.bottomLeft,
    this.followerAnchor = Alignment.topLeft,
    this.offset = const Offset(0, 8),
  });

  final String id;
  final String text;
  final Widget child;

  /// Точка элемента, к которой крепится подсказка.
  final Alignment targetAnchor;

  /// Точка подсказки, которая совпадает с [targetAnchor].
  final Alignment followerAnchor;
  final Offset offset;

  @override
  ConsumerState<OneTimeTip> createState() => _OneTimeTipState();
}

class _OneTimeTipState extends ConsumerState<OneTimeTip> {
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  late final TipsNotifier _tips;

  /// Подсказка была на экране при последней сборке.
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    _tips = ref.read(tipsProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _portal.show();
    });
  }

  @override
  void dispose() {
    if (_shown) {
      final id = widget.id;
      final tips = _tips;
      scheduleMicrotask(() => tips.release(id));
    }
    super.dispose();
  }

  /// Экран с подсказкой сейчас виден: открыт его раздел и он верхний.
  bool _onScreen(BuildContext context) {
    final navigator = Navigator.maybeOf(context);
    final section = ref.watch(appSectionProvider);
    return navigator != null &&
        sectionNavigatorKeys[section]?.currentState == navigator &&
        (ModalRoute.of(context)?.isCurrent ?? true);
  }

  void _later(void Function() action) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) action();
      });

  @override
  Widget build(BuildContext context) {
    final introduced = ref.watch(welcomeProvider).value?.seen.isNotEmpty;
    final tips = ref.watch(tipsProvider).value;
    final eligible =
        introduced == true &&
        tips != null &&
        !tips.seen.contains(widget.id) &&
        _onScreen(context);
    final active = tips?.active == widget.id;
    if (eligible && tips.active == null) {
      _later(() => _tips.request(widget.id));
    } else if (!eligible && active) {
      _later(() => _tips.release(widget.id));
    }
    final show = eligible && active;
    _shown = active;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (_) => Positioned(
          left: 0,
          top: 0,
          child: show
              ? CompositedTransformFollower(
                  link: _link,
                  showWhenUnlinked: false,
                  targetAnchor: widget.targetAnchor,
                  followerAnchor: widget.followerAnchor,
                  offset: widget.offset,
                  child: _Bubble(
                    text: widget.text,
                    onClose: () => _tips.dismiss(widget.id),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        child: widget.child,
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.onClose});

  final String text;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Material(
        color: AppColors.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.accentHover),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onClose,
                  style: TextButton.styleFrom(foregroundColor: Colors.white)
                      .copyWith(
                        foregroundColor: const WidgetStatePropertyAll(
                          Colors.white,
                        ),
                      ),
                  child: const Text('Понятно'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
