import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/toast.dart';
import '../../data/database/app_database.dart';
import '../../data/database/franchise_rules.dart';
import '../../data/database/settings_repository.dart';
import '../../data/providers.dart';
import '../../data/watch/dubbing_rules.dart';
import '../../data/watch/site_episodes_repository.dart';
import 'alert_rules.dart';

const _explanation =
    'Уведомление придёт, когда серия выйдет на YummyAnime в этой озвучке. '
    '«Автоматически»: озвучка последнего просмотра.';

/// Окно озвучки тайтла.
Future<void> showTitleDubbingDialog(
  BuildContext context, {
  required Anime anime,
  required LibraryEntry entry,
}) => showDialog<void>(
  context: context,
  builder: (_) => _TitleDubbingDialog(anime: anime, entry: entry),
);

class _TitleDubbingDialog extends ConsumerWidget {
  const _TitleDubbingDialog({required this.anime, required this.entry});

  final Anime anime;
  final LibraryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final franchises = ref.watch(franchisesProvider).value ?? const {};
    final franchise = franchises[franchiseKeyOf(entry, anime)];
    final prefs = ref.watch(appPrefsProvider).value ?? const AppPrefs();
    final auto = effectiveDubbing(
      entry.copyWith(dubbing: const Value(null)),
      franchise,
    );
    final library = ref.read(libraryRepositoryProvider);
    final on = episodeAlerts(entry, prefs);
    final byDefault = episodeAlertsByDefault(entry, prefs);
    return _DubbingDialog(
      title: 'Уведомления: ${anime.title}',
      current: entry.dubbing,
      alerts: on,
      alertsByDefault: byDefault,
      alertsTitle: 'Уведомлять о новых сериях',
      autoDetail: switch (auto?.source) {
        null => 'пока не известна',
        DubbingSource.franchise => 'как у франшизы: ${auto!.name}',
        DubbingSource.seen => 'по просмотру: ${auto!.name}',
        DubbingSource.franchiseSeen => 'по франшизе: ${auto!.name}',
        DubbingSource.title => auto!.name,
      },
      noneDetail: prefs.episodeAlert.label.toLowerCase(),
      load: () async {
        final site = ref.read(siteEpisodesRepositoryProvider);
        await site.refresh(anime.id);
        return (await site.read(anime.id)).byDubbing;
      },
      onSave: (value, alerts) async {
        final changes = <String>[];
        if (value != entry.dubbing) {
          await library.setDubbing(anime.id, value);
          changes.add(_describe(value));
        }
        final alertsChanged = alerts != null && alerts != on;
        if (alertsChanged) {
          final flags = alertFlags(on: alerts, byDefault: byDefault);
          await library.setAlerts(
            anime.id,
            muted: flags.muted,
            alertsOn: flags.alertsOn,
          );
          changes.add(
            alerts
                ? 'уведомления о сериях включены'
                : 'уведомлений о сериях не будет',
          );
        }
        return (
          text: '«${anime.title}»: ${changes.join(', ')}',
          undo: () async {
            if (value != entry.dubbing) {
              await library.setDubbing(anime.id, entry.dubbing);
            }
            if (alertsChanged) {
              await library.setAlerts(
                anime.id,
                muted: entry.muted,
                alertsOn: entry.alertsOn,
              );
            }
          },
        );
      },
    );
  }
}

/// Окно озвучки франшизы.
Future<void> showFranchiseDubbingDialog(
  BuildContext context, {
  required String franchiseKey,
  required String name,
  required List<int> partIds,
}) => showDialog<void>(
  context: context,
  builder: (_) => _FranchiseDubbingDialog(
    franchiseKey: franchiseKey,
    name: name,
    partIds: partIds,
  ),
);

class _FranchiseDubbingDialog extends ConsumerWidget {
  const _FranchiseDubbingDialog({
    required this.franchiseKey,
    required this.name,
    required this.partIds,
  });

  final String franchiseKey;
  final String name;

  final List<int> partIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final franchise =
        (ref.watch(franchisesProvider).value ?? const {})[franchiseKey];
    final prefs = ref.watch(appPrefsProvider).value ?? const AppPrefs();
    final repository = ref.read(franchiseRepositoryProvider);
    final seen = franchise?.dubbingSeen;
    final on = seasonAlerts(franchise, prefs);
    return _DubbingDialog(
      title: 'Уведомления: $name',
      alerts: on,
      alertsByDefault: prefs.notifyFranchises,
      alertsTitle: 'Уведомлять о новых сезонах',
      note: 'Для всех частей. Озвучка, выбранная у части, важнее.',
      current: franchise?.dubbing,
      autoDetail: seen == null ? 'пока не известна' : 'по просмотру: $seen',
      noneDetail: prefs.episodeAlert.label.toLowerCase(),
      load: () async {
        final site = ref.read(siteEpisodesRepositoryProvider);
        final result = <String, int>{};
        for (final id in partIds) {
          try {
            await site.refresh(id);
          } catch (_) {}
          for (final MapEntry(:key, :value) in (await site.read(
            id,
          )).byDubbing.entries) {
            if (value > (result[key] ?? 0)) result[key] = value;
          }
        }
        return result;
      },
      onSave: (value, alerts) async {
        final undos = <Future<void> Function()>[];
        final changes = <String>[];
        if (value != franchise?.dubbing) {
          undos.add(await repository.setDubbing(franchiseKey, value));
          changes.add(_describe(value));
        }
        if (alerts != null && alerts != on) {
          final flags = alertFlags(
            on: alerts,
            byDefault: prefs.notifyFranchises,
          );
          undos.add(
            await repository.setAlerts(
              franchiseKey,
              muted: flags.muted,
              alertsOn: flags.alertsOn,
            ),
          );
          changes.add(
            alerts ? 'о новых сезонах сообщать' : 'о новых сезонах не сообщать',
          );
        }
        return (
          text: 'Франшиза «$name»: ${changes.join(', ')}',
          undo: () async {
            for (final undo in undos.reversed) {
              await undo();
            }
          },
        );
      },
    );
  }
}

String _describe(String? value) => switch (value) {
  null => 'озвучка автоматически',
  '' => 'озвучку не ждать',
  _ => 'озвучка $value',
};

/// Окно выбора озвучки.
class _DubbingDialog extends ConsumerStatefulWidget {
  const _DubbingDialog({
    required this.title,
    required this.current,
    required this.autoDetail,
    required this.noneDetail,
    required this.load,
    required this.onSave,
    this.note,
    this.alerts,
    this.alertsByDefault = false,
    this.alertsTitle = '',
  });

  final String title;
  final String? note;

  final bool? alerts;
  final bool alertsByDefault;
  final String alertsTitle;

  final String? current;
  final String autoDetail;
  final String noneDetail;

  final Future<Map<String, int>> Function() load;
  final Future<({String text, Future<void> Function() undo})> Function(
    String? value,
    bool? alerts,
  )
  onSave;

  @override
  ConsumerState<_DubbingDialog> createState() => _DubbingDialogState();
}

class _DubbingDialogState extends ConsumerState<_DubbingDialog> {
  late String? _selected = widget.current;
  late bool? _alerts = widget.alerts;
  Map<String, int>? _options;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget
        .load()
        .then((options) {
          if (mounted) setState(() => _options = options);
        })
        .catchError((Object error) {
          if (mounted) {
            setState(() {
              _options = const {};
              _error = '$error';
            });
          }
        });
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final toast = ref.read(toastProvider.notifier);
    if (_selected == widget.current && _alerts == widget.alerts) {
      navigator.pop();
      return;
    }
    final result = await widget.onSave(_selected, _alerts);
    navigator.pop();
    toast.show(result.text, undo: result.undo);
  }

  @override
  Widget build(BuildContext context) {
    final options = SiteEpisodesInfo(byDubbing: _options ?? const {}).sorted;
    final chosen = _selected;
    final chosenMissing =
        chosen != null &&
        chosen.isNotEmpty &&
        !options.any((option) => option.key == chosen);

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              [?widget.note, _explanation].join(' '),
              style: const TextStyle(color: AppColors.muted, height: 1.45),
            ),
            if (_alerts case final alerts?) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.alertsTitle,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          alerts == widget.alertsByDefault
                              ? 'По общей настройке.'
                              : 'Отдельно от общей настройки.',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Switch(
                    value: alerts,
                    onChanged: (on) => setState(() => _alerts = on),
                  ),
                ],
              ),
              const Divider(height: 14, color: AppColors.panelBorder),
            ],
            const SizedBox(height: 12),
            _Option(
              label: 'Автоматически',
              detail: widget.autoDetail,
              selected: chosen == null,
              onTap: () => setState(() => _selected = null),
            ),
            _Option(
              label: 'Не ждать озвучку',
              detail: widget.noneDetail,
              selected: chosen == '',
              onTap: () => setState(() => _selected = ''),
            ),
            const Divider(height: 14, color: AppColors.panelBorder),
            if (chosenMissing)
              _Option(
                label: chosen,
                detail: 'серий на сайте пока нет',
                selected: true,
                onTap: () {},
              ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final option in options)
                      _Option(
                        label: option.key,
                        detail: 'до ${option.value}-й серии',
                        selected: chosen == option.key,
                        onTap: () => setState(() => _selected = option.key),
                      ),
                  ],
                ),
              ),
            ),
            if (_options == null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Загрузка озвучек с YummyAnime…',
                  style: TextStyle(color: AppColors.muted),
                ),
              )
            else if (options.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error == null
                      ? 'На YummyAnime серий пока нет.'
                      : 'YummyAnime не ответил: $_error',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(onPressed: _save, child: const Text('Сохранить')),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
    this.detail,
  });

  final String label;
  final String? detail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      hoverColor: AppColors.cardHover,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          children: [
            Icon(
              selected ? LucideIcons.circleDot : LucideIcons.circle,
              size: 18,
              color: selected ? AppColors.accentText : AppColors.muted,
            ),
            const SizedBox(width: 12),
            Text(label),
            const SizedBox(width: 12),
            if (detail != null)
              Expanded(
                child: Text(
                  detail!,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
