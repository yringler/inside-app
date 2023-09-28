// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_inside_data.dart';

// ignore_for_file: type=lint
class $SectionTableTable extends SectionTable
    with TableInfo<$SectionTableTable, SectionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SectionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
      'sort', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _redirectIdMeta =
      const VerificationMeta('redirectId');
  @override
  late final GeneratedColumn<String> redirectId = GeneratedColumn<String>(
      'redirect_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
      'link', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
      'count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sort, redirectId, link, title, description, count];
  @override
  String get aliasedName => _alias ?? 'section_table';
  @override
  String get actualTableName => 'section_table';
  @override
  VerificationContext validateIntegrity(Insertable<SectionTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sort')) {
      context.handle(
          _sortMeta, sort.isAcceptableOrUnknown(data['sort']!, _sortMeta));
    } else if (isInserting) {
      context.missing(_sortMeta);
    }
    if (data.containsKey('redirect_id')) {
      context.handle(
          _redirectIdMeta,
          redirectId.isAcceptableOrUnknown(
              data['redirect_id']!, _redirectIdMeta));
    }
    if (data.containsKey('link')) {
      context.handle(
          _linkMeta, link.isAcceptableOrUnknown(data['link']!, _linkMeta));
    } else if (isInserting) {
      context.missing(_linkMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('count')) {
      context.handle(
          _countMeta, count.isAcceptableOrUnknown(data['count']!, _countMeta));
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SectionTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SectionTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort'])!,
      redirectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}redirect_id']),
      link: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}link'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      count: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}count'])!,
    );
  }

  @override
  $SectionTableTable createAlias(String alias) {
    return $SectionTableTable(attachedDatabase, alias);
  }
}

class SectionTableData extends DataClass
    implements Insertable<SectionTableData> {
  final String id;
  final int sort;

  /// A section can only have a single parent, but some sections kind of are
  /// in two places. So there's a placeholder section which redirects to the
  /// real section.
  /// NOTE: This is not yet used.
  final String? redirectId;
  final String link;
  final String? title;
  final String? description;
  final int count;
  const SectionTableData(
      {required this.id,
      required this.sort,
      this.redirectId,
      required this.link,
      this.title,
      this.description,
      required this.count});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sort'] = Variable<int>(sort);
    if (!nullToAbsent || redirectId != null) {
      map['redirect_id'] = Variable<String>(redirectId);
    }
    map['link'] = Variable<String>(link);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['count'] = Variable<int>(count);
    return map;
  }

  SectionTableCompanion toCompanion(bool nullToAbsent) {
    return SectionTableCompanion(
      id: Value(id),
      sort: Value(sort),
      redirectId: redirectId == null && nullToAbsent
          ? const Value.absent()
          : Value(redirectId),
      link: Value(link),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      count: Value(count),
    );
  }

  factory SectionTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SectionTableData(
      id: serializer.fromJson<String>(json['id']),
      sort: serializer.fromJson<int>(json['sort']),
      redirectId: serializer.fromJson<String?>(json['redirectId']),
      link: serializer.fromJson<String>(json['link']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sort': serializer.toJson<int>(sort),
      'redirectId': serializer.toJson<String?>(redirectId),
      'link': serializer.toJson<String>(link),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'count': serializer.toJson<int>(count),
    };
  }

  SectionTableData copyWith(
          {String? id,
          int? sort,
          Value<String?> redirectId = const Value.absent(),
          String? link,
          Value<String?> title = const Value.absent(),
          Value<String?> description = const Value.absent(),
          int? count}) =>
      SectionTableData(
        id: id ?? this.id,
        sort: sort ?? this.sort,
        redirectId: redirectId.present ? redirectId.value : this.redirectId,
        link: link ?? this.link,
        title: title.present ? title.value : this.title,
        description: description.present ? description.value : this.description,
        count: count ?? this.count,
      );
  @override
  String toString() {
    return (StringBuffer('SectionTableData(')
          ..write('id: $id, ')
          ..write('sort: $sort, ')
          ..write('redirectId: $redirectId, ')
          ..write('link: $link, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sort, redirectId, link, title, description, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SectionTableData &&
          other.id == this.id &&
          other.sort == this.sort &&
          other.redirectId == this.redirectId &&
          other.link == this.link &&
          other.title == this.title &&
          other.description == this.description &&
          other.count == this.count);
}

class SectionTableCompanion extends UpdateCompanion<SectionTableData> {
  final Value<String> id;
  final Value<int> sort;
  final Value<String?> redirectId;
  final Value<String> link;
  final Value<String?> title;
  final Value<String?> description;
  final Value<int> count;
  final Value<int> rowid;
  const SectionTableCompanion({
    this.id = const Value.absent(),
    this.sort = const Value.absent(),
    this.redirectId = const Value.absent(),
    this.link = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SectionTableCompanion.insert({
    required String id,
    required int sort,
    this.redirectId = const Value.absent(),
    required String link,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    required int count,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sort = Value(sort),
        link = Value(link),
        count = Value(count);
  static Insertable<SectionTableData> custom({
    Expression<String>? id,
    Expression<int>? sort,
    Expression<String>? redirectId,
    Expression<String>? link,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? count,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sort != null) 'sort': sort,
      if (redirectId != null) 'redirect_id': redirectId,
      if (link != null) 'link': link,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (count != null) 'count': count,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SectionTableCompanion copyWith(
      {Value<String>? id,
      Value<int>? sort,
      Value<String?>? redirectId,
      Value<String>? link,
      Value<String?>? title,
      Value<String?>? description,
      Value<int>? count,
      Value<int>? rowid}) {
    return SectionTableCompanion(
      id: id ?? this.id,
      sort: sort ?? this.sort,
      redirectId: redirectId ?? this.redirectId,
      link: link ?? this.link,
      title: title ?? this.title,
      description: description ?? this.description,
      count: count ?? this.count,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (redirectId.present) {
      map['redirect_id'] = Variable<String>(redirectId.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionTableCompanion(')
          ..write('id: $id, ')
          ..write('sort: $sort, ')
          ..write('redirectId: $redirectId, ')
          ..write('link: $link, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('count: $count, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaTableTable extends MediaTable
    with TableInfo<$MediaTableTable, MediaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pkMeta = const VerificationMeta('pk');
  @override
  late final GeneratedColumn<int> pk = GeneratedColumn<int>(
      'pk', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _videoSourceMeta =
      const VerificationMeta('videoSource');
  @override
  late final GeneratedColumn<String> videoSource = GeneratedColumn<String>(
      'video_source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
      'sort', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<int> created = GeneratedColumn<int>(
      'created', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
      'link', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
      'duration', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        pk,
        id,
        source,
        videoSource,
        sort,
        title,
        description,
        created,
        link,
        duration
      ];
  @override
  String get aliasedName => _alias ?? 'media_table';
  @override
  String get actualTableName => 'media_table';
  @override
  VerificationContext validateIntegrity(Insertable<MediaTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pk')) {
      context.handle(_pkMeta, pk.isAcceptableOrUnknown(data['pk']!, _pkMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('video_source')) {
      context.handle(
          _videoSourceMeta,
          videoSource.isAcceptableOrUnknown(
              data['video_source']!, _videoSourceMeta));
    }
    if (data.containsKey('sort')) {
      context.handle(
          _sortMeta, sort.isAcceptableOrUnknown(data['sort']!, _sortMeta));
    } else if (isInserting) {
      context.missing(_sortMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('link')) {
      context.handle(
          _linkMeta, link.isAcceptableOrUnknown(data['link']!, _linkMeta));
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pk};
  @override
  MediaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaTableData(
      pk: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pk'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      videoSource: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}video_source'])!,
      sort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created'])!,
      link: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}link'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration']),
    );
  }

  @override
  $MediaTableTable createAlias(String alias) {
    return $MediaTableTable(attachedDatabase, alias);
  }
}

class MediaTableData extends DataClass implements Insertable<MediaTableData> {
  /// In case there are multiple medias with same [source] and no post ID, this prevents
  /// unique constraint errors.
  final int pk;

  /// The post ID if the class is it's own post. Otherwise, taken from media source.
  final String id;
  final String source;
  final String videoSource;
  final int sort;
  final String? title;
  final String? description;
  final int created;
  final String link;

  /// How long the class is, in milliseconds.
  final int? duration;
  const MediaTableData(
      {required this.pk,
      required this.id,
      required this.source,
      required this.videoSource,
      required this.sort,
      this.title,
      this.description,
      required this.created,
      required this.link,
      this.duration});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pk'] = Variable<int>(pk);
    map['id'] = Variable<String>(id);
    map['source'] = Variable<String>(source);
    map['video_source'] = Variable<String>(videoSource);
    map['sort'] = Variable<int>(sort);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created'] = Variable<int>(created);
    map['link'] = Variable<String>(link);
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    return map;
  }

  MediaTableCompanion toCompanion(bool nullToAbsent) {
    return MediaTableCompanion(
      pk: Value(pk),
      id: Value(id),
      source: Value(source),
      videoSource: Value(videoSource),
      sort: Value(sort),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      created: Value(created),
      link: Value(link),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
    );
  }

  factory MediaTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaTableData(
      pk: serializer.fromJson<int>(json['pk']),
      id: serializer.fromJson<String>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      videoSource: serializer.fromJson<String>(json['videoSource']),
      sort: serializer.fromJson<int>(json['sort']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      created: serializer.fromJson<int>(json['created']),
      link: serializer.fromJson<String>(json['link']),
      duration: serializer.fromJson<int?>(json['duration']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pk': serializer.toJson<int>(pk),
      'id': serializer.toJson<String>(id),
      'source': serializer.toJson<String>(source),
      'videoSource': serializer.toJson<String>(videoSource),
      'sort': serializer.toJson<int>(sort),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'created': serializer.toJson<int>(created),
      'link': serializer.toJson<String>(link),
      'duration': serializer.toJson<int?>(duration),
    };
  }

  MediaTableData copyWith(
          {int? pk,
          String? id,
          String? source,
          String? videoSource,
          int? sort,
          Value<String?> title = const Value.absent(),
          Value<String?> description = const Value.absent(),
          int? created,
          String? link,
          Value<int?> duration = const Value.absent()}) =>
      MediaTableData(
        pk: pk ?? this.pk,
        id: id ?? this.id,
        source: source ?? this.source,
        videoSource: videoSource ?? this.videoSource,
        sort: sort ?? this.sort,
        title: title.present ? title.value : this.title,
        description: description.present ? description.value : this.description,
        created: created ?? this.created,
        link: link ?? this.link,
        duration: duration.present ? duration.value : this.duration,
      );
  @override
  String toString() {
    return (StringBuffer('MediaTableData(')
          ..write('pk: $pk, ')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('videoSource: $videoSource, ')
          ..write('sort: $sort, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('created: $created, ')
          ..write('link: $link, ')
          ..write('duration: $duration')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pk, id, source, videoSource, sort, title,
      description, created, link, duration);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaTableData &&
          other.pk == this.pk &&
          other.id == this.id &&
          other.source == this.source &&
          other.videoSource == this.videoSource &&
          other.sort == this.sort &&
          other.title == this.title &&
          other.description == this.description &&
          other.created == this.created &&
          other.link == this.link &&
          other.duration == this.duration);
}

class MediaTableCompanion extends UpdateCompanion<MediaTableData> {
  final Value<int> pk;
  final Value<String> id;
  final Value<String> source;
  final Value<String> videoSource;
  final Value<int> sort;
  final Value<String?> title;
  final Value<String?> description;
  final Value<int> created;
  final Value<String> link;
  final Value<int?> duration;
  const MediaTableCompanion({
    this.pk = const Value.absent(),
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.videoSource = const Value.absent(),
    this.sort = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.created = const Value.absent(),
    this.link = const Value.absent(),
    this.duration = const Value.absent(),
  });
  MediaTableCompanion.insert({
    this.pk = const Value.absent(),
    required String id,
    required String source,
    this.videoSource = const Value.absent(),
    required int sort,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.created = const Value.absent(),
    this.link = const Value.absent(),
    this.duration = const Value.absent(),
  })  : id = Value(id),
        source = Value(source),
        sort = Value(sort);
  static Insertable<MediaTableData> custom({
    Expression<int>? pk,
    Expression<String>? id,
    Expression<String>? source,
    Expression<String>? videoSource,
    Expression<int>? sort,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? created,
    Expression<String>? link,
    Expression<int>? duration,
  }) {
    return RawValuesInsertable({
      if (pk != null) 'pk': pk,
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (videoSource != null) 'video_source': videoSource,
      if (sort != null) 'sort': sort,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (created != null) 'created': created,
      if (link != null) 'link': link,
      if (duration != null) 'duration': duration,
    });
  }

  MediaTableCompanion copyWith(
      {Value<int>? pk,
      Value<String>? id,
      Value<String>? source,
      Value<String>? videoSource,
      Value<int>? sort,
      Value<String?>? title,
      Value<String?>? description,
      Value<int>? created,
      Value<String>? link,
      Value<int?>? duration}) {
    return MediaTableCompanion(
      pk: pk ?? this.pk,
      id: id ?? this.id,
      source: source ?? this.source,
      videoSource: videoSource ?? this.videoSource,
      sort: sort ?? this.sort,
      title: title ?? this.title,
      description: description ?? this.description,
      created: created ?? this.created,
      link: link ?? this.link,
      duration: duration ?? this.duration,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pk.present) {
      map['pk'] = Variable<int>(pk.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (videoSource.present) {
      map['video_source'] = Variable<String>(videoSource.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (created.present) {
      map['created'] = Variable<int>(created.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaTableCompanion(')
          ..write('pk: $pk, ')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('videoSource: $videoSource, ')
          ..write('sort: $sort, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('created: $created, ')
          ..write('link: $link, ')
          ..write('duration: $duration')
          ..write(')'))
        .toString();
  }
}

class $MediaParentsTableTable extends MediaParentsTable
    with TableInfo<$MediaParentsTableTable, MediaParentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaParentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _mediaIdMeta =
      const VerificationMeta('mediaId');
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
      'media_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentSectionMeta =
      const VerificationMeta('parentSection');
  @override
  late final GeneratedColumn<String> parentSection = GeneratedColumn<String>(
      'parent_section', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
      'sort', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, mediaId, parentSection, sort];
  @override
  String get aliasedName => _alias ?? 'media_parents_table';
  @override
  String get actualTableName => 'media_parents_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<MediaParentsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('media_id')) {
      context.handle(_mediaIdMeta,
          mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta));
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('parent_section')) {
      context.handle(
          _parentSectionMeta,
          parentSection.isAcceptableOrUnknown(
              data['parent_section']!, _parentSectionMeta));
    } else if (isInserting) {
      context.missing(_parentSectionMeta);
    }
    if (data.containsKey('sort')) {
      context.handle(
          _sortMeta, sort.isAcceptableOrUnknown(data['sort']!, _sortMeta));
    } else if (isInserting) {
      context.missing(_sortMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaParentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaParentsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      mediaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_id'])!,
      parentSection: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_section'])!,
      sort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort'])!,
    );
  }

  @override
  $MediaParentsTableTable createAlias(String alias) {
    return $MediaParentsTableTable(attachedDatabase, alias);
  }
}

class MediaParentsTableData extends DataClass
    implements Insertable<MediaParentsTableData> {
  final int id;
  final String mediaId;
  final String parentSection;
  final int sort;
  const MediaParentsTableData(
      {required this.id,
      required this.mediaId,
      required this.parentSection,
      required this.sort});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['media_id'] = Variable<String>(mediaId);
    map['parent_section'] = Variable<String>(parentSection);
    map['sort'] = Variable<int>(sort);
    return map;
  }

  MediaParentsTableCompanion toCompanion(bool nullToAbsent) {
    return MediaParentsTableCompanion(
      id: Value(id),
      mediaId: Value(mediaId),
      parentSection: Value(parentSection),
      sort: Value(sort),
    );
  }

  factory MediaParentsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaParentsTableData(
      id: serializer.fromJson<int>(json['id']),
      mediaId: serializer.fromJson<String>(json['mediaId']),
      parentSection: serializer.fromJson<String>(json['parentSection']),
      sort: serializer.fromJson<int>(json['sort']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mediaId': serializer.toJson<String>(mediaId),
      'parentSection': serializer.toJson<String>(parentSection),
      'sort': serializer.toJson<int>(sort),
    };
  }

  MediaParentsTableData copyWith(
          {int? id, String? mediaId, String? parentSection, int? sort}) =>
      MediaParentsTableData(
        id: id ?? this.id,
        mediaId: mediaId ?? this.mediaId,
        parentSection: parentSection ?? this.parentSection,
        sort: sort ?? this.sort,
      );
  @override
  String toString() {
    return (StringBuffer('MediaParentsTableData(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('parentSection: $parentSection, ')
          ..write('sort: $sort')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mediaId, parentSection, sort);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaParentsTableData &&
          other.id == this.id &&
          other.mediaId == this.mediaId &&
          other.parentSection == this.parentSection &&
          other.sort == this.sort);
}

class MediaParentsTableCompanion
    extends UpdateCompanion<MediaParentsTableData> {
  final Value<int> id;
  final Value<String> mediaId;
  final Value<String> parentSection;
  final Value<int> sort;
  const MediaParentsTableCompanion({
    this.id = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.parentSection = const Value.absent(),
    this.sort = const Value.absent(),
  });
  MediaParentsTableCompanion.insert({
    this.id = const Value.absent(),
    required String mediaId,
    required String parentSection,
    required int sort,
  })  : mediaId = Value(mediaId),
        parentSection = Value(parentSection),
        sort = Value(sort);
  static Insertable<MediaParentsTableData> custom({
    Expression<int>? id,
    Expression<String>? mediaId,
    Expression<String>? parentSection,
    Expression<int>? sort,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaId != null) 'media_id': mediaId,
      if (parentSection != null) 'parent_section': parentSection,
      if (sort != null) 'sort': sort,
    });
  }

  MediaParentsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? mediaId,
      Value<String>? parentSection,
      Value<int>? sort}) {
    return MediaParentsTableCompanion(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      parentSection: parentSection ?? this.parentSection,
      sort: sort ?? this.sort,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (parentSection.present) {
      map['parent_section'] = Variable<String>(parentSection.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaParentsTableCompanion(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('parentSection: $parentSection, ')
          ..write('sort: $sort')
          ..write(')'))
        .toString();
  }
}

class $UpdateTimeTableTable extends UpdateTimeTable
    with TableInfo<$UpdateTimeTableTable, UpdateTimeTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UpdateTimeTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updateTimeMeta =
      const VerificationMeta('updateTime');
  @override
  late final GeneratedColumn<int> updateTime = GeneratedColumn<int>(
      'update_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, updateTime];
  @override
  String get aliasedName => _alias ?? 'update_time_table';
  @override
  String get actualTableName => 'update_time_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<UpdateTimeTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('update_time')) {
      context.handle(
          _updateTimeMeta,
          updateTime.isAcceptableOrUnknown(
              data['update_time']!, _updateTimeMeta));
    } else if (isInserting) {
      context.missing(_updateTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UpdateTimeTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UpdateTimeTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      updateTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}update_time'])!,
    );
  }

  @override
  $UpdateTimeTableTable createAlias(String alias) {
    return $UpdateTimeTableTable(attachedDatabase, alias);
  }
}

class UpdateTimeTableData extends DataClass
    implements Insertable<UpdateTimeTableData> {
  final int id;

  /// Last time DB was updated, in milliseconds since epoch.
  final int updateTime;
  const UpdateTimeTableData({required this.id, required this.updateTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['update_time'] = Variable<int>(updateTime);
    return map;
  }

  UpdateTimeTableCompanion toCompanion(bool nullToAbsent) {
    return UpdateTimeTableCompanion(
      id: Value(id),
      updateTime: Value(updateTime),
    );
  }

  factory UpdateTimeTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UpdateTimeTableData(
      id: serializer.fromJson<int>(json['id']),
      updateTime: serializer.fromJson<int>(json['updateTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'updateTime': serializer.toJson<int>(updateTime),
    };
  }

  UpdateTimeTableData copyWith({int? id, int? updateTime}) =>
      UpdateTimeTableData(
        id: id ?? this.id,
        updateTime: updateTime ?? this.updateTime,
      );
  @override
  String toString() {
    return (StringBuffer('UpdateTimeTableData(')
          ..write('id: $id, ')
          ..write('updateTime: $updateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updateTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UpdateTimeTableData &&
          other.id == this.id &&
          other.updateTime == this.updateTime);
}

class UpdateTimeTableCompanion extends UpdateCompanion<UpdateTimeTableData> {
  final Value<int> id;
  final Value<int> updateTime;
  const UpdateTimeTableCompanion({
    this.id = const Value.absent(),
    this.updateTime = const Value.absent(),
  });
  UpdateTimeTableCompanion.insert({
    this.id = const Value.absent(),
    required int updateTime,
  }) : updateTime = Value(updateTime);
  static Insertable<UpdateTimeTableData> custom({
    Expression<int>? id,
    Expression<int>? updateTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updateTime != null) 'update_time': updateTime,
    });
  }

  UpdateTimeTableCompanion copyWith({Value<int>? id, Value<int>? updateTime}) {
    return UpdateTimeTableCompanion(
      id: id ?? this.id,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (updateTime.present) {
      map['update_time'] = Variable<int>(updateTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UpdateTimeTableCompanion(')
          ..write('id: $id, ')
          ..write('updateTime: $updateTime')
          ..write(')'))
        .toString();
  }
}

class $SectionParentsTableTable extends SectionParentsTable
    with TableInfo<$SectionParentsTableTable, SectionParentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SectionParentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sectionIdMeta =
      const VerificationMeta('sectionId');
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
      'section_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentSectionMeta =
      const VerificationMeta('parentSection');
  @override
  late final GeneratedColumn<String> parentSection = GeneratedColumn<String>(
      'parent_section', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
      'sort', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, sectionId, parentSection, sort];
  @override
  String get aliasedName => _alias ?? 'section_parents_table';
  @override
  String get actualTableName => 'section_parents_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<SectionParentsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('section_id')) {
      context.handle(_sectionIdMeta,
          sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta));
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('parent_section')) {
      context.handle(
          _parentSectionMeta,
          parentSection.isAcceptableOrUnknown(
              data['parent_section']!, _parentSectionMeta));
    } else if (isInserting) {
      context.missing(_parentSectionMeta);
    }
    if (data.containsKey('sort')) {
      context.handle(
          _sortMeta, sort.isAcceptableOrUnknown(data['sort']!, _sortMeta));
    } else if (isInserting) {
      context.missing(_sortMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SectionParentsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SectionParentsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}section_id'])!,
      parentSection: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_section'])!,
      sort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort'])!,
    );
  }

  @override
  $SectionParentsTableTable createAlias(String alias) {
    return $SectionParentsTableTable(attachedDatabase, alias);
  }
}

class SectionParentsTableData extends DataClass
    implements Insertable<SectionParentsTableData> {
  final int id;
  final String sectionId;
  final String parentSection;
  final int sort;
  const SectionParentsTableData(
      {required this.id,
      required this.sectionId,
      required this.parentSection,
      required this.sort});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['section_id'] = Variable<String>(sectionId);
    map['parent_section'] = Variable<String>(parentSection);
    map['sort'] = Variable<int>(sort);
    return map;
  }

  SectionParentsTableCompanion toCompanion(bool nullToAbsent) {
    return SectionParentsTableCompanion(
      id: Value(id),
      sectionId: Value(sectionId),
      parentSection: Value(parentSection),
      sort: Value(sort),
    );
  }

  factory SectionParentsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SectionParentsTableData(
      id: serializer.fromJson<int>(json['id']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      parentSection: serializer.fromJson<String>(json['parentSection']),
      sort: serializer.fromJson<int>(json['sort']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sectionId': serializer.toJson<String>(sectionId),
      'parentSection': serializer.toJson<String>(parentSection),
      'sort': serializer.toJson<int>(sort),
    };
  }

  SectionParentsTableData copyWith(
          {int? id, String? sectionId, String? parentSection, int? sort}) =>
      SectionParentsTableData(
        id: id ?? this.id,
        sectionId: sectionId ?? this.sectionId,
        parentSection: parentSection ?? this.parentSection,
        sort: sort ?? this.sort,
      );
  @override
  String toString() {
    return (StringBuffer('SectionParentsTableData(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('parentSection: $parentSection, ')
          ..write('sort: $sort')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sectionId, parentSection, sort);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SectionParentsTableData &&
          other.id == this.id &&
          other.sectionId == this.sectionId &&
          other.parentSection == this.parentSection &&
          other.sort == this.sort);
}

class SectionParentsTableCompanion
    extends UpdateCompanion<SectionParentsTableData> {
  final Value<int> id;
  final Value<String> sectionId;
  final Value<String> parentSection;
  final Value<int> sort;
  const SectionParentsTableCompanion({
    this.id = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.parentSection = const Value.absent(),
    this.sort = const Value.absent(),
  });
  SectionParentsTableCompanion.insert({
    this.id = const Value.absent(),
    required String sectionId,
    required String parentSection,
    required int sort,
  })  : sectionId = Value(sectionId),
        parentSection = Value(parentSection),
        sort = Value(sort);
  static Insertable<SectionParentsTableData> custom({
    Expression<int>? id,
    Expression<String>? sectionId,
    Expression<String>? parentSection,
    Expression<int>? sort,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sectionId != null) 'section_id': sectionId,
      if (parentSection != null) 'parent_section': parentSection,
      if (sort != null) 'sort': sort,
    });
  }

  SectionParentsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? sectionId,
      Value<String>? parentSection,
      Value<int>? sort}) {
    return SectionParentsTableCompanion(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      parentSection: parentSection ?? this.parentSection,
      sort: sort ?? this.sort,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (parentSection.present) {
      map['parent_section'] = Variable<String>(parentSection.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionParentsTableCompanion(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('parentSection: $parentSection, ')
          ..write('sort: $sort')
          ..write(')'))
        .toString();
  }
}

abstract class _$InsideDatabase extends GeneratedDatabase {
  _$InsideDatabase(QueryExecutor e) : super(e);
  _$InsideDatabase.connect(DatabaseConnection c) : super.connect(c);
  late final $SectionTableTable sectionTable = $SectionTableTable(this);
  late final $MediaTableTable mediaTable = $MediaTableTable(this);
  late final $MediaParentsTableTable mediaParentsTable =
      $MediaParentsTableTable(this);
  late final $UpdateTimeTableTable updateTimeTable =
      $UpdateTimeTableTable(this);
  late final $SectionParentsTableTable sectionParentsTable =
      $SectionParentsTableTable(this);
  Selectable<TestResult> test(String id) {
    return customSelect('SELECT id, title FROM section_table WHERE id = ?1',
        variables: [
          Variable<String>(id)
        ],
        readsFrom: {
          sectionTable,
        }).map((QueryRow row) {
      return TestResult(
        id: row.read<String>('id'),
        title: row.readNullable<String>('title'),
      );
    });
  }

  Selectable<LatestResult> latest(int limit) {
    return customSelect(
        'SELECT"parent"."id" AS "nested_0.id", "parent"."media_id" AS "nested_0.media_id", "parent"."parent_section" AS "nested_0.parent_section", "parent"."sort" AS "nested_0.sort","media"."pk" AS "nested_1.pk", "media"."id" AS "nested_1.id", "media"."source" AS "nested_1.source", "media"."video_source" AS "nested_1.video_source", "media"."sort" AS "nested_1.sort", "media"."title" AS "nested_1.title", "media"."description" AS "nested_1.description", "media"."created" AS "nested_1.created", "media"."link" AS "nested_1.link", "media"."duration" AS "nested_1.duration" FROM media_table AS media INNER JOIN media_parents_table AS parent ON parent.media_id = media.id ORDER BY created DESC LIMIT ?1',
        variables: [
          Variable<int>(limit)
        ],
        readsFrom: {
          mediaTable,
          mediaParentsTable,
        }).asyncMap((QueryRow row) async {
      return LatestResult(
        parent:
            await mediaParentsTable.mapFromRow(row, tablePrefix: 'nested_0'),
        media: await mediaTable.mapFromRow(row, tablePrefix: 'nested_1'),
      );
    });
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        sectionTable,
        mediaTable,
        mediaParentsTable,
        updateTimeTable,
        sectionParentsTable
      ];
}

class TestResult {
  final String id;
  final String? title;
  TestResult({
    required this.id,
    this.title,
  });
}

class LatestResult {
  final MediaParentsTableData parent;
  final MediaTableData media;
  LatestResult({
    required this.parent,
    required this.media,
  });
}
