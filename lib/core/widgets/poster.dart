import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/providers.dart';
import '../../data/shikimori/anime_info.dart';
import '../poster_cache.dart';
import '../theme/app_colors.dart';

/// Постер тайтла; с настройкой «Постеры в полном размере» берётся оригинал.
class Poster extends ConsumerWidget {
  const Poster({
    super.key,
    required this.url,
    this.borderRadius = BorderRadius.zero,
  });

  final String? url;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const placeholder = ColoredBox(
      color: AppColors.poster,
      child: Center(
        child: Icon(
          LucideIcons.imageOff,
          color: AppColors.posterPlaceholder,
          size: 28,
        ),
      ),
    );
    final url = this.url;
    final originals = ref.watch(
      appPrefsProvider.select((prefs) => prefs.value?.posterOriginals ?? false),
    );
    final original = originals && url != null
        ? ref.watch(posterOriginalsProvider.select((map) => map.value?[url])) ??
              knownPosterOriginals[url]
        : null;
    final source = original ?? url;
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: source == null || source.isEmpty
            ? placeholder
            : ColoredBox(
                color: AppColors.poster,
                child: LayoutBuilder(
                  builder: (context, constraints) => Image(
                    image: ResizeImage.resizeIfNeeded(
                      null,
                      _decodeHeight(context, constraints),
                      PosterImage(source),
                    ),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    frameBuilder: (context, child, frame, loadedSync) =>
                        loadedSync
                        ? child
                        : AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: child,
                          ),
                    errorBuilder: (_, _, _) => placeholder,
                  ),
                ),
              ),
      ),
    );
  }

  /// Высота, до которой картинка уменьшается при загрузке: размер на экране
  /// в точках монитора, чтобы большие постеры не занимали лишнюю память.
  static int? _decodeHeight(BuildContext context, BoxConstraints constraints) {
    final height = constraints.maxHeight;
    if (!height.isFinite || height <= 0) return null;
    return (height * MediaQuery.devicePixelRatioOf(context)).ceil();
  }
}
