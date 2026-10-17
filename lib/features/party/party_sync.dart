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

  /// Главное видео загружено и не прерывается на подгрузку или рекламу.
  bool ready = false;

  /// Ушёл вперёд и ждёт отстающего.
  bool held = false;

  /// Серия, на которой участника уже перенесли на позицию комнаты.
  int? alignedEpisode;

  bool? commanded;
  DateTime? commandedAt;
}

/// Через сколько секунд опережения участник ждёт отстающего.
const partyHoldAfter = 1.5;

/// На каком опережении ожидание заканчивается.
const partyReleaseAt = 0.3;

/// Кому играть, а кому ждать: все подстраиваются под отстающего.
({Map<int, bool> play, PartyMember? waitingFor}) partyPlan({
  required bool playing,
  required int? episode,
  required Iterable<PartyMember> members,
}) {
  final active = [
    for (final member in members)
      if (member.watching) member,
  ];
  if (!playing || active.isEmpty) {
    for (final member in active) {
      member.held = false;
    }
    return (
      play: {for (final member in active) member.id: false},
      waitingFor: null,
    );
  }

  bool late(PartyMember member) =>
      !member.ready ||
      (episode != null && member.episode != null && member.episode != episode);
  final behind = active.where(late).firstOrNull;
  if (behind != null) {
    return (
      play: {for (final member in active) member.id: late(member)},
      waitingFor: behind,
    );
  }

  final slowest = active.reduce((a, b) => a.position <= b.position ? a : b);
  final play = <int, bool>{};
  for (final member in active) {
    final ahead = member.position - slowest.position;
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
      (member.position - reference).abs() <= partyHoldAfter) {
    return null;
  }
  return reference;
}

/// Что сейчас с участником, для списка в окне комнаты.
String partyStatus(
  PartyMember member, {
  required int? episode,
  required PartyMember? waitingFor,
}) {
  if (!member.watching) return 'не смотрит';
  if (episode != null && member.episode != null && member.episode != episode) {
    return 'открывает серию';
  }
  if (!member.ready) return 'загрузка или реклама';
  if (member == waitingFor) return 'догоняет';
  if (member.held) return 'ждёт';
  return member.playing ? 'смотрит' : 'пауза';
}
