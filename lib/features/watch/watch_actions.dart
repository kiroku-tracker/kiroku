import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/toast.dart';
import '../../data/database/app_database.dart';
import '../../app_section.dart';
import '../../data/providers.dart';
import '../../data/database/franchise_rules.dart';
import '../player/player_screen.dart';
import '../player/watch_choice.dart';

/// Открывает тайтл для просмотра.
Future<void> watchTitle(WidgetRef ref, Anime anime) async {
  final links = await ref
      .read(watchLinksRepositoryProvider)
      .watchLinks(anime.id)
      .first;
  if (links.isNotEmpty) {
    await _open(ref, Uri.parse(links.first.url), title: anime.title);
    return;
  }
  await watchOnSite(ref, anime);
}

/// Открывает тайтл на сайте по умолчанию: в Kiroku или в браузере.
Future<void> watchOnSite(WidgetRef ref, Anime anime, {bool? inApp}) async {
  final source = ref.read(watchSourceProvider);
  final target = await source.resolve(
    shikimoriId: anime.id,
    title: anime.title,
  );
  await _open(
    ref,
    target.uri,
    title: anime.title,
    inApp: inApp,
    choice: await _choice(ref, anime),
  );
  if (!target.found) {
    ref
        .read(toastProvider.notifier)
        .show(
          'На ${source.name} тайтл не найден по номеру Shikimori, '
          'открыт поиск по названию',
        );
  }
}

Future<void> openWatchLink(WidgetRef ref, WatchLink link) =>
    _open(ref, Uri.parse(link.url), title: link.label);

/// Следующая серия и озвучка тайтла из библиотеки.
Future<WatchChoice> _choice(WidgetRef ref, Anime anime) async {
  final items = ref.read(libraryItemsProvider).value ?? const [];
  final item = items.where((item) => item.anime.id == anime.id).firstOrNull;
  if (item == null) return (episode: null, dubbing: null);
  final key = franchiseKeyOf(item.entry, item.anime);
  final franchises = await ref.read(franchisesProvider.future);
  return watchChoice(item, key == null ? null : franchises[key]);
}

Future<void> _open(
  WidgetRef ref,
  Uri uri, {
  required String title,
  bool? inApp,
  WatchChoice? choice,
}) async {
  if (inApp ?? ref.read(appPrefsProvider).value?.watchInApp ?? false) {
    final dubbing = choice?.dubbing;
    openPlayer(
      ref.read(appSectionProvider),
      uri,
      title: title,
      episode: choice?.episode,
      dubbing: dubbing == null ? null : siteDubbingLabel(dubbing),
    );
    return;
  }
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    ref.read(toastProvider.notifier).show('Не удалось открыть $uri');
  }
}

/// Окно своей ссылки.
Future<({String label, String url})?> askWatchLink(
  BuildContext context, {
  String label = '',
  String url = '',
  bool editing = false,
}) {
  final labelController = TextEditingController(text: label);
  final urlController = TextEditingController(text: url);
  String? error;
  return showDialog<({String label, String url})>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        void submit() {
          final address = urlController.text.trim();
          final uri = Uri.tryParse(address);
          if (uri == null ||
              !(uri.scheme == 'http' || uri.scheme == 'https') ||
              uri.host.isEmpty) {
            setState(
              () => error = 'Адрес должен начинаться с http:// или https://',
            );
            return;
          }
          final name = labelController.text.trim();
          Navigator.of(context)
              .pop((label: name.isEmpty ? uri.host : name, url: address));
        }

        return AlertDialog(
          title: Text(editing ? 'Своя ссылка' : 'Добавить свою ссылку'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: urlController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Адрес',
                    hintText: 'https://…',
                    errorText: error,
                  ),
                  onSubmitted: (_) => submit(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Название (необязательно)',
                    hintText: 'Например, «Озвучка AniLibria»',
                  ),
                  onSubmitted: (_) => submit(),
                ),
                const SizedBox(height: 12),
                const Text(
                  '«Смотреть» будет открывать эту ссылку.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(onPressed: submit, child: const Text('Сохранить')),
          ],
        );
      },
    ),
  ).whenComplete(() {
    labelController.dispose();
    urlController.dispose();
  });
}

Future<void> addWatchLink(
  BuildContext context,
  WidgetRef ref,
  Anime anime,
) async {
  final link = await askWatchLink(context);
  if (link == null) return;
  await ref
      .read(watchLinksRepositoryProvider)
      .add(anime.id, link.label, link.url);
  ref.read(toastProvider.notifier).show('Ссылка «${link.label}» добавлена');
}

Future<void> editWatchLink(
  BuildContext context,
  WidgetRef ref,
  WatchLink link,
) async {
  final edited = await askWatchLink(
    context,
    label: link.label,
    url: link.url,
    editing: true,
  );
  if (edited == null) return;
  await ref
      .read(watchLinksRepositoryProvider)
      .edit(link.id, edited.label, edited.url);
}

Future<void> removeWatchLink(WidgetRef ref, WatchLink link) async {
  final undo = await ref.read(watchLinksRepositoryProvider).remove(link.id);
  ref
      .read(toastProvider.notifier)
      .show('Ссылка «${link.label}» удалена', undo: undo);
}

const watchLinkIcon = LucideIcons.link;
