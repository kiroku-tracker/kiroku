import '../data/shikimori/release_facts.dart';

const kindLabels = {
  'tv': 'Сериал',
  'movie': 'Фильм',
  'ova': 'OVA',
  'ona': 'ONA',
  'special': 'Спецвыпуск',
  'tv_special': 'ТВ-спецвыпуск',
  'music': 'Клип',
  'pv': 'Промо',
  'cm': 'Реклама',
};

String kindLabel(String? kind) => kindLabels[kind] ?? kind ?? 'Аниме';

String? ageRatingLabel(String? rating) => switch (rating) {
  'g' => 'G',
  'pg' => 'PG',
  'pg_13' => 'PG-13',
  'r' => 'R-17',
  'r_plus' => 'R+',
  'rx' => 'Rx',
  _ => null,
};

/// Склонение слова по числу.
String plural(int count, String one, String few, String many) {
  final lastTwo = count % 100;
  final last = count % 10;
  if (lastTwo >= 11 && lastTwo <= 14) return many;
  if (last == 1) return one;
  if (last >= 2 && last <= 4) return few;
  return many;
}

/// Число серий словами.
String episodesLabel(int count) =>
    '$count ${plural(count, 'серия', 'серии', 'серий')}';

/// Краткое описание эфира.
String releaseSummary(ReleaseFacts release) {
  if (release.isAnnounced) {
    return release.episodes > 0
        ? 'Анонс · ${episodesLabel(release.episodes)}'
        : 'Анонс';
  }
  if (release.isOngoing) {
    return release.episodes > 0
        ? 'Вышло ${release.aired} из ${episodesLabel(release.episodes)}'
        : 'Вышло ${episodesLabel(release.aired)}';
  }
  final total = release.availableEpisodes;
  return total > 0 ? episodesLabel(total) : '';
}

/// Прогресс просмотра для карточки.
String progressLabel(ReleaseFacts release, int watched, {int cycleNumber = 1}) {
  final prefix = cycleNumber > 1 ? '$cycleNumber-й просмотр · ' : '';
  if (release.isAnnounced) return '$prefixЕщё не вышло';
  final available = release.availableEpisodes;
  if (available == 0) return '$prefix$watched эп.';
  if (release.isOngoing) {
    final declared = release.episodes > available
        ? ' · ${release.episodes} всего'
        : '';
    return '$prefix$watched из $available вышедших$declared';
  }
  return '$prefix$watched из $available эп.';
}

const _months = [
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентября',
  'октября',
  'ноября',
  'декабря',
];
const _weekdays = ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];

/// Дата и время с днём недели.
String formatDateTime(DateTime value) {
  final local = value.toLocal();
  final year = local.year == DateTime.now().year ? '' : ' ${local.year}';
  final time =
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
  return '${_weekdays[local.weekday - 1]}, ${local.day} ${_months[local.month - 1]}$year, $time';
}

/// Дата относительно сегодня.
String relativeDay(DateTime value) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final local = value.toLocal();
  final day = DateTime(local.year, local.month, local.day);
  final days = day.difference(today).inDays;
  if (days < 0) return 'Ожидается';
  if (days == 0) return 'Сегодня';
  if (days == 1) return 'Завтра';
  return 'Через $days ${plural(days, 'день', 'дня', 'дней')}';
}

String formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.day} ${_months[local.month - 1]} ${local.year}';
}

/// Дата и время просмотра.
String formatWatchDate(DateTime value) {
  final local = value.toLocal();
  final time =
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
  return '${formatDate(local)}, $time';
}

String formatDateRange(DateTime from, DateTime to) {
  final a = from.toLocal();
  final b = to.toLocal();
  if (a.year == b.year && a.month == b.month) {
    return a.day == b.day
        ? formatDate(a)
        : '${a.day}–${b.day} ${_months[b.month - 1]} ${b.year}';
  }
  if (a.year == b.year) {
    return '${a.day} ${_months[a.month - 1]} – ${formatDate(b)}';
  }
  return '${formatDate(a)} – ${formatDate(b)}';
}

const _weekdayNames = [
  'Понедельник',
  'Вторник',
  'Среда',
  'Четверг',
  'Пятница',
  'Суббота',
  'Воскресенье',
];

const _monthNames = [
  'январь',
  'февраль',
  'март',
  'апрель',
  'май',
  'июнь',
  'июль',
  'август',
  'сентябрь',
  'октябрь',
  'ноябрь',
  'декабрь',
];

String weekdayName(DateTime value) => _weekdayNames[value.weekday - 1];

/// День и месяц.
String formatDayMonth(DateTime value) =>
    '${value.day} ${_months[value.month - 1]}';

String formatTime(DateTime value) {
  final local = value.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

String formatWeek(DateTime start) {
  final end = DateTime(start.year, start.month, start.day + 6);
  final year = end.year == DateTime.now().year ? '' : ' ${end.year}';
  if (start.month == end.month) {
    return '${start.day}–${end.day} ${_months[end.month - 1]}$year';
  }
  return '${formatDayMonth(start)} – ${formatDayMonth(end)}$year';
}

String formatAiredOn(String value) {
  final parts = value.split('-');
  final year = parts.first;
  final month = parts.length > 1 ? int.tryParse(parts[1]) : null;
  final day = parts.length > 2 ? int.tryParse(parts[2]) : null;
  if (month == null || month < 1 || month > 12) return year;
  if (day == null) return '${_monthNames[month - 1]} $year';
  return '$day ${_months[month - 1]} $year';
}

/// Номера серий одной строкой.
String episodeRanges(List<int> episodes) {
  final sorted = {...episodes}.toList()..sort();
  final parts = <String>[];
  var index = 0;
  while (index < sorted.length) {
    final from = sorted[index];
    var to = from;
    while (index + 1 < sorted.length && sorted[index + 1] == to + 1) {
      to = sorted[++index];
    }
    parts.add(from == to ? '$from' : '$from–$to');
    index++;
  }
  return parts.join(', ');
}

/// Подпись для списка серий.
String episodesWord(List<int> episodes) => {...episodes}.length == 1
    ? 'Серия ${episodes.first}'
    : 'Серии ${episodeRanges(episodes)}';

/// Сколько времени прошло: «5 мин назад», «вчера», «12 окт».
String timeAgo(DateTime value, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final local = value.toLocal();
  final passed = current.difference(local);
  if (passed.inMinutes < 1) return 'сейчас';
  if (passed.inMinutes < 60) return '${passed.inMinutes} мин назад';
  final today = DateTime(current.year, current.month, current.day);
  final day = DateTime(local.year, local.month, local.day);
  final days = today.difference(day).inDays;
  if (days == 0) return '${passed.inHours} ч назад';
  if (days == 1) return 'вчера';
  final year = local.year == current.year ? '' : ' ${local.year}';
  return '${formatDayMonth(local)}$year';
}
