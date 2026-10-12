// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AnimesTable extends Animes with TableInfo<$AnimesTable, Anime> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _russianMeta = const VerificationMeta(
    'russian',
  );
  @override
  late final GeneratedColumn<String> russian = GeneratedColumn<String>(
    'russian',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shikimoriScoreMeta = const VerificationMeta(
    'shikimoriScore',
  );
  @override
  late final GeneratedColumn<double> shikimoriScore = GeneratedColumn<double>(
    'shikimori_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _episodesMeta = const VerificationMeta(
    'episodes',
  );
  @override
  late final GeneratedColumn<int> episodes = GeneratedColumn<int>(
    'episodes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _episodesAiredMeta = const VerificationMeta(
    'episodesAired',
  );
  @override
  late final GeneratedColumn<int> episodesAired = GeneratedColumn<int>(
    'episodes_aired',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _releaseStatusMeta = const VerificationMeta(
    'releaseStatus',
  );
  @override
  late final GeneratedColumn<String> releaseStatus = GeneratedColumn<String>(
    'release_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextEpisodeAtMeta = const VerificationMeta(
    'nextEpisodeAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextEpisodeAt =
      GeneratedColumn<DateTime>(
        'next_episode_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _airedOnMeta = const VerificationMeta(
    'airedOn',
  );
  @override
  late final GeneratedColumn<String> airedOn = GeneratedColumn<String>(
    'aired_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _posterUrlMeta = const VerificationMeta(
    'posterUrl',
  );
  @override
  late final GeneratedColumn<String> posterUrl = GeneratedColumn<String>(
    'poster_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genresMeta = const VerificationMeta('genres');
  @override
  late final GeneratedColumn<String> genres = GeneratedColumn<String>(
    'genres',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studiosMeta = const VerificationMeta(
    'studios',
  );
  @override
  late final GeneratedColumn<String> studios = GeneratedColumn<String>(
    'studios',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _episodeDurationMeta = const VerificationMeta(
    'episodeDuration',
  );
  @override
  late final GeneratedColumn<int> episodeDuration = GeneratedColumn<int>(
    'episode_duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ageRatingMeta = const VerificationMeta(
    'ageRating',
  );
  @override
  late final GeneratedColumn<String> ageRating = GeneratedColumn<String>(
    'age_rating',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detailsLoadedAtMeta = const VerificationMeta(
    'detailsLoadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> detailsLoadedAt =
      GeneratedColumn<DateTime>(
        'details_loaded_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _franchiseMeta = const VerificationMeta(
    'franchise',
  );
  @override
  late final GeneratedColumn<String> franchise = GeneratedColumn<String>(
    'franchise',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    russian,
    kind,
    shikimoriScore,
    episodes,
    episodesAired,
    releaseStatus,
    nextEpisodeAt,
    airedOn,
    posterUrl,
    updatedAt,
    description,
    genres,
    studios,
    episodeDuration,
    ageRating,
    detailsLoadedAt,
    franchise,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Anime> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('russian')) {
      context.handle(
        _russianMeta,
        russian.isAcceptableOrUnknown(data['russian']!, _russianMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('shikimori_score')) {
      context.handle(
        _shikimoriScoreMeta,
        shikimoriScore.isAcceptableOrUnknown(
          data['shikimori_score']!,
          _shikimoriScoreMeta,
        ),
      );
    }
    if (data.containsKey('episodes')) {
      context.handle(
        _episodesMeta,
        episodes.isAcceptableOrUnknown(data['episodes']!, _episodesMeta),
      );
    }
    if (data.containsKey('episodes_aired')) {
      context.handle(
        _episodesAiredMeta,
        episodesAired.isAcceptableOrUnknown(
          data['episodes_aired']!,
          _episodesAiredMeta,
        ),
      );
    }
    if (data.containsKey('release_status')) {
      context.handle(
        _releaseStatusMeta,
        releaseStatus.isAcceptableOrUnknown(
          data['release_status']!,
          _releaseStatusMeta,
        ),
      );
    }
    if (data.containsKey('next_episode_at')) {
      context.handle(
        _nextEpisodeAtMeta,
        nextEpisodeAt.isAcceptableOrUnknown(
          data['next_episode_at']!,
          _nextEpisodeAtMeta,
        ),
      );
    }
    if (data.containsKey('aired_on')) {
      context.handle(
        _airedOnMeta,
        airedOn.isAcceptableOrUnknown(data['aired_on']!, _airedOnMeta),
      );
    }
    if (data.containsKey('poster_url')) {
      context.handle(
        _posterUrlMeta,
        posterUrl.isAcceptableOrUnknown(data['poster_url']!, _posterUrlMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('genres')) {
      context.handle(
        _genresMeta,
        genres.isAcceptableOrUnknown(data['genres']!, _genresMeta),
      );
    }
    if (data.containsKey('studios')) {
      context.handle(
        _studiosMeta,
        studios.isAcceptableOrUnknown(data['studios']!, _studiosMeta),
      );
    }
    if (data.containsKey('episode_duration')) {
      context.handle(
        _episodeDurationMeta,
        episodeDuration.isAcceptableOrUnknown(
          data['episode_duration']!,
          _episodeDurationMeta,
        ),
      );
    }
    if (data.containsKey('age_rating')) {
      context.handle(
        _ageRatingMeta,
        ageRating.isAcceptableOrUnknown(data['age_rating']!, _ageRatingMeta),
      );
    }
    if (data.containsKey('details_loaded_at')) {
      context.handle(
        _detailsLoadedAtMeta,
        detailsLoadedAt.isAcceptableOrUnknown(
          data['details_loaded_at']!,
          _detailsLoadedAtMeta,
        ),
      );
    }
    if (data.containsKey('franchise')) {
      context.handle(
        _franchiseMeta,
        franchise.isAcceptableOrUnknown(data['franchise']!, _franchiseMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Anime map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Anime(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      russian: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}russian'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      ),
      shikimoriScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}shikimori_score'],
      ),
      episodes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episodes'],
      )!,
      episodesAired: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episodes_aired'],
      )!,
      releaseStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_status'],
      ),
      nextEpisodeAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_episode_at'],
      ),
      airedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aired_on'],
      ),
      posterUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_url'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      genres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres'],
      ),
      studios: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}studios'],
      ),
      episodeDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_duration'],
      ),
      ageRating: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}age_rating'],
      ),
      detailsLoadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}details_loaded_at'],
      ),
      franchise: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}franchise'],
      ),
    );
  }

  @override
  $AnimesTable createAlias(String alias) {
    return $AnimesTable(attachedDatabase, alias);
  }
}

class Anime extends DataClass implements Insertable<Anime> {
  final int id;
  final String name;
  final String russian;
  final String? kind;
  final double? shikimoriScore;
  final int episodes;
  final int episodesAired;
  final String? releaseStatus;
  final DateTime? nextEpisodeAt;
  final String? airedOn;
  final String? posterUrl;
  final DateTime updatedAt;
  final String? description;
  final String? genres;
  final String? studios;
  final int? episodeDuration;
  final String? ageRating;
  final DateTime? detailsLoadedAt;
  final String? franchise;
  const Anime({
    required this.id,
    required this.name,
    required this.russian,
    this.kind,
    this.shikimoriScore,
    required this.episodes,
    required this.episodesAired,
    this.releaseStatus,
    this.nextEpisodeAt,
    this.airedOn,
    this.posterUrl,
    required this.updatedAt,
    this.description,
    this.genres,
    this.studios,
    this.episodeDuration,
    this.ageRating,
    this.detailsLoadedAt,
    this.franchise,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['russian'] = Variable<String>(russian);
    if (!nullToAbsent || kind != null) {
      map['kind'] = Variable<String>(kind);
    }
    if (!nullToAbsent || shikimoriScore != null) {
      map['shikimori_score'] = Variable<double>(shikimoriScore);
    }
    map['episodes'] = Variable<int>(episodes);
    map['episodes_aired'] = Variable<int>(episodesAired);
    if (!nullToAbsent || releaseStatus != null) {
      map['release_status'] = Variable<String>(releaseStatus);
    }
    if (!nullToAbsent || nextEpisodeAt != null) {
      map['next_episode_at'] = Variable<DateTime>(nextEpisodeAt);
    }
    if (!nullToAbsent || airedOn != null) {
      map['aired_on'] = Variable<String>(airedOn);
    }
    if (!nullToAbsent || posterUrl != null) {
      map['poster_url'] = Variable<String>(posterUrl);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || genres != null) {
      map['genres'] = Variable<String>(genres);
    }
    if (!nullToAbsent || studios != null) {
      map['studios'] = Variable<String>(studios);
    }
    if (!nullToAbsent || episodeDuration != null) {
      map['episode_duration'] = Variable<int>(episodeDuration);
    }
    if (!nullToAbsent || ageRating != null) {
      map['age_rating'] = Variable<String>(ageRating);
    }
    if (!nullToAbsent || detailsLoadedAt != null) {
      map['details_loaded_at'] = Variable<DateTime>(detailsLoadedAt);
    }
    if (!nullToAbsent || franchise != null) {
      map['franchise'] = Variable<String>(franchise);
    }
    return map;
  }

  AnimesCompanion toCompanion(bool nullToAbsent) {
    return AnimesCompanion(
      id: Value(id),
      name: Value(name),
      russian: Value(russian),
      kind: kind == null && nullToAbsent ? const Value.absent() : Value(kind),
      shikimoriScore: shikimoriScore == null && nullToAbsent
          ? const Value.absent()
          : Value(shikimoriScore),
      episodes: Value(episodes),
      episodesAired: Value(episodesAired),
      releaseStatus: releaseStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseStatus),
      nextEpisodeAt: nextEpisodeAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextEpisodeAt),
      airedOn: airedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(airedOn),
      posterUrl: posterUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(posterUrl),
      updatedAt: Value(updatedAt),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      genres: genres == null && nullToAbsent
          ? const Value.absent()
          : Value(genres),
      studios: studios == null && nullToAbsent
          ? const Value.absent()
          : Value(studios),
      episodeDuration: episodeDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(episodeDuration),
      ageRating: ageRating == null && nullToAbsent
          ? const Value.absent()
          : Value(ageRating),
      detailsLoadedAt: detailsLoadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(detailsLoadedAt),
      franchise: franchise == null && nullToAbsent
          ? const Value.absent()
          : Value(franchise),
    );
  }

  factory Anime.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Anime(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      russian: serializer.fromJson<String>(json['russian']),
      kind: serializer.fromJson<String?>(json['kind']),
      shikimoriScore: serializer.fromJson<double?>(json['shikimoriScore']),
      episodes: serializer.fromJson<int>(json['episodes']),
      episodesAired: serializer.fromJson<int>(json['episodesAired']),
      releaseStatus: serializer.fromJson<String?>(json['releaseStatus']),
      nextEpisodeAt: serializer.fromJson<DateTime?>(json['nextEpisodeAt']),
      airedOn: serializer.fromJson<String?>(json['airedOn']),
      posterUrl: serializer.fromJson<String?>(json['posterUrl']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      description: serializer.fromJson<String?>(json['description']),
      genres: serializer.fromJson<String?>(json['genres']),
      studios: serializer.fromJson<String?>(json['studios']),
      episodeDuration: serializer.fromJson<int?>(json['episodeDuration']),
      ageRating: serializer.fromJson<String?>(json['ageRating']),
      detailsLoadedAt: serializer.fromJson<DateTime?>(json['detailsLoadedAt']),
      franchise: serializer.fromJson<String?>(json['franchise']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'russian': serializer.toJson<String>(russian),
      'kind': serializer.toJson<String?>(kind),
      'shikimoriScore': serializer.toJson<double?>(shikimoriScore),
      'episodes': serializer.toJson<int>(episodes),
      'episodesAired': serializer.toJson<int>(episodesAired),
      'releaseStatus': serializer.toJson<String?>(releaseStatus),
      'nextEpisodeAt': serializer.toJson<DateTime?>(nextEpisodeAt),
      'airedOn': serializer.toJson<String?>(airedOn),
      'posterUrl': serializer.toJson<String?>(posterUrl),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'description': serializer.toJson<String?>(description),
      'genres': serializer.toJson<String?>(genres),
      'studios': serializer.toJson<String?>(studios),
      'episodeDuration': serializer.toJson<int?>(episodeDuration),
      'ageRating': serializer.toJson<String?>(ageRating),
      'detailsLoadedAt': serializer.toJson<DateTime?>(detailsLoadedAt),
      'franchise': serializer.toJson<String?>(franchise),
    };
  }

  Anime copyWith({
    int? id,
    String? name,
    String? russian,
    Value<String?> kind = const Value.absent(),
    Value<double?> shikimoriScore = const Value.absent(),
    int? episodes,
    int? episodesAired,
    Value<String?> releaseStatus = const Value.absent(),
    Value<DateTime?> nextEpisodeAt = const Value.absent(),
    Value<String?> airedOn = const Value.absent(),
    Value<String?> posterUrl = const Value.absent(),
    DateTime? updatedAt,
    Value<String?> description = const Value.absent(),
    Value<String?> genres = const Value.absent(),
    Value<String?> studios = const Value.absent(),
    Value<int?> episodeDuration = const Value.absent(),
    Value<String?> ageRating = const Value.absent(),
    Value<DateTime?> detailsLoadedAt = const Value.absent(),
    Value<String?> franchise = const Value.absent(),
  }) => Anime(
    id: id ?? this.id,
    name: name ?? this.name,
    russian: russian ?? this.russian,
    kind: kind.present ? kind.value : this.kind,
    shikimoriScore: shikimoriScore.present
        ? shikimoriScore.value
        : this.shikimoriScore,
    episodes: episodes ?? this.episodes,
    episodesAired: episodesAired ?? this.episodesAired,
    releaseStatus: releaseStatus.present
        ? releaseStatus.value
        : this.releaseStatus,
    nextEpisodeAt: nextEpisodeAt.present
        ? nextEpisodeAt.value
        : this.nextEpisodeAt,
    airedOn: airedOn.present ? airedOn.value : this.airedOn,
    posterUrl: posterUrl.present ? posterUrl.value : this.posterUrl,
    updatedAt: updatedAt ?? this.updatedAt,
    description: description.present ? description.value : this.description,
    genres: genres.present ? genres.value : this.genres,
    studios: studios.present ? studios.value : this.studios,
    episodeDuration: episodeDuration.present
        ? episodeDuration.value
        : this.episodeDuration,
    ageRating: ageRating.present ? ageRating.value : this.ageRating,
    detailsLoadedAt: detailsLoadedAt.present
        ? detailsLoadedAt.value
        : this.detailsLoadedAt,
    franchise: franchise.present ? franchise.value : this.franchise,
  );
  Anime copyWithCompanion(AnimesCompanion data) {
    return Anime(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      russian: data.russian.present ? data.russian.value : this.russian,
      kind: data.kind.present ? data.kind.value : this.kind,
      shikimoriScore: data.shikimoriScore.present
          ? data.shikimoriScore.value
          : this.shikimoriScore,
      episodes: data.episodes.present ? data.episodes.value : this.episodes,
      episodesAired: data.episodesAired.present
          ? data.episodesAired.value
          : this.episodesAired,
      releaseStatus: data.releaseStatus.present
          ? data.releaseStatus.value
          : this.releaseStatus,
      nextEpisodeAt: data.nextEpisodeAt.present
          ? data.nextEpisodeAt.value
          : this.nextEpisodeAt,
      airedOn: data.airedOn.present ? data.airedOn.value : this.airedOn,
      posterUrl: data.posterUrl.present ? data.posterUrl.value : this.posterUrl,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      description: data.description.present
          ? data.description.value
          : this.description,
      genres: data.genres.present ? data.genres.value : this.genres,
      studios: data.studios.present ? data.studios.value : this.studios,
      episodeDuration: data.episodeDuration.present
          ? data.episodeDuration.value
          : this.episodeDuration,
      ageRating: data.ageRating.present ? data.ageRating.value : this.ageRating,
      detailsLoadedAt: data.detailsLoadedAt.present
          ? data.detailsLoadedAt.value
          : this.detailsLoadedAt,
      franchise: data.franchise.present ? data.franchise.value : this.franchise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Anime(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('russian: $russian, ')
          ..write('kind: $kind, ')
          ..write('shikimoriScore: $shikimoriScore, ')
          ..write('episodes: $episodes, ')
          ..write('episodesAired: $episodesAired, ')
          ..write('releaseStatus: $releaseStatus, ')
          ..write('nextEpisodeAt: $nextEpisodeAt, ')
          ..write('airedOn: $airedOn, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('description: $description, ')
          ..write('genres: $genres, ')
          ..write('studios: $studios, ')
          ..write('episodeDuration: $episodeDuration, ')
          ..write('ageRating: $ageRating, ')
          ..write('detailsLoadedAt: $detailsLoadedAt, ')
          ..write('franchise: $franchise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    russian,
    kind,
    shikimoriScore,
    episodes,
    episodesAired,
    releaseStatus,
    nextEpisodeAt,
    airedOn,
    posterUrl,
    updatedAt,
    description,
    genres,
    studios,
    episodeDuration,
    ageRating,
    detailsLoadedAt,
    franchise,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Anime &&
          other.id == this.id &&
          other.name == this.name &&
          other.russian == this.russian &&
          other.kind == this.kind &&
          other.shikimoriScore == this.shikimoriScore &&
          other.episodes == this.episodes &&
          other.episodesAired == this.episodesAired &&
          other.releaseStatus == this.releaseStatus &&
          other.nextEpisodeAt == this.nextEpisodeAt &&
          other.airedOn == this.airedOn &&
          other.posterUrl == this.posterUrl &&
          other.updatedAt == this.updatedAt &&
          other.description == this.description &&
          other.genres == this.genres &&
          other.studios == this.studios &&
          other.episodeDuration == this.episodeDuration &&
          other.ageRating == this.ageRating &&
          other.detailsLoadedAt == this.detailsLoadedAt &&
          other.franchise == this.franchise);
}

class AnimesCompanion extends UpdateCompanion<Anime> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> russian;
  final Value<String?> kind;
  final Value<double?> shikimoriScore;
  final Value<int> episodes;
  final Value<int> episodesAired;
  final Value<String?> releaseStatus;
  final Value<DateTime?> nextEpisodeAt;
  final Value<String?> airedOn;
  final Value<String?> posterUrl;
  final Value<DateTime> updatedAt;
  final Value<String?> description;
  final Value<String?> genres;
  final Value<String?> studios;
  final Value<int?> episodeDuration;
  final Value<String?> ageRating;
  final Value<DateTime?> detailsLoadedAt;
  final Value<String?> franchise;
  const AnimesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.russian = const Value.absent(),
    this.kind = const Value.absent(),
    this.shikimoriScore = const Value.absent(),
    this.episodes = const Value.absent(),
    this.episodesAired = const Value.absent(),
    this.releaseStatus = const Value.absent(),
    this.nextEpisodeAt = const Value.absent(),
    this.airedOn = const Value.absent(),
    this.posterUrl = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.description = const Value.absent(),
    this.genres = const Value.absent(),
    this.studios = const Value.absent(),
    this.episodeDuration = const Value.absent(),
    this.ageRating = const Value.absent(),
    this.detailsLoadedAt = const Value.absent(),
    this.franchise = const Value.absent(),
  });
  AnimesCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.russian = const Value.absent(),
    this.kind = const Value.absent(),
    this.shikimoriScore = const Value.absent(),
    this.episodes = const Value.absent(),
    this.episodesAired = const Value.absent(),
    this.releaseStatus = const Value.absent(),
    this.nextEpisodeAt = const Value.absent(),
    this.airedOn = const Value.absent(),
    this.posterUrl = const Value.absent(),
    required DateTime updatedAt,
    this.description = const Value.absent(),
    this.genres = const Value.absent(),
    this.studios = const Value.absent(),
    this.episodeDuration = const Value.absent(),
    this.ageRating = const Value.absent(),
    this.detailsLoadedAt = const Value.absent(),
    this.franchise = const Value.absent(),
  }) : updatedAt = Value(updatedAt);
  static Insertable<Anime> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? russian,
    Expression<String>? kind,
    Expression<double>? shikimoriScore,
    Expression<int>? episodes,
    Expression<int>? episodesAired,
    Expression<String>? releaseStatus,
    Expression<DateTime>? nextEpisodeAt,
    Expression<String>? airedOn,
    Expression<String>? posterUrl,
    Expression<DateTime>? updatedAt,
    Expression<String>? description,
    Expression<String>? genres,
    Expression<String>? studios,
    Expression<int>? episodeDuration,
    Expression<String>? ageRating,
    Expression<DateTime>? detailsLoadedAt,
    Expression<String>? franchise,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (russian != null) 'russian': russian,
      if (kind != null) 'kind': kind,
      if (shikimoriScore != null) 'shikimori_score': shikimoriScore,
      if (episodes != null) 'episodes': episodes,
      if (episodesAired != null) 'episodes_aired': episodesAired,
      if (releaseStatus != null) 'release_status': releaseStatus,
      if (nextEpisodeAt != null) 'next_episode_at': nextEpisodeAt,
      if (airedOn != null) 'aired_on': airedOn,
      if (posterUrl != null) 'poster_url': posterUrl,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (description != null) 'description': description,
      if (genres != null) 'genres': genres,
      if (studios != null) 'studios': studios,
      if (episodeDuration != null) 'episode_duration': episodeDuration,
      if (ageRating != null) 'age_rating': ageRating,
      if (detailsLoadedAt != null) 'details_loaded_at': detailsLoadedAt,
      if (franchise != null) 'franchise': franchise,
    });
  }

  AnimesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? russian,
    Value<String?>? kind,
    Value<double?>? shikimoriScore,
    Value<int>? episodes,
    Value<int>? episodesAired,
    Value<String?>? releaseStatus,
    Value<DateTime?>? nextEpisodeAt,
    Value<String?>? airedOn,
    Value<String?>? posterUrl,
    Value<DateTime>? updatedAt,
    Value<String?>? description,
    Value<String?>? genres,
    Value<String?>? studios,
    Value<int?>? episodeDuration,
    Value<String?>? ageRating,
    Value<DateTime?>? detailsLoadedAt,
    Value<String?>? franchise,
  }) {
    return AnimesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      russian: russian ?? this.russian,
      kind: kind ?? this.kind,
      shikimoriScore: shikimoriScore ?? this.shikimoriScore,
      episodes: episodes ?? this.episodes,
      episodesAired: episodesAired ?? this.episodesAired,
      releaseStatus: releaseStatus ?? this.releaseStatus,
      nextEpisodeAt: nextEpisodeAt ?? this.nextEpisodeAt,
      airedOn: airedOn ?? this.airedOn,
      posterUrl: posterUrl ?? this.posterUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      studios: studios ?? this.studios,
      episodeDuration: episodeDuration ?? this.episodeDuration,
      ageRating: ageRating ?? this.ageRating,
      detailsLoadedAt: detailsLoadedAt ?? this.detailsLoadedAt,
      franchise: franchise ?? this.franchise,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (russian.present) {
      map['russian'] = Variable<String>(russian.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (shikimoriScore.present) {
      map['shikimori_score'] = Variable<double>(shikimoriScore.value);
    }
    if (episodes.present) {
      map['episodes'] = Variable<int>(episodes.value);
    }
    if (episodesAired.present) {
      map['episodes_aired'] = Variable<int>(episodesAired.value);
    }
    if (releaseStatus.present) {
      map['release_status'] = Variable<String>(releaseStatus.value);
    }
    if (nextEpisodeAt.present) {
      map['next_episode_at'] = Variable<DateTime>(nextEpisodeAt.value);
    }
    if (airedOn.present) {
      map['aired_on'] = Variable<String>(airedOn.value);
    }
    if (posterUrl.present) {
      map['poster_url'] = Variable<String>(posterUrl.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (genres.present) {
      map['genres'] = Variable<String>(genres.value);
    }
    if (studios.present) {
      map['studios'] = Variable<String>(studios.value);
    }
    if (episodeDuration.present) {
      map['episode_duration'] = Variable<int>(episodeDuration.value);
    }
    if (ageRating.present) {
      map['age_rating'] = Variable<String>(ageRating.value);
    }
    if (detailsLoadedAt.present) {
      map['details_loaded_at'] = Variable<DateTime>(detailsLoadedAt.value);
    }
    if (franchise.present) {
      map['franchise'] = Variable<String>(franchise.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('russian: $russian, ')
          ..write('kind: $kind, ')
          ..write('shikimoriScore: $shikimoriScore, ')
          ..write('episodes: $episodes, ')
          ..write('episodesAired: $episodesAired, ')
          ..write('releaseStatus: $releaseStatus, ')
          ..write('nextEpisodeAt: $nextEpisodeAt, ')
          ..write('airedOn: $airedOn, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('description: $description, ')
          ..write('genres: $genres, ')
          ..write('studios: $studios, ')
          ..write('episodeDuration: $episodeDuration, ')
          ..write('ageRating: $ageRating, ')
          ..write('detailsLoadedAt: $detailsLoadedAt, ')
          ..write('franchise: $franchise')
          ..write(')'))
        .toString();
  }
}

class $LibraryEntriesTable extends LibraryEntries
    with TableInfo<$LibraryEntriesTable, LibraryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _animeIdMeta = const VerificationMeta(
    'animeId',
  );
  @override
  late final GeneratedColumn<int> animeId = GeneratedColumn<int>(
    'anime_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES animes (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _franchiseOverrideMeta = const VerificationMeta(
    'franchiseOverride',
  );
  @override
  late final GeneratedColumn<String> franchiseOverride =
      GeneratedColumn<String>(
        'franchise_override',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _mutedMeta = const VerificationMeta('muted');
  @override
  late final GeneratedColumn<bool> muted = GeneratedColumn<bool>(
    'muted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("muted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dubbingMeta = const VerificationMeta(
    'dubbing',
  );
  @override
  late final GeneratedColumn<String> dubbing = GeneratedColumn<String>(
    'dubbing',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dubbingSeenMeta = const VerificationMeta(
    'dubbingSeen',
  );
  @override
  late final GeneratedColumn<String> dubbingSeen = GeneratedColumn<String>(
    'dubbing_seen',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    animeId,
    status,
    score,
    note,
    addedAt,
    updatedAt,
    deletedAt,
    franchiseOverride,
    muted,
    dubbing,
    dubbingSeen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('anime_id')) {
      context.handle(
        _animeIdMeta,
        animeId.isAcceptableOrUnknown(data['anime_id']!, _animeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_animeIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('franchise_override')) {
      context.handle(
        _franchiseOverrideMeta,
        franchiseOverride.isAcceptableOrUnknown(
          data['franchise_override']!,
          _franchiseOverrideMeta,
        ),
      );
    }
    if (data.containsKey('muted')) {
      context.handle(
        _mutedMeta,
        muted.isAcceptableOrUnknown(data['muted']!, _mutedMeta),
      );
    }
    if (data.containsKey('dubbing')) {
      context.handle(
        _dubbingMeta,
        dubbing.isAcceptableOrUnknown(data['dubbing']!, _dubbingMeta),
      );
    }
    if (data.containsKey('dubbing_seen')) {
      context.handle(
        _dubbingSeenMeta,
        dubbingSeen.isAcceptableOrUnknown(
          data['dubbing_seen']!,
          _dubbingSeenMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      animeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anime_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      franchiseOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}franchise_override'],
      ),
      muted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}muted'],
      )!,
      dubbing: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dubbing'],
      ),
      dubbingSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dubbing_seen'],
      ),
    );
  }

  @override
  $LibraryEntriesTable createAlias(String alias) {
    return $LibraryEntriesTable(attachedDatabase, alias);
  }
}

class LibraryEntry extends DataClass implements Insertable<LibraryEntry> {
  final String id;
  final int animeId;
  final String status;
  final int? score;
  final String note;
  final DateTime addedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? franchiseOverride;
  final bool muted;
  final String? dubbing;
  final String? dubbingSeen;
  const LibraryEntry({
    required this.id,
    required this.animeId,
    required this.status,
    this.score,
    required this.note,
    required this.addedAt,
    required this.updatedAt,
    this.deletedAt,
    this.franchiseOverride,
    required this.muted,
    this.dubbing,
    this.dubbingSeen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['anime_id'] = Variable<int>(animeId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    map['note'] = Variable<String>(note);
    map['added_at'] = Variable<DateTime>(addedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || franchiseOverride != null) {
      map['franchise_override'] = Variable<String>(franchiseOverride);
    }
    map['muted'] = Variable<bool>(muted);
    if (!nullToAbsent || dubbing != null) {
      map['dubbing'] = Variable<String>(dubbing);
    }
    if (!nullToAbsent || dubbingSeen != null) {
      map['dubbing_seen'] = Variable<String>(dubbingSeen);
    }
    return map;
  }

  LibraryEntriesCompanion toCompanion(bool nullToAbsent) {
    return LibraryEntriesCompanion(
      id: Value(id),
      animeId: Value(animeId),
      status: Value(status),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      note: Value(note),
      addedAt: Value(addedAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      franchiseOverride: franchiseOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(franchiseOverride),
      muted: Value(muted),
      dubbing: dubbing == null && nullToAbsent
          ? const Value.absent()
          : Value(dubbing),
      dubbingSeen: dubbingSeen == null && nullToAbsent
          ? const Value.absent()
          : Value(dubbingSeen),
    );
  }

  factory LibraryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryEntry(
      id: serializer.fromJson<String>(json['id']),
      animeId: serializer.fromJson<int>(json['animeId']),
      status: serializer.fromJson<String>(json['status']),
      score: serializer.fromJson<int?>(json['score']),
      note: serializer.fromJson<String>(json['note']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      franchiseOverride: serializer.fromJson<String?>(
        json['franchiseOverride'],
      ),
      muted: serializer.fromJson<bool>(json['muted']),
      dubbing: serializer.fromJson<String?>(json['dubbing']),
      dubbingSeen: serializer.fromJson<String?>(json['dubbingSeen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'animeId': serializer.toJson<int>(animeId),
      'status': serializer.toJson<String>(status),
      'score': serializer.toJson<int?>(score),
      'note': serializer.toJson<String>(note),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'franchiseOverride': serializer.toJson<String?>(franchiseOverride),
      'muted': serializer.toJson<bool>(muted),
      'dubbing': serializer.toJson<String?>(dubbing),
      'dubbingSeen': serializer.toJson<String?>(dubbingSeen),
    };
  }

  LibraryEntry copyWith({
    String? id,
    int? animeId,
    String? status,
    Value<int?> score = const Value.absent(),
    String? note,
    DateTime? addedAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> franchiseOverride = const Value.absent(),
    bool? muted,
    Value<String?> dubbing = const Value.absent(),
    Value<String?> dubbingSeen = const Value.absent(),
  }) => LibraryEntry(
    id: id ?? this.id,
    animeId: animeId ?? this.animeId,
    status: status ?? this.status,
    score: score.present ? score.value : this.score,
    note: note ?? this.note,
    addedAt: addedAt ?? this.addedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    franchiseOverride: franchiseOverride.present
        ? franchiseOverride.value
        : this.franchiseOverride,
    muted: muted ?? this.muted,
    dubbing: dubbing.present ? dubbing.value : this.dubbing,
    dubbingSeen: dubbingSeen.present ? dubbingSeen.value : this.dubbingSeen,
  );
  LibraryEntry copyWithCompanion(LibraryEntriesCompanion data) {
    return LibraryEntry(
      id: data.id.present ? data.id.value : this.id,
      animeId: data.animeId.present ? data.animeId.value : this.animeId,
      status: data.status.present ? data.status.value : this.status,
      score: data.score.present ? data.score.value : this.score,
      note: data.note.present ? data.note.value : this.note,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      franchiseOverride: data.franchiseOverride.present
          ? data.franchiseOverride.value
          : this.franchiseOverride,
      muted: data.muted.present ? data.muted.value : this.muted,
      dubbing: data.dubbing.present ? data.dubbing.value : this.dubbing,
      dubbingSeen: data.dubbingSeen.present
          ? data.dubbingSeen.value
          : this.dubbingSeen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntry(')
          ..write('id: $id, ')
          ..write('animeId: $animeId, ')
          ..write('status: $status, ')
          ..write('score: $score, ')
          ..write('note: $note, ')
          ..write('addedAt: $addedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('franchiseOverride: $franchiseOverride, ')
          ..write('muted: $muted, ')
          ..write('dubbing: $dubbing, ')
          ..write('dubbingSeen: $dubbingSeen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    animeId,
    status,
    score,
    note,
    addedAt,
    updatedAt,
    deletedAt,
    franchiseOverride,
    muted,
    dubbing,
    dubbingSeen,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryEntry &&
          other.id == this.id &&
          other.animeId == this.animeId &&
          other.status == this.status &&
          other.score == this.score &&
          other.note == this.note &&
          other.addedAt == this.addedAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.franchiseOverride == this.franchiseOverride &&
          other.muted == this.muted &&
          other.dubbing == this.dubbing &&
          other.dubbingSeen == this.dubbingSeen);
}

class LibraryEntriesCompanion extends UpdateCompanion<LibraryEntry> {
  final Value<String> id;
  final Value<int> animeId;
  final Value<String> status;
  final Value<int?> score;
  final Value<String> note;
  final Value<DateTime> addedAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> franchiseOverride;
  final Value<bool> muted;
  final Value<String?> dubbing;
  final Value<String?> dubbingSeen;
  final Value<int> rowid;
  const LibraryEntriesCompanion({
    this.id = const Value.absent(),
    this.animeId = const Value.absent(),
    this.status = const Value.absent(),
    this.score = const Value.absent(),
    this.note = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.franchiseOverride = const Value.absent(),
    this.muted = const Value.absent(),
    this.dubbing = const Value.absent(),
    this.dubbingSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryEntriesCompanion.insert({
    required String id,
    required int animeId,
    required String status,
    this.score = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime addedAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.franchiseOverride = const Value.absent(),
    this.muted = const Value.absent(),
    this.dubbing = const Value.absent(),
    this.dubbingSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       animeId = Value(animeId),
       status = Value(status),
       addedAt = Value(addedAt),
       updatedAt = Value(updatedAt);
  static Insertable<LibraryEntry> custom({
    Expression<String>? id,
    Expression<int>? animeId,
    Expression<String>? status,
    Expression<int>? score,
    Expression<String>? note,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? franchiseOverride,
    Expression<bool>? muted,
    Expression<String>? dubbing,
    Expression<String>? dubbingSeen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animeId != null) 'anime_id': animeId,
      if (status != null) 'status': status,
      if (score != null) 'score': score,
      if (note != null) 'note': note,
      if (addedAt != null) 'added_at': addedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (franchiseOverride != null) 'franchise_override': franchiseOverride,
      if (muted != null) 'muted': muted,
      if (dubbing != null) 'dubbing': dubbing,
      if (dubbingSeen != null) 'dubbing_seen': dubbingSeen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? animeId,
    Value<String>? status,
    Value<int?>? score,
    Value<String>? note,
    Value<DateTime>? addedAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? franchiseOverride,
    Value<bool>? muted,
    Value<String?>? dubbing,
    Value<String?>? dubbingSeen,
    Value<int>? rowid,
  }) {
    return LibraryEntriesCompanion(
      id: id ?? this.id,
      animeId: animeId ?? this.animeId,
      status: status ?? this.status,
      score: score ?? this.score,
      note: note ?? this.note,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      franchiseOverride: franchiseOverride ?? this.franchiseOverride,
      muted: muted ?? this.muted,
      dubbing: dubbing ?? this.dubbing,
      dubbingSeen: dubbingSeen ?? this.dubbingSeen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (animeId.present) {
      map['anime_id'] = Variable<int>(animeId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (franchiseOverride.present) {
      map['franchise_override'] = Variable<String>(franchiseOverride.value);
    }
    if (muted.present) {
      map['muted'] = Variable<bool>(muted.value);
    }
    if (dubbing.present) {
      map['dubbing'] = Variable<String>(dubbing.value);
    }
    if (dubbingSeen.present) {
      map['dubbing_seen'] = Variable<String>(dubbingSeen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('animeId: $animeId, ')
          ..write('status: $status, ')
          ..write('score: $score, ')
          ..write('note: $note, ')
          ..write('addedAt: $addedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('franchiseOverride: $franchiseOverride, ')
          ..write('muted: $muted, ')
          ..write('dubbing: $dubbing, ')
          ..write('dubbingSeen: $dubbingSeen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WatchCyclesTable extends WatchCycles
    with TableInfo<$WatchCyclesTable, WatchCycle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchCyclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES library_entries (id)',
    ),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryId,
    number,
    state,
    startedAt,
    finishedAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_cycles';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchCycle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchCycle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchCycle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $WatchCyclesTable createAlias(String alias) {
    return $WatchCyclesTable(attachedDatabase, alias);
  }
}

class WatchCycle extends DataClass implements Insertable<WatchCycle> {
  final String id;
  final String entryId;
  final int number;
  final String state;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const WatchCycle({
    required this.id,
    required this.entryId,
    required this.number,
    required this.state,
    this.startedAt,
    this.finishedAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entry_id'] = Variable<String>(entryId);
    map['number'] = Variable<int>(number);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  WatchCyclesCompanion toCompanion(bool nullToAbsent) {
    return WatchCyclesCompanion(
      id: Value(id),
      entryId: Value(entryId),
      number: Value(number),
      state: Value(state),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory WatchCycle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchCycle(
      id: serializer.fromJson<String>(json['id']),
      entryId: serializer.fromJson<String>(json['entryId']),
      number: serializer.fromJson<int>(json['number']),
      state: serializer.fromJson<String>(json['state']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entryId': serializer.toJson<String>(entryId),
      'number': serializer.toJson<int>(number),
      'state': serializer.toJson<String>(state),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  WatchCycle copyWith({
    String? id,
    String? entryId,
    int? number,
    String? state,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> finishedAt = const Value.absent(),
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => WatchCycle(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    number: number ?? this.number,
    state: state ?? this.state,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  WatchCycle copyWithCompanion(WatchCyclesCompanion data) {
    return WatchCycle(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      number: data.number.present ? data.number.value : this.number,
      state: data.state.present ? data.state.value : this.state,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchCycle(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('number: $number, ')
          ..write('state: $state, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entryId,
    number,
    state,
    startedAt,
    finishedAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchCycle &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.number == this.number &&
          other.state == this.state &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class WatchCyclesCompanion extends UpdateCompanion<WatchCycle> {
  final Value<String> id;
  final Value<String> entryId;
  final Value<int> number;
  final Value<String> state;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const WatchCyclesCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.number = const Value.absent(),
    this.state = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchCyclesCompanion.insert({
    required String id,
    required String entryId,
    required int number,
    required String state,
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entryId = Value(entryId),
       number = Value(number),
       state = Value(state),
       updatedAt = Value(updatedAt);
  static Insertable<WatchCycle> custom({
    Expression<String>? id,
    Expression<String>? entryId,
    Expression<int>? number,
    Expression<String>? state,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (number != null) 'number': number,
      if (state != null) 'state': state,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchCyclesCompanion copyWith({
    Value<String>? id,
    Value<String>? entryId,
    Value<int>? number,
    Value<String>? state,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return WatchCyclesCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      number: number ?? this.number,
      state: state ?? this.state,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchCyclesCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('number: $number, ')
          ..write('state: $state, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WatchEventsTable extends WatchEvents
    with TableInfo<$WatchEventsTable, WatchEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleIdMeta = const VerificationMeta(
    'cycleId',
  );
  @override
  late final GeneratedColumn<String> cycleId = GeneratedColumn<String>(
    'cycle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES watch_cycles (id)',
    ),
  );
  static const VerificationMeta _episodeMeta = const VerificationMeta(
    'episode',
  );
  @override
  late final GeneratedColumn<int> episode = GeneratedColumn<int>(
    'episode',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _watchedAtMeta = const VerificationMeta(
    'watchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> watchedAt = GeneratedColumn<DateTime>(
    'watched_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _markedAtMeta = const VerificationMeta(
    'markedAt',
  );
  @override
  late final GeneratedColumn<DateTime> markedAt = GeneratedColumn<DateTime>(
    'marked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beforeAiredMeta = const VerificationMeta(
    'beforeAired',
  );
  @override
  late final GeneratedColumn<bool> beforeAired = GeneratedColumn<bool>(
    'before_aired',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("before_aired" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _bulkMeta = const VerificationMeta('bulk');
  @override
  late final GeneratedColumn<bool> bulk = GeneratedColumn<bool>(
    'bulk',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bulk" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cycleId,
    episode,
    watchedAt,
    markedAt,
    beforeAired,
    bulk,
    source,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cycle_id')) {
      context.handle(
        _cycleIdMeta,
        cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('episode')) {
      context.handle(
        _episodeMeta,
        episode.isAcceptableOrUnknown(data['episode']!, _episodeMeta),
      );
    } else if (isInserting) {
      context.missing(_episodeMeta);
    }
    if (data.containsKey('watched_at')) {
      context.handle(
        _watchedAtMeta,
        watchedAt.isAcceptableOrUnknown(data['watched_at']!, _watchedAtMeta),
      );
    }
    if (data.containsKey('marked_at')) {
      context.handle(
        _markedAtMeta,
        markedAt.isAcceptableOrUnknown(data['marked_at']!, _markedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_markedAtMeta);
    }
    if (data.containsKey('before_aired')) {
      context.handle(
        _beforeAiredMeta,
        beforeAired.isAcceptableOrUnknown(
          data['before_aired']!,
          _beforeAiredMeta,
        ),
      );
    }
    if (data.containsKey('bulk')) {
      context.handle(
        _bulkMeta,
        bulk.isAcceptableOrUnknown(data['bulk']!, _bulkMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle_id'],
      )!,
      episode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode'],
      )!,
      watchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}watched_at'],
      ),
      markedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}marked_at'],
      )!,
      beforeAired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}before_aired'],
      )!,
      bulk: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bulk'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $WatchEventsTable createAlias(String alias) {
    return $WatchEventsTable(attachedDatabase, alias);
  }
}

class WatchEvent extends DataClass implements Insertable<WatchEvent> {
  final String id;
  final String cycleId;
  final int episode;
  final DateTime? watchedAt;
  final DateTime markedAt;
  final bool beforeAired;
  final bool bulk;
  final String? source;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const WatchEvent({
    required this.id,
    required this.cycleId,
    required this.episode,
    this.watchedAt,
    required this.markedAt,
    required this.beforeAired,
    required this.bulk,
    this.source,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cycle_id'] = Variable<String>(cycleId);
    map['episode'] = Variable<int>(episode);
    if (!nullToAbsent || watchedAt != null) {
      map['watched_at'] = Variable<DateTime>(watchedAt);
    }
    map['marked_at'] = Variable<DateTime>(markedAt);
    map['before_aired'] = Variable<bool>(beforeAired);
    map['bulk'] = Variable<bool>(bulk);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  WatchEventsCompanion toCompanion(bool nullToAbsent) {
    return WatchEventsCompanion(
      id: Value(id),
      cycleId: Value(cycleId),
      episode: Value(episode),
      watchedAt: watchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(watchedAt),
      markedAt: Value(markedAt),
      beforeAired: Value(beforeAired),
      bulk: Value(bulk),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory WatchEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchEvent(
      id: serializer.fromJson<String>(json['id']),
      cycleId: serializer.fromJson<String>(json['cycleId']),
      episode: serializer.fromJson<int>(json['episode']),
      watchedAt: serializer.fromJson<DateTime?>(json['watchedAt']),
      markedAt: serializer.fromJson<DateTime>(json['markedAt']),
      beforeAired: serializer.fromJson<bool>(json['beforeAired']),
      bulk: serializer.fromJson<bool>(json['bulk']),
      source: serializer.fromJson<String?>(json['source']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cycleId': serializer.toJson<String>(cycleId),
      'episode': serializer.toJson<int>(episode),
      'watchedAt': serializer.toJson<DateTime?>(watchedAt),
      'markedAt': serializer.toJson<DateTime>(markedAt),
      'beforeAired': serializer.toJson<bool>(beforeAired),
      'bulk': serializer.toJson<bool>(bulk),
      'source': serializer.toJson<String?>(source),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  WatchEvent copyWith({
    String? id,
    String? cycleId,
    int? episode,
    Value<DateTime?> watchedAt = const Value.absent(),
    DateTime? markedAt,
    bool? beforeAired,
    bool? bulk,
    Value<String?> source = const Value.absent(),
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => WatchEvent(
    id: id ?? this.id,
    cycleId: cycleId ?? this.cycleId,
    episode: episode ?? this.episode,
    watchedAt: watchedAt.present ? watchedAt.value : this.watchedAt,
    markedAt: markedAt ?? this.markedAt,
    beforeAired: beforeAired ?? this.beforeAired,
    bulk: bulk ?? this.bulk,
    source: source.present ? source.value : this.source,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  WatchEvent copyWithCompanion(WatchEventsCompanion data) {
    return WatchEvent(
      id: data.id.present ? data.id.value : this.id,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      episode: data.episode.present ? data.episode.value : this.episode,
      watchedAt: data.watchedAt.present ? data.watchedAt.value : this.watchedAt,
      markedAt: data.markedAt.present ? data.markedAt.value : this.markedAt,
      beforeAired: data.beforeAired.present
          ? data.beforeAired.value
          : this.beforeAired,
      bulk: data.bulk.present ? data.bulk.value : this.bulk,
      source: data.source.present ? data.source.value : this.source,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchEvent(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('episode: $episode, ')
          ..write('watchedAt: $watchedAt, ')
          ..write('markedAt: $markedAt, ')
          ..write('beforeAired: $beforeAired, ')
          ..write('bulk: $bulk, ')
          ..write('source: $source, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cycleId,
    episode,
    watchedAt,
    markedAt,
    beforeAired,
    bulk,
    source,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchEvent &&
          other.id == this.id &&
          other.cycleId == this.cycleId &&
          other.episode == this.episode &&
          other.watchedAt == this.watchedAt &&
          other.markedAt == this.markedAt &&
          other.beforeAired == this.beforeAired &&
          other.bulk == this.bulk &&
          other.source == this.source &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class WatchEventsCompanion extends UpdateCompanion<WatchEvent> {
  final Value<String> id;
  final Value<String> cycleId;
  final Value<int> episode;
  final Value<DateTime?> watchedAt;
  final Value<DateTime> markedAt;
  final Value<bool> beforeAired;
  final Value<bool> bulk;
  final Value<String?> source;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const WatchEventsCompanion({
    this.id = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.episode = const Value.absent(),
    this.watchedAt = const Value.absent(),
    this.markedAt = const Value.absent(),
    this.beforeAired = const Value.absent(),
    this.bulk = const Value.absent(),
    this.source = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchEventsCompanion.insert({
    required String id,
    required String cycleId,
    required int episode,
    this.watchedAt = const Value.absent(),
    required DateTime markedAt,
    this.beforeAired = const Value.absent(),
    this.bulk = const Value.absent(),
    this.source = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cycleId = Value(cycleId),
       episode = Value(episode),
       markedAt = Value(markedAt),
       updatedAt = Value(updatedAt);
  static Insertable<WatchEvent> custom({
    Expression<String>? id,
    Expression<String>? cycleId,
    Expression<int>? episode,
    Expression<DateTime>? watchedAt,
    Expression<DateTime>? markedAt,
    Expression<bool>? beforeAired,
    Expression<bool>? bulk,
    Expression<String>? source,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cycleId != null) 'cycle_id': cycleId,
      if (episode != null) 'episode': episode,
      if (watchedAt != null) 'watched_at': watchedAt,
      if (markedAt != null) 'marked_at': markedAt,
      if (beforeAired != null) 'before_aired': beforeAired,
      if (bulk != null) 'bulk': bulk,
      if (source != null) 'source': source,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? cycleId,
    Value<int>? episode,
    Value<DateTime?>? watchedAt,
    Value<DateTime>? markedAt,
    Value<bool>? beforeAired,
    Value<bool>? bulk,
    Value<String?>? source,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return WatchEventsCompanion(
      id: id ?? this.id,
      cycleId: cycleId ?? this.cycleId,
      episode: episode ?? this.episode,
      watchedAt: watchedAt ?? this.watchedAt,
      markedAt: markedAt ?? this.markedAt,
      beforeAired: beforeAired ?? this.beforeAired,
      bulk: bulk ?? this.bulk,
      source: source ?? this.source,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<String>(cycleId.value);
    }
    if (episode.present) {
      map['episode'] = Variable<int>(episode.value);
    }
    if (watchedAt.present) {
      map['watched_at'] = Variable<DateTime>(watchedAt.value);
    }
    if (markedAt.present) {
      map['marked_at'] = Variable<DateTime>(markedAt.value);
    }
    if (beforeAired.present) {
      map['before_aired'] = Variable<bool>(beforeAired.value);
    }
    if (bulk.present) {
      map['bulk'] = Variable<bool>(bulk.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchEventsCompanion(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('episode: $episode, ')
          ..write('watchedAt: $watchedAt, ')
          ..write('markedAt: $markedAt, ')
          ..write('beforeAired: $beforeAired, ')
          ..write('bulk: $bulk, ')
          ..write('source: $source, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimeRelationsTable extends AnimeRelations
    with TableInfo<$AnimeRelationsTable, AnimeRelation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimeRelationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _animeIdMeta = const VerificationMeta(
    'animeId',
  );
  @override
  late final GeneratedColumn<int> animeId = GeneratedColumn<int>(
    'anime_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relatedIdMeta = const VerificationMeta(
    'relatedId',
  );
  @override
  late final GeneratedColumn<int> relatedId = GeneratedColumn<int>(
    'related_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationMeta = const VerificationMeta(
    'relation',
  );
  @override
  late final GeneratedColumn<String> relation = GeneratedColumn<String>(
    'relation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [animeId, relatedId, relation];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anime_relations';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnimeRelation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('anime_id')) {
      context.handle(
        _animeIdMeta,
        animeId.isAcceptableOrUnknown(data['anime_id']!, _animeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_animeIdMeta);
    }
    if (data.containsKey('related_id')) {
      context.handle(
        _relatedIdMeta,
        relatedId.isAcceptableOrUnknown(data['related_id']!, _relatedIdMeta),
      );
    } else if (isInserting) {
      context.missing(_relatedIdMeta);
    }
    if (data.containsKey('relation')) {
      context.handle(
        _relationMeta,
        relation.isAcceptableOrUnknown(data['relation']!, _relationMeta),
      );
    } else if (isInserting) {
      context.missing(_relationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {animeId, relatedId};
  @override
  AnimeRelation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimeRelation(
      animeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anime_id'],
      )!,
      relatedId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}related_id'],
      )!,
      relation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation'],
      )!,
    );
  }

  @override
  $AnimeRelationsTable createAlias(String alias) {
    return $AnimeRelationsTable(attachedDatabase, alias);
  }
}

class AnimeRelation extends DataClass implements Insertable<AnimeRelation> {
  final int animeId;
  final int relatedId;
  final String relation;
  const AnimeRelation({
    required this.animeId,
    required this.relatedId,
    required this.relation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['anime_id'] = Variable<int>(animeId);
    map['related_id'] = Variable<int>(relatedId);
    map['relation'] = Variable<String>(relation);
    return map;
  }

  AnimeRelationsCompanion toCompanion(bool nullToAbsent) {
    return AnimeRelationsCompanion(
      animeId: Value(animeId),
      relatedId: Value(relatedId),
      relation: Value(relation),
    );
  }

  factory AnimeRelation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimeRelation(
      animeId: serializer.fromJson<int>(json['animeId']),
      relatedId: serializer.fromJson<int>(json['relatedId']),
      relation: serializer.fromJson<String>(json['relation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'animeId': serializer.toJson<int>(animeId),
      'relatedId': serializer.toJson<int>(relatedId),
      'relation': serializer.toJson<String>(relation),
    };
  }

  AnimeRelation copyWith({int? animeId, int? relatedId, String? relation}) =>
      AnimeRelation(
        animeId: animeId ?? this.animeId,
        relatedId: relatedId ?? this.relatedId,
        relation: relation ?? this.relation,
      );
  AnimeRelation copyWithCompanion(AnimeRelationsCompanion data) {
    return AnimeRelation(
      animeId: data.animeId.present ? data.animeId.value : this.animeId,
      relatedId: data.relatedId.present ? data.relatedId.value : this.relatedId,
      relation: data.relation.present ? data.relation.value : this.relation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimeRelation(')
          ..write('animeId: $animeId, ')
          ..write('relatedId: $relatedId, ')
          ..write('relation: $relation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(animeId, relatedId, relation);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimeRelation &&
          other.animeId == this.animeId &&
          other.relatedId == this.relatedId &&
          other.relation == this.relation);
}

class AnimeRelationsCompanion extends UpdateCompanion<AnimeRelation> {
  final Value<int> animeId;
  final Value<int> relatedId;
  final Value<String> relation;
  final Value<int> rowid;
  const AnimeRelationsCompanion({
    this.animeId = const Value.absent(),
    this.relatedId = const Value.absent(),
    this.relation = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimeRelationsCompanion.insert({
    required int animeId,
    required int relatedId,
    required String relation,
    this.rowid = const Value.absent(),
  }) : animeId = Value(animeId),
       relatedId = Value(relatedId),
       relation = Value(relation);
  static Insertable<AnimeRelation> custom({
    Expression<int>? animeId,
    Expression<int>? relatedId,
    Expression<String>? relation,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (animeId != null) 'anime_id': animeId,
      if (relatedId != null) 'related_id': relatedId,
      if (relation != null) 'relation': relation,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimeRelationsCompanion copyWith({
    Value<int>? animeId,
    Value<int>? relatedId,
    Value<String>? relation,
    Value<int>? rowid,
  }) {
    return AnimeRelationsCompanion(
      animeId: animeId ?? this.animeId,
      relatedId: relatedId ?? this.relatedId,
      relation: relation ?? this.relation,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (animeId.present) {
      map['anime_id'] = Variable<int>(animeId.value);
    }
    if (relatedId.present) {
      map['related_id'] = Variable<int>(relatedId.value);
    }
    if (relation.present) {
      map['relation'] = Variable<String>(relation.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimeRelationsCompanion(')
          ..write('animeId: $animeId, ')
          ..write('relatedId: $relatedId, ')
          ..write('relation: $relation, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FranchisesTable extends Franchises
    with TableInfo<$FranchisesTable, Franchise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FranchisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autoNameMeta = const VerificationMeta(
    'autoName',
  );
  @override
  late final GeneratedColumn<String> autoName = GeneratedColumn<String>(
    'auto_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverAnimeIdMeta = const VerificationMeta(
    'coverAnimeId',
  );
  @override
  late final GeneratedColumn<int> coverAnimeId = GeneratedColumn<int>(
    'cover_anime_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dubbingMeta = const VerificationMeta(
    'dubbing',
  );
  @override
  late final GeneratedColumn<String> dubbing = GeneratedColumn<String>(
    'dubbing',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dubbingSeenMeta = const VerificationMeta(
    'dubbingSeen',
  );
  @override
  late final GeneratedColumn<String> dubbingSeen = GeneratedColumn<String>(
    'dubbing_seen',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partsLoadedAtMeta = const VerificationMeta(
    'partsLoadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> partsLoadedAt =
      GeneratedColumn<DateTime>(
        'parts_loaded_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    name,
    autoName,
    coverAnimeId,
    dubbing,
    dubbingSeen,
    partsLoadedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'franchises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Franchise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('auto_name')) {
      context.handle(
        _autoNameMeta,
        autoName.isAcceptableOrUnknown(data['auto_name']!, _autoNameMeta),
      );
    }
    if (data.containsKey('cover_anime_id')) {
      context.handle(
        _coverAnimeIdMeta,
        coverAnimeId.isAcceptableOrUnknown(
          data['cover_anime_id']!,
          _coverAnimeIdMeta,
        ),
      );
    }
    if (data.containsKey('dubbing')) {
      context.handle(
        _dubbingMeta,
        dubbing.isAcceptableOrUnknown(data['dubbing']!, _dubbingMeta),
      );
    }
    if (data.containsKey('dubbing_seen')) {
      context.handle(
        _dubbingSeenMeta,
        dubbingSeen.isAcceptableOrUnknown(
          data['dubbing_seen']!,
          _dubbingSeenMeta,
        ),
      );
    }
    if (data.containsKey('parts_loaded_at')) {
      context.handle(
        _partsLoadedAtMeta,
        partsLoadedAt.isAcceptableOrUnknown(
          data['parts_loaded_at']!,
          _partsLoadedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Franchise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Franchise(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      autoName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auto_name'],
      ),
      coverAnimeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cover_anime_id'],
      ),
      dubbing: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dubbing'],
      ),
      dubbingSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dubbing_seen'],
      ),
      partsLoadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}parts_loaded_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FranchisesTable createAlias(String alias) {
    return $FranchisesTable(attachedDatabase, alias);
  }
}

class Franchise extends DataClass implements Insertable<Franchise> {
  final String key;
  final String? name;
  final String? autoName;
  final int? coverAnimeId;
  final String? dubbing;
  final String? dubbingSeen;
  final DateTime? partsLoadedAt;
  final DateTime updatedAt;
  const Franchise({
    required this.key,
    this.name,
    this.autoName,
    this.coverAnimeId,
    this.dubbing,
    this.dubbingSeen,
    this.partsLoadedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || autoName != null) {
      map['auto_name'] = Variable<String>(autoName);
    }
    if (!nullToAbsent || coverAnimeId != null) {
      map['cover_anime_id'] = Variable<int>(coverAnimeId);
    }
    if (!nullToAbsent || dubbing != null) {
      map['dubbing'] = Variable<String>(dubbing);
    }
    if (!nullToAbsent || dubbingSeen != null) {
      map['dubbing_seen'] = Variable<String>(dubbingSeen);
    }
    if (!nullToAbsent || partsLoadedAt != null) {
      map['parts_loaded_at'] = Variable<DateTime>(partsLoadedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FranchisesCompanion toCompanion(bool nullToAbsent) {
    return FranchisesCompanion(
      key: Value(key),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      autoName: autoName == null && nullToAbsent
          ? const Value.absent()
          : Value(autoName),
      coverAnimeId: coverAnimeId == null && nullToAbsent
          ? const Value.absent()
          : Value(coverAnimeId),
      dubbing: dubbing == null && nullToAbsent
          ? const Value.absent()
          : Value(dubbing),
      dubbingSeen: dubbingSeen == null && nullToAbsent
          ? const Value.absent()
          : Value(dubbingSeen),
      partsLoadedAt: partsLoadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(partsLoadedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Franchise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Franchise(
      key: serializer.fromJson<String>(json['key']),
      name: serializer.fromJson<String?>(json['name']),
      autoName: serializer.fromJson<String?>(json['autoName']),
      coverAnimeId: serializer.fromJson<int?>(json['coverAnimeId']),
      dubbing: serializer.fromJson<String?>(json['dubbing']),
      dubbingSeen: serializer.fromJson<String?>(json['dubbingSeen']),
      partsLoadedAt: serializer.fromJson<DateTime?>(json['partsLoadedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'name': serializer.toJson<String?>(name),
      'autoName': serializer.toJson<String?>(autoName),
      'coverAnimeId': serializer.toJson<int?>(coverAnimeId),
      'dubbing': serializer.toJson<String?>(dubbing),
      'dubbingSeen': serializer.toJson<String?>(dubbingSeen),
      'partsLoadedAt': serializer.toJson<DateTime?>(partsLoadedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Franchise copyWith({
    String? key,
    Value<String?> name = const Value.absent(),
    Value<String?> autoName = const Value.absent(),
    Value<int?> coverAnimeId = const Value.absent(),
    Value<String?> dubbing = const Value.absent(),
    Value<String?> dubbingSeen = const Value.absent(),
    Value<DateTime?> partsLoadedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => Franchise(
    key: key ?? this.key,
    name: name.present ? name.value : this.name,
    autoName: autoName.present ? autoName.value : this.autoName,
    coverAnimeId: coverAnimeId.present ? coverAnimeId.value : this.coverAnimeId,
    dubbing: dubbing.present ? dubbing.value : this.dubbing,
    dubbingSeen: dubbingSeen.present ? dubbingSeen.value : this.dubbingSeen,
    partsLoadedAt: partsLoadedAt.present
        ? partsLoadedAt.value
        : this.partsLoadedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Franchise copyWithCompanion(FranchisesCompanion data) {
    return Franchise(
      key: data.key.present ? data.key.value : this.key,
      name: data.name.present ? data.name.value : this.name,
      autoName: data.autoName.present ? data.autoName.value : this.autoName,
      coverAnimeId: data.coverAnimeId.present
          ? data.coverAnimeId.value
          : this.coverAnimeId,
      dubbing: data.dubbing.present ? data.dubbing.value : this.dubbing,
      dubbingSeen: data.dubbingSeen.present
          ? data.dubbingSeen.value
          : this.dubbingSeen,
      partsLoadedAt: data.partsLoadedAt.present
          ? data.partsLoadedAt.value
          : this.partsLoadedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Franchise(')
          ..write('key: $key, ')
          ..write('name: $name, ')
          ..write('autoName: $autoName, ')
          ..write('coverAnimeId: $coverAnimeId, ')
          ..write('dubbing: $dubbing, ')
          ..write('dubbingSeen: $dubbingSeen, ')
          ..write('partsLoadedAt: $partsLoadedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    key,
    name,
    autoName,
    coverAnimeId,
    dubbing,
    dubbingSeen,
    partsLoadedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Franchise &&
          other.key == this.key &&
          other.name == this.name &&
          other.autoName == this.autoName &&
          other.coverAnimeId == this.coverAnimeId &&
          other.dubbing == this.dubbing &&
          other.dubbingSeen == this.dubbingSeen &&
          other.partsLoadedAt == this.partsLoadedAt &&
          other.updatedAt == this.updatedAt);
}

class FranchisesCompanion extends UpdateCompanion<Franchise> {
  final Value<String> key;
  final Value<String?> name;
  final Value<String?> autoName;
  final Value<int?> coverAnimeId;
  final Value<String?> dubbing;
  final Value<String?> dubbingSeen;
  final Value<DateTime?> partsLoadedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FranchisesCompanion({
    this.key = const Value.absent(),
    this.name = const Value.absent(),
    this.autoName = const Value.absent(),
    this.coverAnimeId = const Value.absent(),
    this.dubbing = const Value.absent(),
    this.dubbingSeen = const Value.absent(),
    this.partsLoadedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FranchisesCompanion.insert({
    required String key,
    this.name = const Value.absent(),
    this.autoName = const Value.absent(),
    this.coverAnimeId = const Value.absent(),
    this.dubbing = const Value.absent(),
    this.dubbingSeen = const Value.absent(),
    this.partsLoadedAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       updatedAt = Value(updatedAt);
  static Insertable<Franchise> custom({
    Expression<String>? key,
    Expression<String>? name,
    Expression<String>? autoName,
    Expression<int>? coverAnimeId,
    Expression<String>? dubbing,
    Expression<String>? dubbingSeen,
    Expression<DateTime>? partsLoadedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (name != null) 'name': name,
      if (autoName != null) 'auto_name': autoName,
      if (coverAnimeId != null) 'cover_anime_id': coverAnimeId,
      if (dubbing != null) 'dubbing': dubbing,
      if (dubbingSeen != null) 'dubbing_seen': dubbingSeen,
      if (partsLoadedAt != null) 'parts_loaded_at': partsLoadedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FranchisesCompanion copyWith({
    Value<String>? key,
    Value<String?>? name,
    Value<String?>? autoName,
    Value<int?>? coverAnimeId,
    Value<String?>? dubbing,
    Value<String?>? dubbingSeen,
    Value<DateTime?>? partsLoadedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FranchisesCompanion(
      key: key ?? this.key,
      name: name ?? this.name,
      autoName: autoName ?? this.autoName,
      coverAnimeId: coverAnimeId ?? this.coverAnimeId,
      dubbing: dubbing ?? this.dubbing,
      dubbingSeen: dubbingSeen ?? this.dubbingSeen,
      partsLoadedAt: partsLoadedAt ?? this.partsLoadedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (autoName.present) {
      map['auto_name'] = Variable<String>(autoName.value);
    }
    if (coverAnimeId.present) {
      map['cover_anime_id'] = Variable<int>(coverAnimeId.value);
    }
    if (dubbing.present) {
      map['dubbing'] = Variable<String>(dubbing.value);
    }
    if (dubbingSeen.present) {
      map['dubbing_seen'] = Variable<String>(dubbingSeen.value);
    }
    if (partsLoadedAt.present) {
      map['parts_loaded_at'] = Variable<DateTime>(partsLoadedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FranchisesCompanion(')
          ..write('key: $key, ')
          ..write('name: $name, ')
          ..write('autoName: $autoName, ')
          ..write('coverAnimeId: $coverAnimeId, ')
          ..write('dubbing: $dubbing, ')
          ..write('dubbingSeen: $dubbingSeen, ')
          ..write('partsLoadedAt: $partsLoadedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserGroupsTable extends UserGroups
    with TableInfo<$UserGroupsTable, UserGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $UserGroupsTable createAlias(String alias) {
    return $UserGroupsTable(attachedDatabase, alias);
  }
}

class UserGroup extends DataClass implements Insertable<UserGroup> {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const UserGroup({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  UserGroupsCompanion toCompanion(bool nullToAbsent) {
    return UserGroupsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory UserGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserGroup(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  UserGroup copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => UserGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  UserGroup copyWithCompanion(UserGroupsCompanion data) {
    return UserGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class UserGroupsCompanion extends UpdateCompanion<UserGroup> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const UserGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserGroupsCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserGroup> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return UserGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserGroupMembersTable extends UserGroupMembers
    with TableInfo<$UserGroupMembersTable, UserGroupMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserGroupMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_groups (id)',
    ),
  );
  static const VerificationMeta _memberKeyMeta = const VerificationMeta(
    'memberKey',
  );
  @override
  late final GeneratedColumn<String> memberKey = GeneratedColumn<String>(
    'member_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    groupId,
    memberKey,
    addedAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_group_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserGroupMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('member_key')) {
      context.handle(
        _memberKeyMeta,
        memberKey.isAcceptableOrUnknown(data['member_key']!, _memberKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_memberKeyMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, memberKey};
  @override
  UserGroupMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserGroupMember(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      memberKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_key'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $UserGroupMembersTable createAlias(String alias) {
    return $UserGroupMembersTable(attachedDatabase, alias);
  }
}

class UserGroupMember extends DataClass implements Insertable<UserGroupMember> {
  final String groupId;
  final String memberKey;
  final DateTime addedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const UserGroupMember({
    required this.groupId,
    required this.memberKey,
    required this.addedAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['member_key'] = Variable<String>(memberKey);
    map['added_at'] = Variable<DateTime>(addedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  UserGroupMembersCompanion toCompanion(bool nullToAbsent) {
    return UserGroupMembersCompanion(
      groupId: Value(groupId),
      memberKey: Value(memberKey),
      addedAt: Value(addedAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory UserGroupMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserGroupMember(
      groupId: serializer.fromJson<String>(json['groupId']),
      memberKey: serializer.fromJson<String>(json['memberKey']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'memberKey': serializer.toJson<String>(memberKey),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  UserGroupMember copyWith({
    String? groupId,
    String? memberKey,
    DateTime? addedAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => UserGroupMember(
    groupId: groupId ?? this.groupId,
    memberKey: memberKey ?? this.memberKey,
    addedAt: addedAt ?? this.addedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  UserGroupMember copyWithCompanion(UserGroupMembersCompanion data) {
    return UserGroupMember(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      memberKey: data.memberKey.present ? data.memberKey.value : this.memberKey,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserGroupMember(')
          ..write('groupId: $groupId, ')
          ..write('memberKey: $memberKey, ')
          ..write('addedAt: $addedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(groupId, memberKey, addedAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserGroupMember &&
          other.groupId == this.groupId &&
          other.memberKey == this.memberKey &&
          other.addedAt == this.addedAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class UserGroupMembersCompanion extends UpdateCompanion<UserGroupMember> {
  final Value<String> groupId;
  final Value<String> memberKey;
  final Value<DateTime> addedAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const UserGroupMembersCompanion({
    this.groupId = const Value.absent(),
    this.memberKey = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserGroupMembersCompanion.insert({
    required String groupId,
    required String memberKey,
    required DateTime addedAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       memberKey = Value(memberKey),
       addedAt = Value(addedAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserGroupMember> custom({
    Expression<String>? groupId,
    Expression<String>? memberKey,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (memberKey != null) 'member_key': memberKey,
      if (addedAt != null) 'added_at': addedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserGroupMembersCompanion copyWith({
    Value<String>? groupId,
    Value<String>? memberKey,
    Value<DateTime>? addedAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return UserGroupMembersCompanion(
      groupId: groupId ?? this.groupId,
      memberKey: memberKey ?? this.memberKey,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (memberKey.present) {
      map['member_key'] = Variable<String>(memberKey.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserGroupMembersCompanion(')
          ..write('groupId: $groupId, ')
          ..write('memberKey: $memberKey, ')
          ..write('addedAt: $addedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WatchQueuesTable extends WatchQueues
    with TableInfo<$WatchQueuesTable, WatchQueue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchQueuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _franchiseKeyMeta = const VerificationMeta(
    'franchiseKey',
  );
  @override
  late final GeneratedColumn<String> franchiseKey = GeneratedColumn<String>(
    'franchise_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    franchiseKey,
    state,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_queues';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchQueue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('franchise_key')) {
      context.handle(
        _franchiseKeyMeta,
        franchiseKey.isAcceptableOrUnknown(
          data['franchise_key']!,
          _franchiseKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_franchiseKeyMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchQueue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchQueue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      franchiseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}franchise_key'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WatchQueuesTable createAlias(String alias) {
    return $WatchQueuesTable(attachedDatabase, alias);
  }
}

class WatchQueue extends DataClass implements Insertable<WatchQueue> {
  final String id;
  final String franchiseKey;
  final String state;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WatchQueue({
    required this.id,
    required this.franchiseKey,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['franchise_key'] = Variable<String>(franchiseKey);
    map['state'] = Variable<String>(state);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WatchQueuesCompanion toCompanion(bool nullToAbsent) {
    return WatchQueuesCompanion(
      id: Value(id),
      franchiseKey: Value(franchiseKey),
      state: Value(state),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WatchQueue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchQueue(
      id: serializer.fromJson<String>(json['id']),
      franchiseKey: serializer.fromJson<String>(json['franchiseKey']),
      state: serializer.fromJson<String>(json['state']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'franchiseKey': serializer.toJson<String>(franchiseKey),
      'state': serializer.toJson<String>(state),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WatchQueue copyWith({
    String? id,
    String? franchiseKey,
    String? state,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WatchQueue(
    id: id ?? this.id,
    franchiseKey: franchiseKey ?? this.franchiseKey,
    state: state ?? this.state,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WatchQueue copyWithCompanion(WatchQueuesCompanion data) {
    return WatchQueue(
      id: data.id.present ? data.id.value : this.id,
      franchiseKey: data.franchiseKey.present
          ? data.franchiseKey.value
          : this.franchiseKey,
      state: data.state.present ? data.state.value : this.state,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchQueue(')
          ..write('id: $id, ')
          ..write('franchiseKey: $franchiseKey, ')
          ..write('state: $state, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, franchiseKey, state, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchQueue &&
          other.id == this.id &&
          other.franchiseKey == this.franchiseKey &&
          other.state == this.state &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WatchQueuesCompanion extends UpdateCompanion<WatchQueue> {
  final Value<String> id;
  final Value<String> franchiseKey;
  final Value<String> state;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WatchQueuesCompanion({
    this.id = const Value.absent(),
    this.franchiseKey = const Value.absent(),
    this.state = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchQueuesCompanion.insert({
    required String id,
    required String franchiseKey,
    required String state,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       franchiseKey = Value(franchiseKey),
       state = Value(state),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WatchQueue> custom({
    Expression<String>? id,
    Expression<String>? franchiseKey,
    Expression<String>? state,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (franchiseKey != null) 'franchise_key': franchiseKey,
      if (state != null) 'state': state,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchQueuesCompanion copyWith({
    Value<String>? id,
    Value<String>? franchiseKey,
    Value<String>? state,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WatchQueuesCompanion(
      id: id ?? this.id,
      franchiseKey: franchiseKey ?? this.franchiseKey,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (franchiseKey.present) {
      map['franchise_key'] = Variable<String>(franchiseKey.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchQueuesCompanion(')
          ..write('id: $id, ')
          ..write('franchiseKey: $franchiseKey, ')
          ..write('state: $state, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WatchQueueItemsTable extends WatchQueueItems
    with TableInfo<$WatchQueueItemsTable, WatchQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchQueueItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _queueIdMeta = const VerificationMeta(
    'queueId',
  );
  @override
  late final GeneratedColumn<String> queueId = GeneratedColumn<String>(
    'queue_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES watch_queues (id)',
    ),
  );
  static const VerificationMeta _animeIdMeta = const VerificationMeta(
    'animeId',
  );
  @override
  late final GeneratedColumn<int> animeId = GeneratedColumn<int>(
    'anime_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    queueId,
    animeId,
    position,
    mode,
    state,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_queue_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchQueueItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('queue_id')) {
      context.handle(
        _queueIdMeta,
        queueId.isAcceptableOrUnknown(data['queue_id']!, _queueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_queueIdMeta);
    }
    if (data.containsKey('anime_id')) {
      context.handle(
        _animeIdMeta,
        animeId.isAcceptableOrUnknown(data['anime_id']!, _animeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_animeIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {queueId, animeId};
  @override
  WatchQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchQueueItem(
      queueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}queue_id'],
      )!,
      animeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anime_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
    );
  }

  @override
  $WatchQueueItemsTable createAlias(String alias) {
    return $WatchQueueItemsTable(attachedDatabase, alias);
  }
}

class WatchQueueItem extends DataClass implements Insertable<WatchQueueItem> {
  final String queueId;
  final int animeId;
  final int position;
  final String mode;
  final String state;
  const WatchQueueItem({
    required this.queueId,
    required this.animeId,
    required this.position,
    required this.mode,
    required this.state,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['queue_id'] = Variable<String>(queueId);
    map['anime_id'] = Variable<int>(animeId);
    map['position'] = Variable<int>(position);
    map['mode'] = Variable<String>(mode);
    map['state'] = Variable<String>(state);
    return map;
  }

  WatchQueueItemsCompanion toCompanion(bool nullToAbsent) {
    return WatchQueueItemsCompanion(
      queueId: Value(queueId),
      animeId: Value(animeId),
      position: Value(position),
      mode: Value(mode),
      state: Value(state),
    );
  }

  factory WatchQueueItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchQueueItem(
      queueId: serializer.fromJson<String>(json['queueId']),
      animeId: serializer.fromJson<int>(json['animeId']),
      position: serializer.fromJson<int>(json['position']),
      mode: serializer.fromJson<String>(json['mode']),
      state: serializer.fromJson<String>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'queueId': serializer.toJson<String>(queueId),
      'animeId': serializer.toJson<int>(animeId),
      'position': serializer.toJson<int>(position),
      'mode': serializer.toJson<String>(mode),
      'state': serializer.toJson<String>(state),
    };
  }

  WatchQueueItem copyWith({
    String? queueId,
    int? animeId,
    int? position,
    String? mode,
    String? state,
  }) => WatchQueueItem(
    queueId: queueId ?? this.queueId,
    animeId: animeId ?? this.animeId,
    position: position ?? this.position,
    mode: mode ?? this.mode,
    state: state ?? this.state,
  );
  WatchQueueItem copyWithCompanion(WatchQueueItemsCompanion data) {
    return WatchQueueItem(
      queueId: data.queueId.present ? data.queueId.value : this.queueId,
      animeId: data.animeId.present ? data.animeId.value : this.animeId,
      position: data.position.present ? data.position.value : this.position,
      mode: data.mode.present ? data.mode.value : this.mode,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchQueueItem(')
          ..write('queueId: $queueId, ')
          ..write('animeId: $animeId, ')
          ..write('position: $position, ')
          ..write('mode: $mode, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(queueId, animeId, position, mode, state);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchQueueItem &&
          other.queueId == this.queueId &&
          other.animeId == this.animeId &&
          other.position == this.position &&
          other.mode == this.mode &&
          other.state == this.state);
}

class WatchQueueItemsCompanion extends UpdateCompanion<WatchQueueItem> {
  final Value<String> queueId;
  final Value<int> animeId;
  final Value<int> position;
  final Value<String> mode;
  final Value<String> state;
  final Value<int> rowid;
  const WatchQueueItemsCompanion({
    this.queueId = const Value.absent(),
    this.animeId = const Value.absent(),
    this.position = const Value.absent(),
    this.mode = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchQueueItemsCompanion.insert({
    required String queueId,
    required int animeId,
    required int position,
    required String mode,
    required String state,
    this.rowid = const Value.absent(),
  }) : queueId = Value(queueId),
       animeId = Value(animeId),
       position = Value(position),
       mode = Value(mode),
       state = Value(state);
  static Insertable<WatchQueueItem> custom({
    Expression<String>? queueId,
    Expression<int>? animeId,
    Expression<int>? position,
    Expression<String>? mode,
    Expression<String>? state,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (queueId != null) 'queue_id': queueId,
      if (animeId != null) 'anime_id': animeId,
      if (position != null) 'position': position,
      if (mode != null) 'mode': mode,
      if (state != null) 'state': state,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchQueueItemsCompanion copyWith({
    Value<String>? queueId,
    Value<int>? animeId,
    Value<int>? position,
    Value<String>? mode,
    Value<String>? state,
    Value<int>? rowid,
  }) {
    return WatchQueueItemsCompanion(
      queueId: queueId ?? this.queueId,
      animeId: animeId ?? this.animeId,
      position: position ?? this.position,
      mode: mode ?? this.mode,
      state: state ?? this.state,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (queueId.present) {
      map['queue_id'] = Variable<String>(queueId.value);
    }
    if (animeId.present) {
      map['anime_id'] = Variable<int>(animeId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchQueueItemsCompanion(')
          ..write('queueId: $queueId, ')
          ..write('animeId: $animeId, ')
          ..write('position: $position, ')
          ..write('mode: $mode, ')
          ..write('state: $state, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WatchLinksTable extends WatchLinks
    with TableInfo<$WatchLinksTable, WatchLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _animeIdMeta = const VerificationMeta(
    'animeId',
  );
  @override
  late final GeneratedColumn<int> animeId = GeneratedColumn<int>(
    'anime_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    animeId,
    label,
    url,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('anime_id')) {
      context.handle(
        _animeIdMeta,
        animeId.isAcceptableOrUnknown(data['anime_id']!, _animeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_animeIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      animeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anime_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $WatchLinksTable createAlias(String alias) {
    return $WatchLinksTable(attachedDatabase, alias);
  }
}

class WatchLink extends DataClass implements Insertable<WatchLink> {
  final String id;
  final int animeId;
  final String label;
  final String url;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const WatchLink({
    required this.id,
    required this.animeId,
    required this.label,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['anime_id'] = Variable<int>(animeId);
    map['label'] = Variable<String>(label);
    map['url'] = Variable<String>(url);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  WatchLinksCompanion toCompanion(bool nullToAbsent) {
    return WatchLinksCompanion(
      id: Value(id),
      animeId: Value(animeId),
      label: Value(label),
      url: Value(url),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory WatchLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchLink(
      id: serializer.fromJson<String>(json['id']),
      animeId: serializer.fromJson<int>(json['animeId']),
      label: serializer.fromJson<String>(json['label']),
      url: serializer.fromJson<String>(json['url']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'animeId': serializer.toJson<int>(animeId),
      'label': serializer.toJson<String>(label),
      'url': serializer.toJson<String>(url),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  WatchLink copyWith({
    String? id,
    int? animeId,
    String? label,
    String? url,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => WatchLink(
    id: id ?? this.id,
    animeId: animeId ?? this.animeId,
    label: label ?? this.label,
    url: url ?? this.url,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  WatchLink copyWithCompanion(WatchLinksCompanion data) {
    return WatchLink(
      id: data.id.present ? data.id.value : this.id,
      animeId: data.animeId.present ? data.animeId.value : this.animeId,
      label: data.label.present ? data.label.value : this.label,
      url: data.url.present ? data.url.value : this.url,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchLink(')
          ..write('id: $id, ')
          ..write('animeId: $animeId, ')
          ..write('label: $label, ')
          ..write('url: $url, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, animeId, label, url, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchLink &&
          other.id == this.id &&
          other.animeId == this.animeId &&
          other.label == this.label &&
          other.url == this.url &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class WatchLinksCompanion extends UpdateCompanion<WatchLink> {
  final Value<String> id;
  final Value<int> animeId;
  final Value<String> label;
  final Value<String> url;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const WatchLinksCompanion({
    this.id = const Value.absent(),
    this.animeId = const Value.absent(),
    this.label = const Value.absent(),
    this.url = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchLinksCompanion.insert({
    required String id,
    required int animeId,
    required String label,
    required String url,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       animeId = Value(animeId),
       label = Value(label),
       url = Value(url),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WatchLink> custom({
    Expression<String>? id,
    Expression<int>? animeId,
    Expression<String>? label,
    Expression<String>? url,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animeId != null) 'anime_id': animeId,
      if (label != null) 'label': label,
      if (url != null) 'url': url,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchLinksCompanion copyWith({
    Value<String>? id,
    Value<int>? animeId,
    Value<String>? label,
    Value<String>? url,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return WatchLinksCompanion(
      id: id ?? this.id,
      animeId: animeId ?? this.animeId,
      label: label ?? this.label,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (animeId.present) {
      map['anime_id'] = Variable<int>(animeId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchLinksCompanion(')
          ..write('id: $id, ')
          ..write('animeId: $animeId, ')
          ..write('label: $label, ')
          ..write('url: $url, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SiteEpisodesTable extends SiteEpisodes
    with TableInfo<$SiteEpisodesTable, SiteEpisode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SiteEpisodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _animeIdMeta = const VerificationMeta(
    'animeId',
  );
  @override
  late final GeneratedColumn<int> animeId = GeneratedColumn<int>(
    'anime_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dubbingMeta = const VerificationMeta(
    'dubbing',
  );
  @override
  late final GeneratedColumn<String> dubbing = GeneratedColumn<String>(
    'dubbing',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _episodesMeta = const VerificationMeta(
    'episodes',
  );
  @override
  late final GeneratedColumn<int> episodes = GeneratedColumn<int>(
    'episodes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [animeId, dubbing, episodes, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'site_episodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SiteEpisode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('anime_id')) {
      context.handle(
        _animeIdMeta,
        animeId.isAcceptableOrUnknown(data['anime_id']!, _animeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_animeIdMeta);
    }
    if (data.containsKey('dubbing')) {
      context.handle(
        _dubbingMeta,
        dubbing.isAcceptableOrUnknown(data['dubbing']!, _dubbingMeta),
      );
    } else if (isInserting) {
      context.missing(_dubbingMeta);
    }
    if (data.containsKey('episodes')) {
      context.handle(
        _episodesMeta,
        episodes.isAcceptableOrUnknown(data['episodes']!, _episodesMeta),
      );
    } else if (isInserting) {
      context.missing(_episodesMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {animeId, dubbing};
  @override
  SiteEpisode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SiteEpisode(
      animeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anime_id'],
      )!,
      dubbing: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dubbing'],
      )!,
      episodes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episodes'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SiteEpisodesTable createAlias(String alias) {
    return $SiteEpisodesTable(attachedDatabase, alias);
  }
}

class SiteEpisode extends DataClass implements Insertable<SiteEpisode> {
  final int animeId;
  final String dubbing;
  final int episodes;
  final DateTime updatedAt;
  const SiteEpisode({
    required this.animeId,
    required this.dubbing,
    required this.episodes,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['anime_id'] = Variable<int>(animeId);
    map['dubbing'] = Variable<String>(dubbing);
    map['episodes'] = Variable<int>(episodes);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SiteEpisodesCompanion toCompanion(bool nullToAbsent) {
    return SiteEpisodesCompanion(
      animeId: Value(animeId),
      dubbing: Value(dubbing),
      episodes: Value(episodes),
      updatedAt: Value(updatedAt),
    );
  }

  factory SiteEpisode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SiteEpisode(
      animeId: serializer.fromJson<int>(json['animeId']),
      dubbing: serializer.fromJson<String>(json['dubbing']),
      episodes: serializer.fromJson<int>(json['episodes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'animeId': serializer.toJson<int>(animeId),
      'dubbing': serializer.toJson<String>(dubbing),
      'episodes': serializer.toJson<int>(episodes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SiteEpisode copyWith({
    int? animeId,
    String? dubbing,
    int? episodes,
    DateTime? updatedAt,
  }) => SiteEpisode(
    animeId: animeId ?? this.animeId,
    dubbing: dubbing ?? this.dubbing,
    episodes: episodes ?? this.episodes,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SiteEpisode copyWithCompanion(SiteEpisodesCompanion data) {
    return SiteEpisode(
      animeId: data.animeId.present ? data.animeId.value : this.animeId,
      dubbing: data.dubbing.present ? data.dubbing.value : this.dubbing,
      episodes: data.episodes.present ? data.episodes.value : this.episodes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SiteEpisode(')
          ..write('animeId: $animeId, ')
          ..write('dubbing: $dubbing, ')
          ..write('episodes: $episodes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(animeId, dubbing, episodes, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SiteEpisode &&
          other.animeId == this.animeId &&
          other.dubbing == this.dubbing &&
          other.episodes == this.episodes &&
          other.updatedAt == this.updatedAt);
}

class SiteEpisodesCompanion extends UpdateCompanion<SiteEpisode> {
  final Value<int> animeId;
  final Value<String> dubbing;
  final Value<int> episodes;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SiteEpisodesCompanion({
    this.animeId = const Value.absent(),
    this.dubbing = const Value.absent(),
    this.episodes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SiteEpisodesCompanion.insert({
    required int animeId,
    required String dubbing,
    required int episodes,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : animeId = Value(animeId),
       dubbing = Value(dubbing),
       episodes = Value(episodes),
       updatedAt = Value(updatedAt);
  static Insertable<SiteEpisode> custom({
    Expression<int>? animeId,
    Expression<String>? dubbing,
    Expression<int>? episodes,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (animeId != null) 'anime_id': animeId,
      if (dubbing != null) 'dubbing': dubbing,
      if (episodes != null) 'episodes': episodes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SiteEpisodesCompanion copyWith({
    Value<int>? animeId,
    Value<String>? dubbing,
    Value<int>? episodes,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SiteEpisodesCompanion(
      animeId: animeId ?? this.animeId,
      dubbing: dubbing ?? this.dubbing,
      episodes: episodes ?? this.episodes,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (animeId.present) {
      map['anime_id'] = Variable<int>(animeId.value);
    }
    if (dubbing.present) {
      map['dubbing'] = Variable<String>(dubbing.value);
    }
    if (episodes.present) {
      map['episodes'] = Variable<int>(episodes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SiteEpisodesCompanion(')
          ..write('animeId: $animeId, ')
          ..write('dubbing: $dubbing, ')
          ..write('episodes: $episodes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AnimesTable animes = $AnimesTable(this);
  late final $LibraryEntriesTable libraryEntries = $LibraryEntriesTable(this);
  late final $WatchCyclesTable watchCycles = $WatchCyclesTable(this);
  late final $WatchEventsTable watchEvents = $WatchEventsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $AnimeRelationsTable animeRelations = $AnimeRelationsTable(this);
  late final $FranchisesTable franchises = $FranchisesTable(this);
  late final $UserGroupsTable userGroups = $UserGroupsTable(this);
  late final $UserGroupMembersTable userGroupMembers = $UserGroupMembersTable(
    this,
  );
  late final $WatchQueuesTable watchQueues = $WatchQueuesTable(this);
  late final $WatchQueueItemsTable watchQueueItems = $WatchQueueItemsTable(
    this,
  );
  late final $WatchLinksTable watchLinks = $WatchLinksTable(this);
  late final $SiteEpisodesTable siteEpisodes = $SiteEpisodesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    animes,
    libraryEntries,
    watchCycles,
    watchEvents,
    appSettings,
    animeRelations,
    franchises,
    userGroups,
    userGroupMembers,
    watchQueues,
    watchQueueItems,
    watchLinks,
    siteEpisodes,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$AnimesTableCreateCompanionBuilder = AnimesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> russian,
  Value<String?> kind,
  Value<double?> shikimoriScore,
  Value<int> episodes,
  Value<int> episodesAired,
  Value<String?> releaseStatus,
  Value<DateTime?> nextEpisodeAt,
  Value<String?> airedOn,
  Value<String?> posterUrl,
  required DateTime updatedAt,
  Value<String?> description,
  Value<String?> genres,
  Value<String?> studios,
  Value<int?> episodeDuration,
  Value<String?> ageRating,
  Value<DateTime?> detailsLoadedAt,
  Value<String?> franchise,
});
typedef $$AnimesTableUpdateCompanionBuilder = AnimesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> russian,
  Value<String?> kind,
  Value<double?> shikimoriScore,
  Value<int> episodes,
  Value<int> episodesAired,
  Value<String?> releaseStatus,
  Value<DateTime?> nextEpisodeAt,
  Value<String?> airedOn,
  Value<String?> posterUrl,
  Value<DateTime> updatedAt,
  Value<String?> description,
  Value<String?> genres,
  Value<String?> studios,
  Value<int?> episodeDuration,
  Value<String?> ageRating,
  Value<DateTime?> detailsLoadedAt,
  Value<String?> franchise,
});

final class $$AnimesTableReferences
    extends BaseReferences<_$AppDatabase, $AnimesTable, Anime> {
  $$AnimesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LibraryEntriesTable, List<LibraryEntry>>
  _libraryEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.libraryEntries,
    aliasName: 'animes__id__library_entries__anime_id',
  );

  $$LibraryEntriesTableProcessedTableManager get libraryEntriesRefs {
    final manager = $$LibraryEntriesTableTableManager(
      $_db,
      $_db.libraryEntries,
    ).filter((f) => f.animeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_libraryEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AnimesTableFilterComposer
    extends Composer<_$AppDatabase, $AnimesTable> {
  $$AnimesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get russian => $composableBuilder(
    column: $table.russian,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get shikimoriScore => $composableBuilder(
    column: $table.shikimoriScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episodes => $composableBuilder(
    column: $table.episodes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episodesAired => $composableBuilder(
    column: $table.episodesAired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get releaseStatus => $composableBuilder(
    column: $table.releaseStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextEpisodeAt => $composableBuilder(
    column: $table.nextEpisodeAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get airedOn => $composableBuilder(
    column: $table.airedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterUrl => $composableBuilder(
    column: $table.posterUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studios => $composableBuilder(
    column: $table.studios,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episodeDuration => $composableBuilder(
    column: $table.episodeDuration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ageRating => $composableBuilder(
    column: $table.ageRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detailsLoadedAt => $composableBuilder(
    column: $table.detailsLoadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get franchise => $composableBuilder(
    column: $table.franchise,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> libraryEntriesRefs(
    Expression<bool> Function($$LibraryEntriesTableFilterComposer f) f,
  ) {
    final $$LibraryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.libraryEntries,
      getReferencedColumn: (t) => t.animeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.libraryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AnimesTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimesTable> {
  $$AnimesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get russian => $composableBuilder(
    column: $table.russian,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get shikimoriScore => $composableBuilder(
    column: $table.shikimoriScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episodes => $composableBuilder(
    column: $table.episodes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episodesAired => $composableBuilder(
    column: $table.episodesAired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get releaseStatus => $composableBuilder(
    column: $table.releaseStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextEpisodeAt => $composableBuilder(
    column: $table.nextEpisodeAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get airedOn => $composableBuilder(
    column: $table.airedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterUrl => $composableBuilder(
    column: $table.posterUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studios => $composableBuilder(
    column: $table.studios,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episodeDuration => $composableBuilder(
    column: $table.episodeDuration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ageRating => $composableBuilder(
    column: $table.ageRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detailsLoadedAt => $composableBuilder(
    column: $table.detailsLoadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get franchise => $composableBuilder(
    column: $table.franchise,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnimesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimesTable> {
  $$AnimesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get russian =>
      $composableBuilder(column: $table.russian, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get shikimoriScore => $composableBuilder(
    column: $table.shikimoriScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get episodes =>
      $composableBuilder(column: $table.episodes, builder: (column) => column);

  GeneratedColumn<int> get episodesAired => $composableBuilder(
    column: $table.episodesAired,
    builder: (column) => column,
  );

  GeneratedColumn<String> get releaseStatus => $composableBuilder(
    column: $table.releaseStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextEpisodeAt => $composableBuilder(
    column: $table.nextEpisodeAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get airedOn =>
      $composableBuilder(column: $table.airedOn, builder: (column) => column);

  GeneratedColumn<String> get posterUrl =>
      $composableBuilder(column: $table.posterUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genres =>
      $composableBuilder(column: $table.genres, builder: (column) => column);

  GeneratedColumn<String> get studios =>
      $composableBuilder(column: $table.studios, builder: (column) => column);

  GeneratedColumn<int> get episodeDuration => $composableBuilder(
    column: $table.episodeDuration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ageRating =>
      $composableBuilder(column: $table.ageRating, builder: (column) => column);

  GeneratedColumn<DateTime> get detailsLoadedAt => $composableBuilder(
    column: $table.detailsLoadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get franchise =>
      $composableBuilder(column: $table.franchise, builder: (column) => column);

  Expression<T> libraryEntriesRefs<T extends Object>(
    Expression<T> Function($$LibraryEntriesTableAnnotationComposer a) f,
  ) {
    final $$LibraryEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.libraryEntries,
      getReferencedColumn: (t) => t.animeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.libraryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AnimesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnimesTable,
          Anime,
          $$AnimesTableFilterComposer,
          $$AnimesTableOrderingComposer,
          $$AnimesTableAnnotationComposer,
          $$AnimesTableCreateCompanionBuilder,
          $$AnimesTableUpdateCompanionBuilder,
          (Anime, $$AnimesTableReferences),
          Anime,
          PrefetchHooks Function({bool libraryEntriesRefs})
        > {
  $$AnimesTableTableManager(_$AppDatabase db, $AnimesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> russian = const Value.absent(),
                Value<String?> kind = const Value.absent(),
                Value<double?> shikimoriScore = const Value.absent(),
                Value<int> episodes = const Value.absent(),
                Value<int> episodesAired = const Value.absent(),
                Value<String?> releaseStatus = const Value.absent(),
                Value<DateTime?> nextEpisodeAt = const Value.absent(),
                Value<String?> airedOn = const Value.absent(),
                Value<String?> posterUrl = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<String?> studios = const Value.absent(),
                Value<int?> episodeDuration = const Value.absent(),
                Value<String?> ageRating = const Value.absent(),
                Value<DateTime?> detailsLoadedAt = const Value.absent(),
                Value<String?> franchise = const Value.absent(),
              }) => AnimesCompanion(
                id: id,
                name: name,
                russian: russian,
                kind: kind,
                shikimoriScore: shikimoriScore,
                episodes: episodes,
                episodesAired: episodesAired,
                releaseStatus: releaseStatus,
                nextEpisodeAt: nextEpisodeAt,
                airedOn: airedOn,
                posterUrl: posterUrl,
                updatedAt: updatedAt,
                description: description,
                genres: genres,
                studios: studios,
                episodeDuration: episodeDuration,
                ageRating: ageRating,
                detailsLoadedAt: detailsLoadedAt,
                franchise: franchise,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> russian = const Value.absent(),
                Value<String?> kind = const Value.absent(),
                Value<double?> shikimoriScore = const Value.absent(),
                Value<int> episodes = const Value.absent(),
                Value<int> episodesAired = const Value.absent(),
                Value<String?> releaseStatus = const Value.absent(),
                Value<DateTime?> nextEpisodeAt = const Value.absent(),
                Value<String?> airedOn = const Value.absent(),
                Value<String?> posterUrl = const Value.absent(),
                required DateTime updatedAt,
                Value<String?> description = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<String?> studios = const Value.absent(),
                Value<int?> episodeDuration = const Value.absent(),
                Value<String?> ageRating = const Value.absent(),
                Value<DateTime?> detailsLoadedAt = const Value.absent(),
                Value<String?> franchise = const Value.absent(),
              }) => AnimesCompanion.insert(
                id: id,
                name: name,
                russian: russian,
                kind: kind,
                shikimoriScore: shikimoriScore,
                episodes: episodes,
                episodesAired: episodesAired,
                releaseStatus: releaseStatus,
                nextEpisodeAt: nextEpisodeAt,
                airedOn: airedOn,
                posterUrl: posterUrl,
                updatedAt: updatedAt,
                description: description,
                genres: genres,
                studios: studios,
                episodeDuration: episodeDuration,
                ageRating: ageRating,
                detailsLoadedAt: detailsLoadedAt,
                franchise: franchise,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AnimesTable, Anime>(table),
                  $$AnimesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({libraryEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (libraryEntriesRefs) db.libraryEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (libraryEntriesRefs)
                    await $_getPrefetchedData<
                      Anime,
                      $AnimesTable,
                      LibraryEntry
                    >(
                      currentTable: table,
                      referencedTable: $$AnimesTableReferences
                          ._libraryEntriesRefsTable(db),
                      managerFromTypedResult: (p0) => $$AnimesTableReferences(
                        db,
                        table,
                        p0,
                      ).libraryEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.animeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AnimesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnimesTable,
      Anime,
      $$AnimesTableFilterComposer,
      $$AnimesTableOrderingComposer,
      $$AnimesTableAnnotationComposer,
      $$AnimesTableCreateCompanionBuilder,
      $$AnimesTableUpdateCompanionBuilder,
      (Anime, $$AnimesTableReferences),
      Anime,
      PrefetchHooks Function({bool libraryEntriesRefs})
    >;
typedef $$LibraryEntriesTableCreateCompanionBuilder =
    LibraryEntriesCompanion Function({
      required String id,
      required int animeId,
      required String status,
      Value<int?> score,
      Value<String> note,
      required DateTime addedAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> franchiseOverride,
      Value<bool> muted,
      Value<String?> dubbing,
      Value<String?> dubbingSeen,
      Value<int> rowid,
    });
typedef $$LibraryEntriesTableUpdateCompanionBuilder =
    LibraryEntriesCompanion Function({
      Value<String> id,
      Value<int> animeId,
      Value<String> status,
      Value<int?> score,
      Value<String> note,
      Value<DateTime> addedAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> franchiseOverride,
      Value<bool> muted,
      Value<String?> dubbing,
      Value<String?> dubbingSeen,
      Value<int> rowid,
    });

final class $$LibraryEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $LibraryEntriesTable, LibraryEntry> {
  $$LibraryEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AnimesTable _animeIdTable(_$AppDatabase db) =>
      db.animes.createAlias('library_entries__anime_id__animes__id');

  $$AnimesTableProcessedTableManager get animeId {
    final $_column = $_itemColumn<int>('anime_id')!;

    final manager = $$AnimesTableTableManager(
      $_db,
      $_db.animes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_animeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WatchCyclesTable, List<WatchCycle>>
  _watchCyclesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.watchCycles,
    aliasName: 'library_entries__id__watch_cycles__entry_id',
  );

  $$WatchCyclesTableProcessedTableManager get watchCyclesRefs {
    final manager = $$WatchCyclesTableTableManager(
      $_db,
      $_db.watchCycles,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_watchCyclesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LibraryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get franchiseOverride => $composableBuilder(
    column: $table.franchiseOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get muted => $composableBuilder(
    column: $table.muted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dubbing => $composableBuilder(
    column: $table.dubbing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dubbingSeen => $composableBuilder(
    column: $table.dubbingSeen,
    builder: (column) => ColumnFilters(column),
  );

  $$AnimesTableFilterComposer get animeId {
    final $$AnimesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.animeId,
      referencedTable: $db.animes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnimesTableFilterComposer(
            $db: $db,
            $table: $db.animes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> watchCyclesRefs(
    Expression<bool> Function($$WatchCyclesTableFilterComposer f) f,
  ) {
    final $$WatchCyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.watchCycles,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchCyclesTableFilterComposer(
            $db: $db,
            $table: $db.watchCycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LibraryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get franchiseOverride => $composableBuilder(
    column: $table.franchiseOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get muted => $composableBuilder(
    column: $table.muted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dubbing => $composableBuilder(
    column: $table.dubbing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dubbingSeen => $composableBuilder(
    column: $table.dubbingSeen,
    builder: (column) => ColumnOrderings(column),
  );

  $$AnimesTableOrderingComposer get animeId {
    final $$AnimesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.animeId,
      referencedTable: $db.animes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnimesTableOrderingComposer(
            $db: $db,
            $table: $db.animes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LibraryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get franchiseOverride => $composableBuilder(
    column: $table.franchiseOverride,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get muted =>
      $composableBuilder(column: $table.muted, builder: (column) => column);

  GeneratedColumn<String> get dubbing =>
      $composableBuilder(column: $table.dubbing, builder: (column) => column);

  GeneratedColumn<String> get dubbingSeen => $composableBuilder(
    column: $table.dubbingSeen,
    builder: (column) => column,
  );

  $$AnimesTableAnnotationComposer get animeId {
    final $$AnimesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.animeId,
      referencedTable: $db.animes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnimesTableAnnotationComposer(
            $db: $db,
            $table: $db.animes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> watchCyclesRefs<T extends Object>(
    Expression<T> Function($$WatchCyclesTableAnnotationComposer a) f,
  ) {
    final $$WatchCyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.watchCycles,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchCyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.watchCycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LibraryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryEntriesTable,
          LibraryEntry,
          $$LibraryEntriesTableFilterComposer,
          $$LibraryEntriesTableOrderingComposer,
          $$LibraryEntriesTableAnnotationComposer,
          $$LibraryEntriesTableCreateCompanionBuilder,
          $$LibraryEntriesTableUpdateCompanionBuilder,
          (LibraryEntry, $$LibraryEntriesTableReferences),
          LibraryEntry,
          PrefetchHooks Function({bool animeId, bool watchCyclesRefs})
        > {
  $$LibraryEntriesTableTableManager(
    _$AppDatabase db,
    $LibraryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> animeId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> franchiseOverride = const Value.absent(),
                Value<bool> muted = const Value.absent(),
                Value<String?> dubbing = const Value.absent(),
                Value<String?> dubbingSeen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryEntriesCompanion(
                id: id,
                animeId: animeId,
                status: status,
                score: score,
                note: note,
                addedAt: addedAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                franchiseOverride: franchiseOverride,
                muted: muted,
                dubbing: dubbing,
                dubbingSeen: dubbingSeen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int animeId,
                required String status,
                Value<int?> score = const Value.absent(),
                Value<String> note = const Value.absent(),
                required DateTime addedAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> franchiseOverride = const Value.absent(),
                Value<bool> muted = const Value.absent(),
                Value<String?> dubbing = const Value.absent(),
                Value<String?> dubbingSeen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryEntriesCompanion.insert(
                id: id,
                animeId: animeId,
                status: status,
                score: score,
                note: note,
                addedAt: addedAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                franchiseOverride: franchiseOverride,
                muted: muted,
                dubbing: dubbing,
                dubbingSeen: dubbingSeen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LibraryEntriesTable, LibraryEntry>(table),
                  $$LibraryEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({animeId = false, watchCyclesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (watchCyclesRefs) db.watchCycles],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (animeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.animeId,
                        referencedTable: $$LibraryEntriesTableReferences
                            ._animeIdTable(db),
                        referencedColumn: $$LibraryEntriesTableReferences
                            ._animeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (watchCyclesRefs)
                    await $_getPrefetchedData<
                      LibraryEntry,
                      $LibraryEntriesTable,
                      WatchCycle
                    >(
                      currentTable: table,
                      referencedTable: $$LibraryEntriesTableReferences
                          ._watchCyclesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LibraryEntriesTableReferences(
                            db,
                            table,
                            p0,
                          ).watchCyclesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.entryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LibraryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryEntriesTable,
      LibraryEntry,
      $$LibraryEntriesTableFilterComposer,
      $$LibraryEntriesTableOrderingComposer,
      $$LibraryEntriesTableAnnotationComposer,
      $$LibraryEntriesTableCreateCompanionBuilder,
      $$LibraryEntriesTableUpdateCompanionBuilder,
      (LibraryEntry, $$LibraryEntriesTableReferences),
      LibraryEntry,
      PrefetchHooks Function({bool animeId, bool watchCyclesRefs})
    >;
typedef $$WatchCyclesTableCreateCompanionBuilder =
    WatchCyclesCompanion Function({
      required String id,
      required String entryId,
      required int number,
      required String state,
      Value<DateTime?> startedAt,
      Value<DateTime?> finishedAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$WatchCyclesTableUpdateCompanionBuilder =
    WatchCyclesCompanion Function({
      Value<String> id,
      Value<String> entryId,
      Value<int> number,
      Value<String> state,
      Value<DateTime?> startedAt,
      Value<DateTime?> finishedAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$WatchCyclesTableReferences
    extends BaseReferences<_$AppDatabase, $WatchCyclesTable, WatchCycle> {
  $$WatchCyclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LibraryEntriesTable _entryIdTable(_$AppDatabase db) => db
      .libraryEntries
      .createAlias('watch_cycles__entry_id__library_entries__id');

  $$LibraryEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $$LibraryEntriesTableTableManager(
      $_db,
      $_db.libraryEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WatchEventsTable, List<WatchEvent>>
  _watchEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.watchEvents,
    aliasName: 'watch_cycles__id__watch_events__cycle_id',
  );

  $$WatchEventsTableProcessedTableManager get watchEventsRefs {
    final manager = $$WatchEventsTableTableManager(
      $_db,
      $_db.watchEvents,
    ).filter((f) => f.cycleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_watchEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WatchCyclesTableFilterComposer
    extends Composer<_$AppDatabase, $WatchCyclesTable> {
  $$WatchCyclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LibraryEntriesTableFilterComposer get entryId {
    final $$LibraryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.libraryEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.libraryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> watchEventsRefs(
    Expression<bool> Function($$WatchEventsTableFilterComposer f) f,
  ) {
    final $$WatchEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.watchEvents,
      getReferencedColumn: (t) => t.cycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchEventsTableFilterComposer(
            $db: $db,
            $table: $db.watchEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WatchCyclesTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchCyclesTable> {
  $$WatchCyclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LibraryEntriesTableOrderingComposer get entryId {
    final $$LibraryEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.libraryEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.libraryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchCyclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchCyclesTable> {
  $$WatchCyclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$LibraryEntriesTableAnnotationComposer get entryId {
    final $$LibraryEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.libraryEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.libraryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> watchEventsRefs<T extends Object>(
    Expression<T> Function($$WatchEventsTableAnnotationComposer a) f,
  ) {
    final $$WatchEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.watchEvents,
      getReferencedColumn: (t) => t.cycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.watchEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WatchCyclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchCyclesTable,
          WatchCycle,
          $$WatchCyclesTableFilterComposer,
          $$WatchCyclesTableOrderingComposer,
          $$WatchCyclesTableAnnotationComposer,
          $$WatchCyclesTableCreateCompanionBuilder,
          $$WatchCyclesTableUpdateCompanionBuilder,
          (WatchCycle, $$WatchCyclesTableReferences),
          WatchCycle,
          PrefetchHooks Function({bool entryId, bool watchEventsRefs})
        > {
  $$WatchCyclesTableTableManager(_$AppDatabase db, $WatchCyclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchCyclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchCyclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchCyclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchCyclesCompanion(
                id: id,
                entryId: entryId,
                number: number,
                state: state,
                startedAt: startedAt,
                finishedAt: finishedAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entryId,
                required int number,
                required String state,
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchCyclesCompanion.insert(
                id: id,
                entryId: entryId,
                number: number,
                state: state,
                startedAt: startedAt,
                finishedAt: finishedAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WatchCyclesTable, WatchCycle>(table),
                  $$WatchCyclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false, watchEventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (watchEventsRefs) db.watchEvents],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.entryId,
                        referencedTable: $$WatchCyclesTableReferences
                            ._entryIdTable(db),
                        referencedColumn: $$WatchCyclesTableReferences
                            ._entryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (watchEventsRefs)
                    await $_getPrefetchedData<
                      WatchCycle,
                      $WatchCyclesTable,
                      WatchEvent
                    >(
                      currentTable: table,
                      referencedTable: $$WatchCyclesTableReferences
                          ._watchEventsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WatchCyclesTableReferences(
                            db,
                            table,
                            p0,
                          ).watchEventsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.cycleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WatchCyclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchCyclesTable,
      WatchCycle,
      $$WatchCyclesTableFilterComposer,
      $$WatchCyclesTableOrderingComposer,
      $$WatchCyclesTableAnnotationComposer,
      $$WatchCyclesTableCreateCompanionBuilder,
      $$WatchCyclesTableUpdateCompanionBuilder,
      (WatchCycle, $$WatchCyclesTableReferences),
      WatchCycle,
      PrefetchHooks Function({bool entryId, bool watchEventsRefs})
    >;
typedef $$WatchEventsTableCreateCompanionBuilder =
    WatchEventsCompanion Function({
      required String id,
      required String cycleId,
      required int episode,
      Value<DateTime?> watchedAt,
      required DateTime markedAt,
      Value<bool> beforeAired,
      Value<bool> bulk,
      Value<String?> source,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$WatchEventsTableUpdateCompanionBuilder =
    WatchEventsCompanion Function({
      Value<String> id,
      Value<String> cycleId,
      Value<int> episode,
      Value<DateTime?> watchedAt,
      Value<DateTime> markedAt,
      Value<bool> beforeAired,
      Value<bool> bulk,
      Value<String?> source,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$WatchEventsTableReferences
    extends BaseReferences<_$AppDatabase, $WatchEventsTable, WatchEvent> {
  $$WatchEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WatchCyclesTable _cycleIdTable(_$AppDatabase db) =>
      db.watchCycles.createAlias('watch_events__cycle_id__watch_cycles__id');

  $$WatchCyclesTableProcessedTableManager get cycleId {
    final $_column = $_itemColumn<String>('cycle_id')!;

    final manager = $$WatchCyclesTableTableManager(
      $_db,
      $_db.watchCycles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WatchEventsTableFilterComposer
    extends Composer<_$AppDatabase, $WatchEventsTable> {
  $$WatchEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episode => $composableBuilder(
    column: $table.episode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get watchedAt => $composableBuilder(
    column: $table.watchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get markedAt => $composableBuilder(
    column: $table.markedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get beforeAired => $composableBuilder(
    column: $table.beforeAired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bulk => $composableBuilder(
    column: $table.bulk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WatchCyclesTableFilterComposer get cycleId {
    final $$WatchCyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.watchCycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchCyclesTableFilterComposer(
            $db: $db,
            $table: $db.watchCycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchEventsTable> {
  $$WatchEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episode => $composableBuilder(
    column: $table.episode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get watchedAt => $composableBuilder(
    column: $table.watchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get markedAt => $composableBuilder(
    column: $table.markedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get beforeAired => $composableBuilder(
    column: $table.beforeAired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bulk => $composableBuilder(
    column: $table.bulk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WatchCyclesTableOrderingComposer get cycleId {
    final $$WatchCyclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.watchCycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchCyclesTableOrderingComposer(
            $db: $db,
            $table: $db.watchCycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchEventsTable> {
  $$WatchEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get episode =>
      $composableBuilder(column: $table.episode, builder: (column) => column);

  GeneratedColumn<DateTime> get watchedAt =>
      $composableBuilder(column: $table.watchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get markedAt =>
      $composableBuilder(column: $table.markedAt, builder: (column) => column);

  GeneratedColumn<bool> get beforeAired => $composableBuilder(
    column: $table.beforeAired,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get bulk =>
      $composableBuilder(column: $table.bulk, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$WatchCyclesTableAnnotationComposer get cycleId {
    final $$WatchCyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.watchCycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchCyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.watchCycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchEventsTable,
          WatchEvent,
          $$WatchEventsTableFilterComposer,
          $$WatchEventsTableOrderingComposer,
          $$WatchEventsTableAnnotationComposer,
          $$WatchEventsTableCreateCompanionBuilder,
          $$WatchEventsTableUpdateCompanionBuilder,
          (WatchEvent, $$WatchEventsTableReferences),
          WatchEvent,
          PrefetchHooks Function({bool cycleId})
        > {
  $$WatchEventsTableTableManager(_$AppDatabase db, $WatchEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cycleId = const Value.absent(),
                Value<int> episode = const Value.absent(),
                Value<DateTime?> watchedAt = const Value.absent(),
                Value<DateTime> markedAt = const Value.absent(),
                Value<bool> beforeAired = const Value.absent(),
                Value<bool> bulk = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchEventsCompanion(
                id: id,
                cycleId: cycleId,
                episode: episode,
                watchedAt: watchedAt,
                markedAt: markedAt,
                beforeAired: beforeAired,
                bulk: bulk,
                source: source,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cycleId,
                required int episode,
                Value<DateTime?> watchedAt = const Value.absent(),
                required DateTime markedAt,
                Value<bool> beforeAired = const Value.absent(),
                Value<bool> bulk = const Value.absent(),
                Value<String?> source = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchEventsCompanion.insert(
                id: id,
                cycleId: cycleId,
                episode: episode,
                watchedAt: watchedAt,
                markedAt: markedAt,
                beforeAired: beforeAired,
                bulk: bulk,
                source: source,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WatchEventsTable, WatchEvent>(table),
                  $$WatchEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cycleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cycleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cycleId,
                        referencedTable: $$WatchEventsTableReferences
                            ._cycleIdTable(db),
                        referencedColumn: $$WatchEventsTableReferences
                            ._cycleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WatchEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchEventsTable,
      WatchEvent,
      $$WatchEventsTableFilterComposer,
      $$WatchEventsTableOrderingComposer,
      $$WatchEventsTableAnnotationComposer,
      $$WatchEventsTableCreateCompanionBuilder,
      $$WatchEventsTableUpdateCompanionBuilder,
      (WatchEvent, $$WatchEventsTableReferences),
      WatchEvent,
      PrefetchHooks Function({bool cycleId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$AnimeRelationsTableCreateCompanionBuilder =
    AnimeRelationsCompanion Function({
      required int animeId,
      required int relatedId,
      required String relation,
      Value<int> rowid,
    });
typedef $$AnimeRelationsTableUpdateCompanionBuilder =
    AnimeRelationsCompanion Function({
      Value<int> animeId,
      Value<int> relatedId,
      Value<String> relation,
      Value<int> rowid,
    });

class $$AnimeRelationsTableFilterComposer
    extends Composer<_$AppDatabase, $AnimeRelationsTable> {
  $$AnimeRelationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get animeId => $composableBuilder(
    column: $table.animeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get relatedId => $composableBuilder(
    column: $table.relatedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnimeRelationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimeRelationsTable> {
  $$AnimeRelationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get animeId => $composableBuilder(
    column: $table.animeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get relatedId => $composableBuilder(
    column: $table.relatedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnimeRelationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimeRelationsTable> {
  $$AnimeRelationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get animeId =>
      $composableBuilder(column: $table.animeId, builder: (column) => column);

  GeneratedColumn<int> get relatedId =>
      $composableBuilder(column: $table.relatedId, builder: (column) => column);

  GeneratedColumn<String> get relation =>
      $composableBuilder(column: $table.relation, builder: (column) => column);
}

class $$AnimeRelationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnimeRelationsTable,
          AnimeRelation,
          $$AnimeRelationsTableFilterComposer,
          $$AnimeRelationsTableOrderingComposer,
          $$AnimeRelationsTableAnnotationComposer,
          $$AnimeRelationsTableCreateCompanionBuilder,
          $$AnimeRelationsTableUpdateCompanionBuilder,
          (
            AnimeRelation,
            BaseReferences<_$AppDatabase, $AnimeRelationsTable, AnimeRelation>,
          ),
          AnimeRelation,
          PrefetchHooks Function()
        > {
  $$AnimeRelationsTableTableManager(
    _$AppDatabase db,
    $AnimeRelationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimeRelationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimeRelationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimeRelationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> animeId = const Value.absent(),
                Value<int> relatedId = const Value.absent(),
                Value<String> relation = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnimeRelationsCompanion(
                animeId: animeId,
                relatedId: relatedId,
                relation: relation,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int animeId,
                required int relatedId,
                required String relation,
                Value<int> rowid = const Value.absent(),
              }) => AnimeRelationsCompanion.insert(
                animeId: animeId,
                relatedId: relatedId,
                relation: relation,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AnimeRelationsTable, AnimeRelation>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AnimeRelationsTable,
                    AnimeRelation
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnimeRelationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnimeRelationsTable,
      AnimeRelation,
      $$AnimeRelationsTableFilterComposer,
      $$AnimeRelationsTableOrderingComposer,
      $$AnimeRelationsTableAnnotationComposer,
      $$AnimeRelationsTableCreateCompanionBuilder,
      $$AnimeRelationsTableUpdateCompanionBuilder,
      (
        AnimeRelation,
        BaseReferences<_$AppDatabase, $AnimeRelationsTable, AnimeRelation>,
      ),
      AnimeRelation,
      PrefetchHooks Function()
    >;
typedef $$FranchisesTableCreateCompanionBuilder = FranchisesCompanion Function({
  required String key,
  Value<String?> name,
  Value<String?> autoName,
  Value<int?> coverAnimeId,
  Value<String?> dubbing,
  Value<String?> dubbingSeen,
  Value<DateTime?> partsLoadedAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$FranchisesTableUpdateCompanionBuilder = FranchisesCompanion Function({
  Value<String> key,
  Value<String?> name,
  Value<String?> autoName,
  Value<int?> coverAnimeId,
  Value<String?> dubbing,
  Value<String?> dubbingSeen,
  Value<DateTime?> partsLoadedAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$FranchisesTableFilterComposer
    extends Composer<_$AppDatabase, $FranchisesTable> {
  $$FranchisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get autoName => $composableBuilder(
    column: $table.autoName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coverAnimeId => $composableBuilder(
    column: $table.coverAnimeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dubbing => $composableBuilder(
    column: $table.dubbing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dubbingSeen => $composableBuilder(
    column: $table.dubbingSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get partsLoadedAt => $composableBuilder(
    column: $table.partsLoadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FranchisesTableOrderingComposer
    extends Composer<_$AppDatabase, $FranchisesTable> {
  $$FranchisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autoName => $composableBuilder(
    column: $table.autoName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coverAnimeId => $composableBuilder(
    column: $table.coverAnimeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dubbing => $composableBuilder(
    column: $table.dubbing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dubbingSeen => $composableBuilder(
    column: $table.dubbingSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get partsLoadedAt => $composableBuilder(
    column: $table.partsLoadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FranchisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FranchisesTable> {
  $$FranchisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get autoName =>
      $composableBuilder(column: $table.autoName, builder: (column) => column);

  GeneratedColumn<int> get coverAnimeId => $composableBuilder(
    column: $table.coverAnimeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dubbing =>
      $composableBuilder(column: $table.dubbing, builder: (column) => column);

  GeneratedColumn<String> get dubbingSeen => $composableBuilder(
    column: $table.dubbingSeen,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get partsLoadedAt => $composableBuilder(
    column: $table.partsLoadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FranchisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FranchisesTable,
          Franchise,
          $$FranchisesTableFilterComposer,
          $$FranchisesTableOrderingComposer,
          $$FranchisesTableAnnotationComposer,
          $$FranchisesTableCreateCompanionBuilder,
          $$FranchisesTableUpdateCompanionBuilder,
          (
            Franchise,
            BaseReferences<_$AppDatabase, $FranchisesTable, Franchise>,
          ),
          Franchise,
          PrefetchHooks Function()
        > {
  $$FranchisesTableTableManager(_$AppDatabase db, $FranchisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FranchisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FranchisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FranchisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> autoName = const Value.absent(),
                Value<int?> coverAnimeId = const Value.absent(),
                Value<String?> dubbing = const Value.absent(),
                Value<String?> dubbingSeen = const Value.absent(),
                Value<DateTime?> partsLoadedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FranchisesCompanion(
                key: key,
                name: name,
                autoName: autoName,
                coverAnimeId: coverAnimeId,
                dubbing: dubbing,
                dubbingSeen: dubbingSeen,
                partsLoadedAt: partsLoadedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> name = const Value.absent(),
                Value<String?> autoName = const Value.absent(),
                Value<int?> coverAnimeId = const Value.absent(),
                Value<String?> dubbing = const Value.absent(),
                Value<String?> dubbingSeen = const Value.absent(),
                Value<DateTime?> partsLoadedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FranchisesCompanion.insert(
                key: key,
                name: name,
                autoName: autoName,
                coverAnimeId: coverAnimeId,
                dubbing: dubbing,
                dubbingSeen: dubbingSeen,
                partsLoadedAt: partsLoadedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FranchisesTable, Franchise>(table),
                  BaseReferences<_$AppDatabase, $FranchisesTable, Franchise>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FranchisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FranchisesTable,
      Franchise,
      $$FranchisesTableFilterComposer,
      $$FranchisesTableOrderingComposer,
      $$FranchisesTableAnnotationComposer,
      $$FranchisesTableCreateCompanionBuilder,
      $$FranchisesTableUpdateCompanionBuilder,
      (Franchise, BaseReferences<_$AppDatabase, $FranchisesTable, Franchise>),
      Franchise,
      PrefetchHooks Function()
    >;
typedef $$UserGroupsTableCreateCompanionBuilder = UserGroupsCompanion Function({
  required String id,
  required String name,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$UserGroupsTableUpdateCompanionBuilder = UserGroupsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$UserGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $UserGroupsTable, UserGroup> {
  $$UserGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserGroupMembersTable, List<UserGroupMember>>
  _userGroupMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userGroupMembers,
    aliasName: 'user_groups__id__user_group_members__group_id',
  );

  $$UserGroupMembersTableProcessedTableManager get userGroupMembersRefs {
    final manager = $$UserGroupMembersTableTableManager(
      $_db,
      $_db.userGroupMembers,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userGroupMembersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $UserGroupsTable> {
  $$UserGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userGroupMembersRefs(
    Expression<bool> Function($$UserGroupMembersTableFilterComposer f) f,
  ) {
    final $$UserGroupMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userGroupMembers,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserGroupMembersTableFilterComposer(
            $db: $db,
            $table: $db.userGroupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserGroupsTable> {
  $$UserGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserGroupsTable> {
  $$UserGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> userGroupMembersRefs<T extends Object>(
    Expression<T> Function($$UserGroupMembersTableAnnotationComposer a) f,
  ) {
    final $$UserGroupMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userGroupMembers,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserGroupMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.userGroupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserGroupsTable,
          UserGroup,
          $$UserGroupsTableFilterComposer,
          $$UserGroupsTableOrderingComposer,
          $$UserGroupsTableAnnotationComposer,
          $$UserGroupsTableCreateCompanionBuilder,
          $$UserGroupsTableUpdateCompanionBuilder,
          (UserGroup, $$UserGroupsTableReferences),
          UserGroup,
          PrefetchHooks Function({bool userGroupMembersRefs})
        > {
  $$UserGroupsTableTableManager(_$AppDatabase db, $UserGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserGroupsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserGroupsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserGroupsTable, UserGroup>(table),
                  $$UserGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userGroupMembersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userGroupMembersRefs) db.userGroupMembers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userGroupMembersRefs)
                    await $_getPrefetchedData<
                      UserGroup,
                      $UserGroupsTable,
                      UserGroupMember
                    >(
                      currentTable: table,
                      referencedTable: $$UserGroupsTableReferences
                          ._userGroupMembersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UserGroupsTableReferences(
                            db,
                            table,
                            p0,
                          ).userGroupMembersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.groupId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UserGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserGroupsTable,
      UserGroup,
      $$UserGroupsTableFilterComposer,
      $$UserGroupsTableOrderingComposer,
      $$UserGroupsTableAnnotationComposer,
      $$UserGroupsTableCreateCompanionBuilder,
      $$UserGroupsTableUpdateCompanionBuilder,
      (UserGroup, $$UserGroupsTableReferences),
      UserGroup,
      PrefetchHooks Function({bool userGroupMembersRefs})
    >;
typedef $$UserGroupMembersTableCreateCompanionBuilder =
    UserGroupMembersCompanion Function({
      required String groupId,
      required String memberKey,
      required DateTime addedAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$UserGroupMembersTableUpdateCompanionBuilder =
    UserGroupMembersCompanion Function({
      Value<String> groupId,
      Value<String> memberKey,
      Value<DateTime> addedAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$UserGroupMembersTableReferences
    extends
        BaseReferences<_$AppDatabase, $UserGroupMembersTable, UserGroupMember> {
  $$UserGroupMembersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserGroupsTable _groupIdTable(_$AppDatabase db) => db.userGroups
      .createAlias('user_group_members__group_id__user_groups__id');

  $$UserGroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$UserGroupsTableTableManager(
      $_db,
      $_db.userGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserGroupMembersTableFilterComposer
    extends Composer<_$AppDatabase, $UserGroupMembersTable> {
  $$UserGroupMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get memberKey => $composableBuilder(
    column: $table.memberKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UserGroupsTableFilterComposer get groupId {
    final $$UserGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.userGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserGroupsTableFilterComposer(
            $db: $db,
            $table: $db.userGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserGroupMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $UserGroupMembersTable> {
  $$UserGroupMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get memberKey => $composableBuilder(
    column: $table.memberKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserGroupsTableOrderingComposer get groupId {
    final $$UserGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.userGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.userGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserGroupMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserGroupMembersTable> {
  $$UserGroupMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get memberKey =>
      $composableBuilder(column: $table.memberKey, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$UserGroupsTableAnnotationComposer get groupId {
    final $$UserGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.userGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.userGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserGroupMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserGroupMembersTable,
          UserGroupMember,
          $$UserGroupMembersTableFilterComposer,
          $$UserGroupMembersTableOrderingComposer,
          $$UserGroupMembersTableAnnotationComposer,
          $$UserGroupMembersTableCreateCompanionBuilder,
          $$UserGroupMembersTableUpdateCompanionBuilder,
          (UserGroupMember, $$UserGroupMembersTableReferences),
          UserGroupMember,
          PrefetchHooks Function({bool groupId})
        > {
  $$UserGroupMembersTableTableManager(
    _$AppDatabase db,
    $UserGroupMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserGroupMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserGroupMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserGroupMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> groupId = const Value.absent(),
                Value<String> memberKey = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserGroupMembersCompanion(
                groupId: groupId,
                memberKey: memberKey,
                addedAt: addedAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String groupId,
                required String memberKey,
                required DateTime addedAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserGroupMembersCompanion.insert(
                groupId: groupId,
                memberKey: memberKey,
                addedAt: addedAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserGroupMembersTable, UserGroupMember>(table),
                  $$UserGroupMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (groupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.groupId,
                        referencedTable: $$UserGroupMembersTableReferences
                            ._groupIdTable(db),
                        referencedColumn: $$UserGroupMembersTableReferences
                            ._groupIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserGroupMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserGroupMembersTable,
      UserGroupMember,
      $$UserGroupMembersTableFilterComposer,
      $$UserGroupMembersTableOrderingComposer,
      $$UserGroupMembersTableAnnotationComposer,
      $$UserGroupMembersTableCreateCompanionBuilder,
      $$UserGroupMembersTableUpdateCompanionBuilder,
      (UserGroupMember, $$UserGroupMembersTableReferences),
      UserGroupMember,
      PrefetchHooks Function({bool groupId})
    >;
typedef $$WatchQueuesTableCreateCompanionBuilder =
    WatchQueuesCompanion Function({
      required String id,
      required String franchiseKey,
      required String state,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WatchQueuesTableUpdateCompanionBuilder =
    WatchQueuesCompanion Function({
      Value<String> id,
      Value<String> franchiseKey,
      Value<String> state,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$WatchQueuesTableReferences
    extends BaseReferences<_$AppDatabase, $WatchQueuesTable, WatchQueue> {
  $$WatchQueuesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WatchQueueItemsTable, List<WatchQueueItem>>
  _watchQueueItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.watchQueueItems,
    aliasName: 'watch_queues__id__watch_queue_items__queue_id',
  );

  $$WatchQueueItemsTableProcessedTableManager get watchQueueItemsRefs {
    final manager = $$WatchQueueItemsTableTableManager(
      $_db,
      $_db.watchQueueItems,
    ).filter((f) => f.queueId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _watchQueueItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WatchQueuesTableFilterComposer
    extends Composer<_$AppDatabase, $WatchQueuesTable> {
  $$WatchQueuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get franchiseKey => $composableBuilder(
    column: $table.franchiseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> watchQueueItemsRefs(
    Expression<bool> Function($$WatchQueueItemsTableFilterComposer f) f,
  ) {
    final $$WatchQueueItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.watchQueueItems,
      getReferencedColumn: (t) => t.queueId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchQueueItemsTableFilterComposer(
            $db: $db,
            $table: $db.watchQueueItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WatchQueuesTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchQueuesTable> {
  $$WatchQueuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get franchiseKey => $composableBuilder(
    column: $table.franchiseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WatchQueuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchQueuesTable> {
  $$WatchQueuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get franchiseKey => $composableBuilder(
    column: $table.franchiseKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> watchQueueItemsRefs<T extends Object>(
    Expression<T> Function($$WatchQueueItemsTableAnnotationComposer a) f,
  ) {
    final $$WatchQueueItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.watchQueueItems,
      getReferencedColumn: (t) => t.queueId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchQueueItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.watchQueueItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WatchQueuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchQueuesTable,
          WatchQueue,
          $$WatchQueuesTableFilterComposer,
          $$WatchQueuesTableOrderingComposer,
          $$WatchQueuesTableAnnotationComposer,
          $$WatchQueuesTableCreateCompanionBuilder,
          $$WatchQueuesTableUpdateCompanionBuilder,
          (WatchQueue, $$WatchQueuesTableReferences),
          WatchQueue,
          PrefetchHooks Function({bool watchQueueItemsRefs})
        > {
  $$WatchQueuesTableTableManager(_$AppDatabase db, $WatchQueuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchQueuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchQueuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchQueuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> franchiseKey = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchQueuesCompanion(
                id: id,
                franchiseKey: franchiseKey,
                state: state,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String franchiseKey,
                required String state,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WatchQueuesCompanion.insert(
                id: id,
                franchiseKey: franchiseKey,
                state: state,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WatchQueuesTable, WatchQueue>(table),
                  $$WatchQueuesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({watchQueueItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (watchQueueItemsRefs) db.watchQueueItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (watchQueueItemsRefs)
                    await $_getPrefetchedData<
                      WatchQueue,
                      $WatchQueuesTable,
                      WatchQueueItem
                    >(
                      currentTable: table,
                      referencedTable: $$WatchQueuesTableReferences
                          ._watchQueueItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WatchQueuesTableReferences(
                            db,
                            table,
                            p0,
                          ).watchQueueItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.queueId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WatchQueuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchQueuesTable,
      WatchQueue,
      $$WatchQueuesTableFilterComposer,
      $$WatchQueuesTableOrderingComposer,
      $$WatchQueuesTableAnnotationComposer,
      $$WatchQueuesTableCreateCompanionBuilder,
      $$WatchQueuesTableUpdateCompanionBuilder,
      (WatchQueue, $$WatchQueuesTableReferences),
      WatchQueue,
      PrefetchHooks Function({bool watchQueueItemsRefs})
    >;
typedef $$WatchQueueItemsTableCreateCompanionBuilder =
    WatchQueueItemsCompanion Function({
      required String queueId,
      required int animeId,
      required int position,
      required String mode,
      required String state,
      Value<int> rowid,
    });
typedef $$WatchQueueItemsTableUpdateCompanionBuilder =
    WatchQueueItemsCompanion Function({
      Value<String> queueId,
      Value<int> animeId,
      Value<int> position,
      Value<String> mode,
      Value<String> state,
      Value<int> rowid,
    });

final class $$WatchQueueItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $WatchQueueItemsTable, WatchQueueItem> {
  $$WatchQueueItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WatchQueuesTable _queueIdTable(_$AppDatabase db) => db.watchQueues
      .createAlias('watch_queue_items__queue_id__watch_queues__id');

  $$WatchQueuesTableProcessedTableManager get queueId {
    final $_column = $_itemColumn<String>('queue_id')!;

    final manager = $$WatchQueuesTableTableManager(
      $_db,
      $_db.watchQueues,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_queueIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WatchQueueItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WatchQueueItemsTable> {
  $$WatchQueueItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get animeId => $composableBuilder(
    column: $table.animeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  $$WatchQueuesTableFilterComposer get queueId {
    final $$WatchQueuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.queueId,
      referencedTable: $db.watchQueues,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchQueuesTableFilterComposer(
            $db: $db,
            $table: $db.watchQueues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchQueueItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchQueueItemsTable> {
  $$WatchQueueItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get animeId => $composableBuilder(
    column: $table.animeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  $$WatchQueuesTableOrderingComposer get queueId {
    final $$WatchQueuesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.queueId,
      referencedTable: $db.watchQueues,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchQueuesTableOrderingComposer(
            $db: $db,
            $table: $db.watchQueues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchQueueItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchQueueItemsTable> {
  $$WatchQueueItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get animeId =>
      $composableBuilder(column: $table.animeId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  $$WatchQueuesTableAnnotationComposer get queueId {
    final $$WatchQueuesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.queueId,
      referencedTable: $db.watchQueues,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchQueuesTableAnnotationComposer(
            $db: $db,
            $table: $db.watchQueues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchQueueItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchQueueItemsTable,
          WatchQueueItem,
          $$WatchQueueItemsTableFilterComposer,
          $$WatchQueueItemsTableOrderingComposer,
          $$WatchQueueItemsTableAnnotationComposer,
          $$WatchQueueItemsTableCreateCompanionBuilder,
          $$WatchQueueItemsTableUpdateCompanionBuilder,
          (WatchQueueItem, $$WatchQueueItemsTableReferences),
          WatchQueueItem,
          PrefetchHooks Function({bool queueId})
        > {
  $$WatchQueueItemsTableTableManager(
    _$AppDatabase db,
    $WatchQueueItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchQueueItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchQueueItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchQueueItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> queueId = const Value.absent(),
                Value<int> animeId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchQueueItemsCompanion(
                queueId: queueId,
                animeId: animeId,
                position: position,
                mode: mode,
                state: state,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String queueId,
                required int animeId,
                required int position,
                required String mode,
                required String state,
                Value<int> rowid = const Value.absent(),
              }) => WatchQueueItemsCompanion.insert(
                queueId: queueId,
                animeId: animeId,
                position: position,
                mode: mode,
                state: state,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WatchQueueItemsTable, WatchQueueItem>(table),
                  $$WatchQueueItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({queueId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (queueId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.queueId,
                        referencedTable: $$WatchQueueItemsTableReferences
                            ._queueIdTable(db),
                        referencedColumn: $$WatchQueueItemsTableReferences
                            ._queueIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WatchQueueItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchQueueItemsTable,
      WatchQueueItem,
      $$WatchQueueItemsTableFilterComposer,
      $$WatchQueueItemsTableOrderingComposer,
      $$WatchQueueItemsTableAnnotationComposer,
      $$WatchQueueItemsTableCreateCompanionBuilder,
      $$WatchQueueItemsTableUpdateCompanionBuilder,
      (WatchQueueItem, $$WatchQueueItemsTableReferences),
      WatchQueueItem,
      PrefetchHooks Function({bool queueId})
    >;
typedef $$WatchLinksTableCreateCompanionBuilder = WatchLinksCompanion Function({
  required String id,
  required int animeId,
  required String label,
  required String url,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$WatchLinksTableUpdateCompanionBuilder = WatchLinksCompanion Function({
  Value<String> id,
  Value<int> animeId,
  Value<String> label,
  Value<String> url,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$WatchLinksTableFilterComposer
    extends Composer<_$AppDatabase, $WatchLinksTable> {
  $$WatchLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get animeId => $composableBuilder(
    column: $table.animeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WatchLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchLinksTable> {
  $$WatchLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get animeId => $composableBuilder(
    column: $table.animeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WatchLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchLinksTable> {
  $$WatchLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get animeId =>
      $composableBuilder(column: $table.animeId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$WatchLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchLinksTable,
          WatchLink,
          $$WatchLinksTableFilterComposer,
          $$WatchLinksTableOrderingComposer,
          $$WatchLinksTableAnnotationComposer,
          $$WatchLinksTableCreateCompanionBuilder,
          $$WatchLinksTableUpdateCompanionBuilder,
          (
            WatchLink,
            BaseReferences<_$AppDatabase, $WatchLinksTable, WatchLink>,
          ),
          WatchLink,
          PrefetchHooks Function()
        > {
  $$WatchLinksTableTableManager(_$AppDatabase db, $WatchLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> animeId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchLinksCompanion(
                id: id,
                animeId: animeId,
                label: label,
                url: url,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int animeId,
                required String label,
                required String url,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchLinksCompanion.insert(
                id: id,
                animeId: animeId,
                label: label,
                url: url,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WatchLinksTable, WatchLink>(table),
                  BaseReferences<_$AppDatabase, $WatchLinksTable, WatchLink>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WatchLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchLinksTable,
      WatchLink,
      $$WatchLinksTableFilterComposer,
      $$WatchLinksTableOrderingComposer,
      $$WatchLinksTableAnnotationComposer,
      $$WatchLinksTableCreateCompanionBuilder,
      $$WatchLinksTableUpdateCompanionBuilder,
      (WatchLink, BaseReferences<_$AppDatabase, $WatchLinksTable, WatchLink>),
      WatchLink,
      PrefetchHooks Function()
    >;
typedef $$SiteEpisodesTableCreateCompanionBuilder =
    SiteEpisodesCompanion Function({
      required int animeId,
      required String dubbing,
      required int episodes,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SiteEpisodesTableUpdateCompanionBuilder =
    SiteEpisodesCompanion Function({
      Value<int> animeId,
      Value<String> dubbing,
      Value<int> episodes,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SiteEpisodesTableFilterComposer
    extends Composer<_$AppDatabase, $SiteEpisodesTable> {
  $$SiteEpisodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get animeId => $composableBuilder(
    column: $table.animeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dubbing => $composableBuilder(
    column: $table.dubbing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episodes => $composableBuilder(
    column: $table.episodes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SiteEpisodesTableOrderingComposer
    extends Composer<_$AppDatabase, $SiteEpisodesTable> {
  $$SiteEpisodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get animeId => $composableBuilder(
    column: $table.animeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dubbing => $composableBuilder(
    column: $table.dubbing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episodes => $composableBuilder(
    column: $table.episodes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SiteEpisodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SiteEpisodesTable> {
  $$SiteEpisodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get animeId =>
      $composableBuilder(column: $table.animeId, builder: (column) => column);

  GeneratedColumn<String> get dubbing =>
      $composableBuilder(column: $table.dubbing, builder: (column) => column);

  GeneratedColumn<int> get episodes =>
      $composableBuilder(column: $table.episodes, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SiteEpisodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SiteEpisodesTable,
          SiteEpisode,
          $$SiteEpisodesTableFilterComposer,
          $$SiteEpisodesTableOrderingComposer,
          $$SiteEpisodesTableAnnotationComposer,
          $$SiteEpisodesTableCreateCompanionBuilder,
          $$SiteEpisodesTableUpdateCompanionBuilder,
          (
            SiteEpisode,
            BaseReferences<_$AppDatabase, $SiteEpisodesTable, SiteEpisode>,
          ),
          SiteEpisode,
          PrefetchHooks Function()
        > {
  $$SiteEpisodesTableTableManager(_$AppDatabase db, $SiteEpisodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SiteEpisodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SiteEpisodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SiteEpisodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> animeId = const Value.absent(),
                Value<String> dubbing = const Value.absent(),
                Value<int> episodes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SiteEpisodesCompanion(
                animeId: animeId,
                dubbing: dubbing,
                episodes: episodes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int animeId,
                required String dubbing,
                required int episodes,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SiteEpisodesCompanion.insert(
                animeId: animeId,
                dubbing: dubbing,
                episodes: episodes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SiteEpisodesTable, SiteEpisode>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SiteEpisodesTable,
                    SiteEpisode
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SiteEpisodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SiteEpisodesTable,
      SiteEpisode,
      $$SiteEpisodesTableFilterComposer,
      $$SiteEpisodesTableOrderingComposer,
      $$SiteEpisodesTableAnnotationComposer,
      $$SiteEpisodesTableCreateCompanionBuilder,
      $$SiteEpisodesTableUpdateCompanionBuilder,
      (
        SiteEpisode,
        BaseReferences<_$AppDatabase, $SiteEpisodesTable, SiteEpisode>,
      ),
      SiteEpisode,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AnimesTableTableManager get animes =>
      $$AnimesTableTableManager(_db, _db.animes);
  $$LibraryEntriesTableTableManager get libraryEntries =>
      $$LibraryEntriesTableTableManager(_db, _db.libraryEntries);
  $$WatchCyclesTableTableManager get watchCycles =>
      $$WatchCyclesTableTableManager(_db, _db.watchCycles);
  $$WatchEventsTableTableManager get watchEvents =>
      $$WatchEventsTableTableManager(_db, _db.watchEvents);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$AnimeRelationsTableTableManager get animeRelations =>
      $$AnimeRelationsTableTableManager(_db, _db.animeRelations);
  $$FranchisesTableTableManager get franchises =>
      $$FranchisesTableTableManager(_db, _db.franchises);
  $$UserGroupsTableTableManager get userGroups =>
      $$UserGroupsTableTableManager(_db, _db.userGroups);
  $$UserGroupMembersTableTableManager get userGroupMembers =>
      $$UserGroupMembersTableTableManager(_db, _db.userGroupMembers);
  $$WatchQueuesTableTableManager get watchQueues =>
      $$WatchQueuesTableTableManager(_db, _db.watchQueues);
  $$WatchQueueItemsTableTableManager get watchQueueItems =>
      $$WatchQueueItemsTableTableManager(_db, _db.watchQueueItems);
  $$WatchLinksTableTableManager get watchLinks =>
      $$WatchLinksTableTableManager(_db, _db.watchLinks);
  $$SiteEpisodesTableTableManager get siteEpisodes =>
      $$SiteEpisodesTableTableManager(_db, _db.siteEpisodes);
}
