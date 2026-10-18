/// Участник комнаты.
class PartyMember {
  PartyMember({required this.id, this.owner = false});

  final int id;
  bool owner;
  String name = 'Гость';

  /// Постоянный номер Kiroku участника.
  String uid = '';

  /// Плеер открыт на тайтле комнаты.
  bool watching = false;
  int? episode;
  double position = 0;

  /// Длина серии в секундах.
  double duration = 0;
  bool playing = false;

  /// Скорость, с которой сейчас идёт видео.
  double rate = 1;

  /// Когда пришло последнее состояние.
  DateTime? reportedAt;

  /// Главное видео загружено и не прерывается на подгрузку или рекламу.
  bool ready = false;

  /// С какого момента видео не готово.
  DateTime? notReadySince;

  /// Ушёл вперёд и ждёт отстающего.
  bool held = false;

  /// Серия, на которой участника уже перенесли на позицию комнаты.
  int? alignedEpisode;

  bool? commanded;
  DateTime? commandedAt;

  double? commandedRate;
  DateTime? rateCommandedAt;

  /// Позиция сейчас: последняя присланная плюс время с её прихода.
  double positionAt(DateTime now) {
    final at = reportedAt;
    if (!playing || !ready || at == null) return position;
    return position + now.difference(at).inMilliseconds / 1000 * rate;
  }

  /// Видео не готово дольше [partyLoadingGrace].
  bool loadingAt(DateTime now) {
    final since = notReadySince;
    return !ready &&
        (since == null || now.difference(since) >= partyLoadingGrace);
  }
}

/// Сколько участник может подгружаться, пока остальные не ждут его.
const partyLoadingGrace = Duration(milliseconds: 1500);

/// Через сколько секунд опережения участник ставится на паузу.
const partyHoldAfter = 2.0;

/// На каком опережении пауза заканчивается.
const partyReleaseAt = 0.3;

/// Новичок дальше этого от остальных переносится на их позицию.
const partyAlignAfter = 1.0;

/// Кому играть, а кому ждать: ушедший вперёд ждёт отстающего, короткая
/// подгрузка никого не останавливает.
({Map<int, bool> play, PartyMember? waitingFor}) partyPlan({
  required bool playing,
  required int? episode,
  required Iterable<PartyMember> members,
  DateTime? now,
}) {
  final at = now ?? DateTime.now();
  final active = [
    for (final member in members)
      if (member.watching) member,
  ];
  void calm() {
    for (final member in active) {
      member.held = false;
    }
  }

  if (!playing || active.isEmpty) {
    calm();
    return (
      play: {for (final member in active) member.id: false},
      waitingFor: null,
    );
  }

  bool late(PartyMember member) =>
      member.loadingAt(at) ||
      (episode != null && member.episode != null && member.episode != episode);
  final behind = active.where(late).firstOrNull;
  if (behind != null) {
    calm();
    return (
      play: {for (final member in active) member.id: late(member)},
      waitingFor: behind,
    );
  }

  final positions = {
    for (final member in active) member.id: member.positionAt(at),
  };
  final slowest = active.reduce(
    (a, b) => positions[a.id]! <= positions[b.id]! ? a : b,
  );
  final play = <int, bool>{};
  for (final member in active) {
    final ahead = positions[member.id]! - positions[slowest.id]!;
    if (ahead > partyHoldAfter) {
      member.held = true;
    } else if (ahead <= partyReleaseAt) {
      member.held = false;
    }
    play[member.id] = !member.held;
  }
  return (
    play: play,
    waitingFor: active.any((member) => member.held) ? slowest : null,
  );
}

/// Куда перенести участника, впервые готового на этой серии: на позицию
/// самого отстающего из уже идущих вместе.
double? partyAlign(PartyMember member, Iterable<PartyMember> members) {
  if (!member.watching || !member.ready) return null;
  if (member.alignedEpisode == member.episode) return null;
  member.alignedEpisode = member.episode;
  double? reference;
  for (final other in members) {
    if (other == member ||
        !other.watching ||
        !other.ready ||
        other.episode != member.episode ||
        other.alignedEpisode != other.episode) {
      continue;
    }
    if (reference == null || other.position < reference) {
      reference = other.position;
    }
  }
  if (reference == null ||
      (member.position - reference).abs() <= partyAlignAfter) {
    return null;
  }
  return reference;
}

/// Что сейчас с участником, для списка в окне комнаты.
String partyStatus(
  PartyMember member, {
  required int? episode,
  required PartyMember? waitingFor,
  DateTime? now,
}) {
  if (!member.watching) return 'не смотрит';
  if (episode != null && member.episode != null && member.episode != episode) {
    return 'открывает серию';
  }
  if (member.loadingAt(now ?? DateTime.now())) return 'загрузка или реклама';
  if (member == waitingFor) return 'догоняет';
  if (member.held) return 'ждёт';
  return member.playing ? 'смотрит' : 'пауза';
}
