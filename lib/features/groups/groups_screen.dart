import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/card_grid.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/poster_card.dart';
import '../../core/widgets/poster_collage.dart';
import '../franchise/franchise_card.dart';
import 'group_actions.dart';
import 'group_model.dart';
import 'group_screen.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  static final _bodyHeight = PosterCard.bodyHeight(withExtra: true);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final views = ref.watch(groupViewsProvider);
    final padding = pagePadding();

    Future<void> create() async {
      final id = await createGroup(context, ref);
      if (id != null && context.mounted) openGroup(context, id);
    }

    final header = PageHeader(
      title: 'Группы',
      trailing: FilledButton.icon(
        onPressed: create,
        icon: const Icon(LucideIcons.folderPlus),
        label: const Text('Новая группа'),
      ),
    );

    return views.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Padding(
        padding: padding,
        child: Text(
          'Не удалось открыть группы: $error',
          style: const TextStyle(color: AppColors.dangerText),
        ),
      ),
      data: (views) {
        if (views.isEmpty) {
          return SingleChildScrollView(
            padding: padding,
            child: Column(
              children: [
                header,
                const SizedBox(height: 18),
                EmptyState(
                  title: 'Групп пока нет',
                  text:
                      'Свои подборки тайтлов и франшиз, например «Лучшее». '
                      'Тайтл может быть в нескольких группах.',
                  actions: [
                    OutlinedButton.icon(
                      onPressed: create,
                      icon: const Icon(LucideIcons.folderPlus),
                      label: const Text('Создать группу'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) => CustomScrollView(
            slivers: [
              SliverPadding(
                padding: padding.copyWith(bottom: 18),
                sliver: SliverToBoxAdapter(child: header),
              ),
              SliverPadding(
                padding: padding.copyWith(top: 0),
                sliver: SliverGrid.builder(
                  gridDelegate: posterGridDelegate(
                    width: constraints.maxWidth - padding.horizontal,
                    bodyHeight: _bodyHeight,
                  ),
                  itemCount: views.length,
                  itemBuilder: (context, index) =>
                      _GroupCard(view: views[index]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.view});

  final GroupView view;

  @override
  Widget build(BuildContext context) {
    final total = view.items.length;
    final average = view.averageScore;
    void open() => openGroup(context, view.group.id);
    return PosterCard(
      posterUrl: null,
      cover: PosterCollage(urls: view.coverUrls),
      title: view.group.name,
      subtitle: total == 0 ? 'Пока пусто' : view.summary,
      meta: total == 0
          ? const Text('')
          : Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Просмотрено ${view.completedCount} из $total',
                  ),
                  if (average != null) ...[
                    const TextSpan(text: '  ·  '),
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        LucideIcons.star,
                        size: 13,
                        color: Color(0xFFFFC857),
                      ),
                    ),
                    TextSpan(text: ' ${formatAverage(average)}'),
                  ],
                ],
              ),
            ),
      extra: ProgressBar(value: total == 0 ? 0 : view.completedCount / total),
      onTap: open,
      action: OutlinedButton.icon(
        onPressed: open,
        icon: const Icon(LucideIcons.folderOpen),
        label: const Text('Открыть группу'),
      ),
    );
  }
}
