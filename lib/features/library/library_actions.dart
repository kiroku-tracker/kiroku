import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../core/toast.dart';
import '../../data/database/app_database.dart';
import '../../data/database/library_repository.dart';
import '../../data/database/status_action.dart';
import '../../data/providers.dart';
import '../../data/shikimori/anime_info.dart';

/// Действия с библиотекой.

Future<void> addToLibrary(
  WidgetRef ref,
  AnimeInfo anime,
  StatusAction action,
) async {
  final toast = ref.read(toastProvider.notifier);
  try {
    final change = await ref.read(libraryRepositoryProvider).add(anime, action);
    final marked = change.markedEpisodes > 0
        ? ' · отмечено ${episodesLabel(change.markedEpisodes)}'
        : '';
    toast.show(
      '«${anime.title}» добавлено в «${action.status.label}»$marked',
      undo: change.undo,
    );
  } catch (error) {
    toast.show('Не удалось добавить тайтл: $error');
  }
}

/// Добавляет несколько тайтлов.
Future<void> addAllToLibrary(
  WidgetRef ref,
  List<AnimeInfo> animes,
  StatusAction action,
) async {
  final toast = ref.read(toastProvider.notifier);
  final repository = ref.read(libraryRepositoryProvider);
  final undos = <Future<void> Function()>[];
  try {
    for (final anime in animes) {
      undos.add((await repository.add(anime, action)).undo);
    }
    toast.show(
      'Добавлено в «${action.status.label}»: '
      '${animes.length} ${plural(animes.length, 'тайтл', 'тайтла', 'тайтлов')}',
      undo: () async {
        for (final undo in undos.reversed) {
          await undo();
        }
      },
    );
  } catch (error) {
    toast.show('Не удалось добавить тайтлы: $error');
  }
}

Future<void> changeStatus(
  WidgetRef ref, {
  required int animeId,
  required String title,
  required StatusAction action,
}) async {
  final toast = ref.read(toastProvider.notifier);
  try {
    final change = await ref
        .read(libraryRepositoryProvider)
        .applyAction(animeId, action);
    final String text;
    if (change.startedRewatch) {
      text = '«$title»: начат повторный просмотр';
    } else if (action == StatusAction.caughtUp) {
      text = change.markedEpisodes > 0
          ? '«$title»: всё вышедшее просмотрено · отмечено '
                '${episodesLabel(change.markedEpisodes)}'
          : '«$title»: всё вышедшее просмотрено';
    } else if (change.markedEpisodes > 0) {
      text =
          '«$title» перенесено в «${action.status.label}» · отмечено '
          '${episodesLabel(change.markedEpisodes)}';
    } else {
      text = '«$title» перенесено в «${action.status.label}»';
    }
    final queue = await _advanceQueue(
      ref,
      animeId,
      change,
      finished: action == StatusAction.completed,
    );
    toast.show('$text${queue.note}', undo: queue.undo);
  } catch (error) {
    toast.show('Не удалось изменить статус: $error');
  }
}

Future<void> removeFromLibrary(
  WidgetRef ref, {
  required int animeId,
  required String title,
}) async {
  final toast = ref.read(toastProvider.notifier);
  try {
    final change = await ref.read(libraryRepositoryProvider).remove(animeId);
    toast.show('«$title» убрано из библиотеки', undo: change.undo);
  } catch (error) {
    toast.show('Не удалось убрать тайтл: $error');
  }
}

/// Отмечает следующую серию.
Future<void> markNextEpisode(
  WidgetRef ref, {
  required int animeId,
  required String title,
}) async {
  final toast = ref.read(toastProvider.notifier);
  try {
    final change = await ref
        .read(libraryRepositoryProvider)
        .markNextEpisode(animeId);
    final episode = change.episode;
    if (episode == null) {
      toast.show('Все вышедшие серии уже отмечены');
      return;
    }
    final queue = await _advanceQueue(
      ref,
      animeId,
      change,
      finished: change.finished,
    );
    toast.show(
      change.finished
          ? 'Серия $episode отмечена, «$title» просмотрено${queue.note}'
          : 'Серия $episode отмечена',
      undo: queue.undo,
    );
  } catch (error) {
    toast.show('Не удалось отметить серию: $error');
  }
}

/// Выполняет изменение и показывает подсказку.
Future<void> _run(
  WidgetRef ref,
  int animeId,
  Future<LibraryChange> Function(LibraryRepository repository) action,
  String Function(LibraryChange change) message, {
  required String errorText,
}) async {
  final toast = ref.read(toastProvider.notifier);
  try {
    final change = await action(ref.read(libraryRepositoryProvider));
    final queue = await _advanceQueue(
      ref,
      animeId,
      change,
      finished: change.finished,
    );
    toast.show('${message(change)}${queue.note}', undo: queue.undo);
  } catch (error) {
    toast.show('$errorText: $error');
  }
}

/// Отмечает серию или снимает отметку.
Future<void> toggleEpisode(
  WidgetRef ref, {
  required int animeId,
  required String title,
  required int episode,
}) => _run(
  ref,
  animeId,
  (repository) => repository.toggleEpisode(animeId, episode),
  (change) => change.markedEpisodes == 0
      ? 'Отметка серии $episode снята'
      : change.finished
      ? 'Серия $episode отмечена, «$title» просмотрено'
      : 'Серия $episode отмечена',
  errorText: 'Не удалось изменить отметку',
);

/// Отмечает серии from–to.
Future<void> markEpisodeRange(
  WidgetRef ref, {
  required int animeId,
  required String title,
  required int from,
  required int to,
}) => _run(
  ref,
  animeId,
  (repository) => repository.markRange(animeId, from, to),
  (change) {
    final count = change.markedEpisodes;
    final text = count == 0
        ? 'Серии $from–$to уже отмечены'
        : 'Отмечено: ${episodesLabel(count)}';
    return change.finished ? '$text, «$title» просмотрено' : text;
  },
  errorText: 'Не удалось отметить серии',
);

/// Снимает отметки серий from–to.
Future<void> unmarkEpisodeRange(
  WidgetRef ref, {
  required int animeId,
  required int from,
  required int to,
}) => _run(
  ref,
  animeId,
  (repository) => repository.unmarkRange(animeId, from, to),
  (_) => 'Отметки серий $from–$to сняты',
  errorText: 'Не удалось снять отметки',
);

/// Меняет дату просмотра серии.
Future<void> setEpisodeDate(
  WidgetRef ref, {
  required int animeId,
  required String cycleId,
  required int episode,
  required DateTime? watchedAt,
}) => _run(
  ref,
  animeId,
  (repository) =>
      repository.setEpisodeDate(animeId, cycleId, episode, watchedAt),
  (_) => watchedAt == null
      ? 'Дата серии $episode теперь неизвестна'
      : 'Дата серии $episode: ${formatWatchDate(watchedAt)}',
  errorText: 'Не удалось изменить дату',
);

Future<void> deleteViewing(
  WidgetRef ref, {
  required int animeId,
  required String cycleId,
  required int number,
}) => _run(
  ref,
  animeId,
  (repository) => repository.deleteCycle(animeId, cycleId),
  (_) => 'Просмотр $number удалён',
  errorText: 'Не удалось удалить просмотр',
);

/// Начинает просмотр заново.
Future<void> restartViewing(WidgetRef ref, {required int animeId}) => _run(
  ref,
  animeId,
  (repository) => repository.restartViewing(animeId),
  (_) => 'Начат новый просмотр. Прежний остался в истории',
  errorText: 'Не удалось начать заново',
);

/// Переводит очередь на следующую часть.
Future<({String note, Future<void> Function() undo})> _advanceQueue(
  WidgetRef ref,
  int animeId,
  LibraryChange change, {
  required bool finished,
}) async {
  if (!finished) return (note: '', undo: change.undo);
  final step = await ref.read(queueRepositoryProvider).onFinished(animeId);
  if (step == null) return (note: '', undo: change.undo);
  return (
    note: step.finished
        ? ' · франшиза досмотрена по порядку'
        : ' · дальше: «${step.next!.title}»',
    undo: () async {
      await step.undo();
      await change.undo();
    },
  );
}

/// Меняет дату просмотра нескольких серий.
Future<void> setEpisodesDate(
  WidgetRef ref, {
  required int animeId,
  required String cycleId,
  required List<int> episodes,
  required DateTime watchedAt,
}) => _run(
  ref,
  animeId,
  (repository) =>
      repository.setEpisodesDate(animeId, cycleId, episodes, watchedAt),
  (_) => '${episodesWord(episodes)}: дата ${formatWatchDate(watchedAt)}',
  errorText: 'Не удалось изменить дату',
);

/// Снимает отметки серий.
Future<void> unmarkEpisodes(
  WidgetRef ref, {
  required int animeId,
  required String title,
  required String cycleId,
  required List<int> episodes,
}) => _run(
  ref,
  animeId,
  (repository) => repository.unmarkEpisodes(animeId, cycleId, episodes),
  (_) => 'Отметка снята: «$title», ${episodesWord(episodes).toLowerCase()}',
  errorText: 'Не удалось снять отметку',
);
