/// Фильтры поиска Shikimori.
library;

enum SearchKind {
  all('Все типы', null),
  tv('Сериалы', 'tv'),
  movie('Фильмы', 'movie'),
  ova('OVA', 'ova'),
  ona('ONA', 'ona'),
  special('Спецвыпуски', 'special,tv_special');

  const SearchKind(this.label, this.code);

  final String label;
  final String? code;
}

enum SearchStatus {
  all('Все статусы', null),
  anons('Анонсы', 'anons'),
  ongoing('Онгоинги', 'ongoing'),
  released('Вышедшие', 'released');

  const SearchStatus(this.label, this.code);

  final String label;
  final String? code;
}

enum SearchOrder {
  popularity('Популярные', 'popularity'),
  ranked('С высокой оценкой', 'ranked'),
  airedOn('Сначала новые', 'aired_on'),
  name('По названию', 'name');

  const SearchOrder(this.label, this.code);

  final String label;
  final String code;
}

class AnimeGenre {
  const AnimeGenre({required this.id, required this.name});

  final int id;
  final String name;

  @override
  bool operator ==(Object other) => other is AnimeGenre && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class AnimeSeason {
  const AnimeSeason(this.year, this.quarter);

  factory AnimeSeason.of(DateTime date) =>
      AnimeSeason(date.year, (date.month - 1) ~/ 3);

  final int year;

  final int quarter;

  static const _codes = ['winter', 'spring', 'summer', 'fall'];
  static const _names = ['Зима', 'Весна', 'Лето', 'Осень'];

  /// Сдвиг на несколько сезонов.
  AnimeSeason shift(int count) {
    final index = year * 4 + quarter + count;
    return AnimeSeason(index ~/ 4, index % 4);
  }

  String get code => '${_codes[quarter]}_$year';
  String get label => '${_names[quarter]} $year';

  @override
  bool operator ==(Object other) =>
      other is AnimeSeason && other.year == year && other.quarter == quarter;

  @override
  int get hashCode => Object.hash(year, quarter);
}

/// Год выхода для поиска.
class SearchYear {
  const SearchYear(this.label, this.code);

  final String label;

  final String? code;

  static const any = SearchYear('Все годы', null);

  /// Список лет для фильтра.
  static List<SearchYear> options(DateTime now) => [
    any,
    for (var year = now.year + 1; year >= 2000; year--)
      SearchYear('$year', '$year'),
    const SearchYear('1990-е', '1990_1999'),
    const SearchYear('1980-е', '1980_1989'),
    const SearchYear('Раньше', '1917_1979'),
  ];

  @override
  bool operator ==(Object other) => other is SearchYear && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

/// Запрос к каталогу.
class AnimeQuery {
  const AnimeQuery({
    this.search = '',
    this.season,
    this.kind = SearchKind.all,
    this.status = SearchStatus.all,
    this.genre,
    this.order = SearchOrder.popularity,
  });

  final String search;
  final String? season;
  final SearchKind kind;
  final SearchStatus status;
  final AnimeGenre? genre;
  final SearchOrder order;

  @override
  bool operator ==(Object other) =>
      other is AnimeQuery &&
      other.search == search &&
      other.season == season &&
      other.kind == kind &&
      other.status == status &&
      other.genre == genre &&
      other.order == order;

  @override
  int get hashCode => Object.hash(search, season, kind, status, genre, order);
}
