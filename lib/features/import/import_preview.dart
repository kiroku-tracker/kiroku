import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/status_style.dart';
import '../../core/widgets/app_menu_anchor.dart';
import '../../core/widgets/poster.dart';
import '../../core/widgets/status_menu.dart';
import '../../data/database/watch_status.dart';
import '../../data/import/import_plan.dart';
import 'import_controller.dart';
import 'import_edit_dialogs.dart';

/// Цвета группы переноса.
class _GroupStyle {
  const _GroupStyle(this.border, this.text, this.background, this.label);

  final Color border;
  final Color text;
  final Color background;
  final String label;

  static _GroupStyle of(ImportGroup group) => switch (group) {
    ImportGroup.add => const _GroupStyle(
      AppColors.accent,
      AppColors.accentText,
      Color(0xFF221D3D),
      'Добавятся',
    ),
    ImportGroup.existing => const _GroupStyle(
      Color(0xFF5A86B8),
      Color(0xFF8FB3D9),
      Color(0xFF1D2733),
      'Уже есть в Kiroku',
    ),
    ImportGroup.notFound => const _GroupStyle(
      Color(0xFFD99A4E),
      Color(0xFFE8B36A),
      Color(0xFF33281A),
      'Не найдены',
    ),
  };
}

/// Плитки групп, карточки тайтлов и галочка замены.
class ImportPreview extends ConsumerStatefulWidget {
  const ImportPreview({super.key});

  @override
  ConsumerState<ImportPreview> createState() => _ImportPreviewState();
}

class _ImportPreviewState extends ConsumerState<ImportPreview> {
  var _group = ImportGroup.add;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importControllerProvider);
    if (state == null) return const SizedBox.shrink();
    final groups = [
      for (final group in ImportGroup.values)
        if (group != ImportGroup.notFound || state.count(group) > 0) group,
    ];
    final shown = groups.contains(_group) ? _group : ImportGroup.add;
    final indexes = [
      for (var i = 0; i < state.items.length; i++)
        if (state.groupOf(i) == shown) i,
    ];
    final existing = state.count(ImportGroup.existing);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final group in groups) ...[
              Expanded(
                child: _Plate(
                  group: group,
                  number: group == ImportGroup.add
                      ? state.selectedIn(group)
                      : state.count(group),
                  selected: group == shown,
                  onTap: () => setState(() => _group = group),
                ),
              ),
              if (group != groups.last) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 14),
        _CardGrid(
          indexes: indexes,
          state: state,
          tall: shown == ImportGroup.existing,
        ),
        if (existing > 0) ...[
          const SizedBox(height: 14),
          InkWell(
            onTap: () => ref
                .read(importControllerProvider.notifier)
                .setReplace(!state.replace),
            child: Row(
              children: [
                Checkbox(
                  value: state.replace,
                  onChanged: (value) => ref
                      .read(importControllerProvider.notifier)
                      .setReplace(value ?? false),
                ),
                Expanded(
                  child: Text(
                    'Заменить данными ${state.plan.sourceName} $existing '
                    '${plural(existing, 'тайтл', 'тайтла', 'тайтлов')}, '
                    '${plural(existing, 'который', 'которые', 'которые')} '
                    'уже есть в Kiroku',
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Ленивая сетка карточек: строит только видимые и не выше окна.
class _CardGrid extends StatelessWidget {
  const _CardGrid({
    required this.indexes,
    required this.state,
    required this.tall,
  });

  static const _spacing = 12.0;
  static const _cell = _ImportCard.width;
  static const _rowHeight = 284.0;
  static const _tallRowHeight = 352.0;

  final List<int> indexes;
  final ImportState state;

  /// В «Уже есть» подписей больше: статус в Kiroku и в источнике.
  final bool tall;

  @override
  Widget build(BuildContext context) {
    final rowHeight = tall ? _tallRowHeight : _rowHeight;
    if (indexes.isEmpty) return const SizedBox.shrink();
    // Остальное окно (заголовок, плитки, галочка замены, кнопки) занимает
    // около 440 px.
    final limit = (MediaQuery.sizeOf(context).height - 440).clamp(
      rowHeight / 2,
      420.0,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / (_cell + _spacing)).ceil();
        final rows = (indexes.length / columns).ceil();
        final content = rows * rowHeight + (rows - 1) * _spacing;
        return SizedBox(
          height: content < limit ? content : limit,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: _cell,
              mainAxisExtent: rowHeight,
              crossAxisSpacing: _spacing,
              mainAxisSpacing: _spacing,
            ),
            itemCount: indexes.length,
            itemBuilder: (context, i) =>
                _ImportCard(index: indexes[i], state: state),
          ),
        );
      },
    );
  }
}

class _Plate extends StatelessWidget {
  const _Plate({
    required this.group,
    required this.number,
    required this.selected,
    required this.onTap,
  });

  final ImportGroup group;
  final int number;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _GroupStyle.of(group);
    return InkWell(
      key: ValueKey('plate-${group.name}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? style.background : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? style.border : AppColors.panelBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$number',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: style.text,
              ),
            ),
            Text(
              style.label,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportCard extends ConsumerWidget {
  const _ImportCard({required this.index, required this.state});

  static const width = 124.0;

  final int index;
  final ImportState state;

  String _progress(ImportItem item) {
    final marked = item.episodesMarked;
    if (marked == 0) return '';
    final total = item.anime?.release.availableEpisodes ?? 0;
    return total > 0 ? '$marked из $total' : episodesLabel(marked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(importControllerProvider.notifier);
    final item = state.items[index];
    final group = state.groupOf(index);
    final style = _GroupStyle.of(group);
    final inLibrary = state.libraryStatus(index);
    final lost = group == ImportGroup.notFound;

    final menu = <Widget>[
      if (lost)
        _menuItem(
          'Выбрать тайтл…',
          LucideIcons.search,
          AppColors.accentText,
          () async {
            final anime = await pickAnime(context, initial: item.sourceTitle);
            if (anime != null) controller.match(index, anime);
          },
        )
      else ...[
        for (final status in WatchStatus.values)
          _menuItem(
            status.label,
            StatusStyle.of(status).icon,
            StatusStyle.of(status).foreground,
            () => controller.setStatus(index, status),
            checked: item.status == status,
          ),
        const Divider(height: 9, thickness: 1, color: Color(0xFF35323C)),
        _menuItem(
          item.favorite ? 'Убрать из избранного' : 'В избранное',
          LucideIcons.heart,
          AppColors.favorite,
          () => controller.setFavorite(index, !item.favorite),
        ),
        _menuItem(
          'Отмеченные серии…',
          LucideIcons.listChecks,
          AppColors.textSecondary,
          () async {
            final count = await askEpisodeCount(
              context,
              current: item.episodesMarked,
              total: item.anime?.release.availableEpisodes ?? 0,
            );
            if (count != null) controller.setEpisodes(index, count);
          },
        ),
      ],
    ];

    return AppMenuAnchor(
      style: AppTheme.menuStyle,
      alignmentOffset: const Offset(0, 4),
      menuChildren: menu,
      builder: (context, menuController, _) => Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(9),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => menuController.isOpen
              ? menuController.close()
              : menuController.open(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 3, color: style.border),
              Stack(
                children: [
                  if (lost)
                    const AspectRatio(
                      aspectRatio: 2 / 3,
                      child: ColoredBox(
                        color: AppColors.poster,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'нет на Shikimori',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.posterPlaceholder,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Poster(url: item.anime?.posterUrl),
                  if (!lost)
                    Positioned(
                      left: 6,
                      top: 6,
                      child: ImportTick(
                        value: state.isChecked(index),
                        onChanged: () => controller.toggle(index),
                      ),
                    ),
                  if (item.favorite)
                    const Positioned(right: 6, top: 6, child: _Heart()),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                child: SizedBox(
                  height: 34,
                  child: Text(
                    item.anime?.title ?? item.sourceTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                child: group == ImportGroup.existing
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'В Kiroku: ${inLibrary?.label ?? ''}',
                            style: _small,
                          ),
                          Text(
                            'В ${state.plan.sourceName}: ${item.status.label}',
                            style: _small,
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.status.label, style: _small),
                          Text(_progress(item), style: _small),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _small = TextStyle(color: AppColors.muted, fontSize: 11.5);

  Widget _menuItem(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool checked = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: AppMenuItem(
      label: label,
      icon: icon,
      color: color,
      checked: checked,
      onPressed: onPressed,
    ),
  );
}

/// Круглая отметка на постере: переносить тайтл или нет.
class ImportTick extends StatelessWidget {
  const ImportTick({super.key, required this.value, required this.onChanged});

  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      child: Material(
        color: value ? AppColors.accent : Colors.black.withValues(alpha: 0.45),
        shape: CircleBorder(
          side: BorderSide(
            color: value ? AppColors.accent : Colors.white,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onChanged,
          child: SizedBox.square(
            dimension: 24,
            child: value
                ? const Icon(LucideIcons.check, size: 15, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }
}

class _Heart extends StatelessWidget {
  const _Heart();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      child: const Icon(LucideIcons.heart, size: 12, color: AppColors.favorite),
    );
  }
}
