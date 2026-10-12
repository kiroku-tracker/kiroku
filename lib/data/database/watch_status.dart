/// Статус тайтла в библиотеке.
enum WatchStatus {
  watching('Смотрю'),
  planned('Хочу посмотреть'),
  completed('Просмотрено'),
  paused('Отложено'),
  dropped('Брошено');

  const WatchStatus(this.label);

  final String label;

  static WatchStatus fromName(String value) => WatchStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => WatchStatus.planned,
  );
}
