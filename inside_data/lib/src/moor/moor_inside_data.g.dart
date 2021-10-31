// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moor_inside_data.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class SectionTableData extends DataClass
    implements Insertable<SectionTableData> {
  final int id;
  final String parentId;
  final int sort;

  /// A section can only have a single parent, but some sections kind of are
  /// in two places. So there's a placeholder section which redirects to the
  /// real section.
  final String redirectId;
  final String? title;
  final String? description;
  final int count;
  SectionTableData(
      {required this.id,
      required this.parentId,
      required this.sort,
      required this.redirectId,
      this.title,
      this.description,
      required this.count});
  factory SectionTableData.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return SectionTableData(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      parentId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}parent_id'])!,
      sort: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}sort'])!,
      redirectId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}redirect_id'])!,
      title: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}title']),
      description: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}description']),
      count: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}count'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['parent_id'] = Variable<String>(parentId);
    map['sort'] = Variable<int>(sort);
    map['redirect_id'] = Variable<String>(redirectId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String?>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String?>(description);
    }
    map['count'] = Variable<int>(count);
    return map;
  }

  SectionTableCompanion toCompanion(bool nullToAbsent) {
    return SectionTableCompanion(
      id: Value(id),
      parentId: Value(parentId),
      sort: Value(sort),
      redirectId: Value(redirectId),
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
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return SectionTableData(
      id: serializer.fromJson<int>(json['id']),
      parentId: serializer.fromJson<String>(json['parentId']),
      sort: serializer.fromJson<int>(json['sort']),
      redirectId: serializer.fromJson<String>(json['redirectId']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'parentId': serializer.toJson<String>(parentId),
      'sort': serializer.toJson<int>(sort),
      'redirectId': serializer.toJson<String>(redirectId),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'count': serializer.toJson<int>(count),
    };
  }

  SectionTableData copyWith(
          {int? id,
          String? parentId,
          int? sort,
          String? redirectId,
          String? title,
          String? description,
          int? count}) =>
      SectionTableData(
        id: id ?? this.id,
        parentId: parentId ?? this.parentId,
        sort: sort ?? this.sort,
        redirectId: redirectId ?? this.redirectId,
        title: title ?? this.title,
        description: description ?? this.description,
        count: count ?? this.count,
      );
  @override
  String toString() {
    return (StringBuffer('SectionTableData(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('sort: $sort, ')
          ..write('redirectId: $redirectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, parentId, sort, redirectId, title, description, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SectionTableData &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.sort == this.sort &&
          other.redirectId == this.redirectId &&
          other.title == this.title &&
          other.description == this.description &&
          other.count == this.count);
}

class SectionTableCompanion extends UpdateCompanion<SectionTableData> {
  final Value<int> id;
  final Value<String> parentId;
  final Value<int> sort;
  final Value<String> redirectId;
  final Value<String?> title;
  final Value<String?> description;
  final Value<int> count;
  const SectionTableCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.sort = const Value.absent(),
    this.redirectId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.count = const Value.absent(),
  });
  SectionTableCompanion.insert({
    this.id = const Value.absent(),
    required String parentId,
    required int sort,
    required String redirectId,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    required int count,
  })  : parentId = Value(parentId),
        sort = Value(sort),
        redirectId = Value(redirectId),
        count = Value(count);
  static Insertable<SectionTableData> custom({
    Expression<int>? id,
    Expression<String>? parentId,
    Expression<int>? sort,
    Expression<String>? redirectId,
    Expression<String?>? title,
    Expression<String?>? description,
    Expression<int>? count,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (sort != null) 'sort': sort,
      if (redirectId != null) 'redirect_id': redirectId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (count != null) 'count': count,
    });
  }

  SectionTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? parentId,
      Value<int>? sort,
      Value<String>? redirectId,
      Value<String?>? title,
      Value<String?>? description,
      Value<int>? count}) {
    return SectionTableCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      sort: sort ?? this.sort,
      redirectId: redirectId ?? this.redirectId,
      title: title ?? this.title,
      description: description ?? this.description,
      count: count ?? this.count,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (redirectId.present) {
      map['redirect_id'] = Variable<String>(redirectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String?>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String?>(description.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionTableCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('sort: $sort, ')
          ..write('redirectId: $redirectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }
}

class $SectionTableTable extends SectionTable
    with TableInfo<$SectionTableTable, SectionTableData> {
  final GeneratedDatabase _db;
  final String? _alias;
  $SectionTableTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: false);
  final VerificationMeta _parentIdMeta = const VerificationMeta('parentId');
  late final GeneratedColumn<String?> parentId = GeneratedColumn<String?>(
      'parent_id', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _sortMeta = const VerificationMeta('sort');
  late final GeneratedColumn<int?> sort = GeneratedColumn<int?>(
      'sort', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true);
  final VerificationMeta _redirectIdMeta = const VerificationMeta('redirectId');
  late final GeneratedColumn<String?> redirectId = GeneratedColumn<String?>(
      'redirect_id', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String?> title = GeneratedColumn<String?>(
      'title', aliasedName, true,
      typeName: 'TEXT', requiredDuringInsert: false);
  final VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  late final GeneratedColumn<String?> description = GeneratedColumn<String?>(
      'description', aliasedName, true,
      typeName: 'TEXT', requiredDuringInsert: false);
  final VerificationMeta _countMeta = const VerificationMeta('count');
  late final GeneratedColumn<int?> count = GeneratedColumn<int?>(
      'count', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, parentId, sort, redirectId, title, description, count];
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
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    } else if (isInserting) {
      context.missing(_parentIdMeta);
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
    } else if (isInserting) {
      context.missing(_redirectIdMeta);
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
    return SectionTableData.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $SectionTableTable createAlias(String alias) {
    return $SectionTableTable(_db, alias);
  }
}

class MediaTableData extends DataClass implements Insertable<MediaTableData> {
  /// The post ID if the class is it's own post. Otherwise, taken from media source.
  final String id;
  final String source;
  final int sort;
  final String? title;
  final String? description;

  /// How long the class is, in milliseconds.
  final int duration;
  MediaTableData(
      {required this.id,
      required this.source,
      required this.sort,
      this.title,
      this.description,
      required this.duration});
  factory MediaTableData.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return MediaTableData(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      source: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}source'])!,
      sort: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}sort'])!,
      title: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}title']),
      description: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}description']),
      duration: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}duration'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source'] = Variable<String>(source);
    map['sort'] = Variable<int>(sort);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String?>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String?>(description);
    }
    map['duration'] = Variable<int>(duration);
    return map;
  }

  MediaTableCompanion toCompanion(bool nullToAbsent) {
    return MediaTableCompanion(
      id: Value(id),
      source: Value(source),
      sort: Value(sort),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      duration: Value(duration),
    );
  }

  factory MediaTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return MediaTableData(
      id: serializer.fromJson<String>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      sort: serializer.fromJson<int>(json['sort']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      duration: serializer.fromJson<int>(json['duration']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'source': serializer.toJson<String>(source),
      'sort': serializer.toJson<int>(sort),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'duration': serializer.toJson<int>(duration),
    };
  }

  MediaTableData copyWith(
          {String? id,
          String? source,
          int? sort,
          String? title,
          String? description,
          int? duration}) =>
      MediaTableData(
        id: id ?? this.id,
        source: source ?? this.source,
        sort: sort ?? this.sort,
        title: title ?? this.title,
        description: description ?? this.description,
        duration: duration ?? this.duration,
      );
  @override
  String toString() {
    return (StringBuffer('MediaTableData(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('sort: $sort, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('duration: $duration')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, source, sort, title, description, duration);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaTableData &&
          other.id == this.id &&
          other.source == this.source &&
          other.sort == this.sort &&
          other.title == this.title &&
          other.description == this.description &&
          other.duration == this.duration);
}

class MediaTableCompanion extends UpdateCompanion<MediaTableData> {
  final Value<String> id;
  final Value<String> source;
  final Value<int> sort;
  final Value<String?> title;
  final Value<String?> description;
  final Value<int> duration;
  const MediaTableCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.sort = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.duration = const Value.absent(),
  });
  MediaTableCompanion.insert({
    required String id,
    required String source,
    required int sort,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    required int duration,
  })  : id = Value(id),
        source = Value(source),
        sort = Value(sort),
        duration = Value(duration);
  static Insertable<MediaTableData> custom({
    Expression<String>? id,
    Expression<String>? source,
    Expression<int>? sort,
    Expression<String?>? title,
    Expression<String?>? description,
    Expression<int>? duration,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (sort != null) 'sort': sort,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (duration != null) 'duration': duration,
    });
  }

  MediaTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? source,
      Value<int>? sort,
      Value<String?>? title,
      Value<String?>? description,
      Value<int>? duration}) {
    return MediaTableCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      sort: sort ?? this.sort,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (title.present) {
      map['title'] = Variable<String?>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String?>(description.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaTableCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('sort: $sort, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('duration: $duration')
          ..write(')'))
        .toString();
  }
}

class $MediaTableTable extends MediaTable
    with TableInfo<$MediaTableTable, MediaTableData> {
  final GeneratedDatabase _db;
  final String? _alias;
  $MediaTableTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _sourceMeta = const VerificationMeta('source');
  late final GeneratedColumn<String?> source = GeneratedColumn<String?>(
      'source', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _sortMeta = const VerificationMeta('sort');
  late final GeneratedColumn<int?> sort = GeneratedColumn<int?>(
      'sort', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true);
  final VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String?> title = GeneratedColumn<String?>(
      'title', aliasedName, true,
      typeName: 'TEXT', requiredDuringInsert: false);
  final VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  late final GeneratedColumn<String?> description = GeneratedColumn<String?>(
      'description', aliasedName, true,
      typeName: 'TEXT', requiredDuringInsert: false);
  final VerificationMeta _durationMeta = const VerificationMeta('duration');
  late final GeneratedColumn<int?> duration = GeneratedColumn<int?>(
      'duration', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, source, sort, title, description, duration];
  @override
  String get aliasedName => _alias ?? 'media_table';
  @override
  String get actualTableName => 'media_table';
  @override
  VerificationContext validateIntegrity(Insertable<MediaTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    return MediaTableData.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $MediaTableTable createAlias(String alias) {
    return $MediaTableTable(_db, alias);
  }
}

class UpdateTimeTableData extends DataClass
    implements Insertable<UpdateTimeTableData> {
  final int id;

  /// Last time DB was updated, in milliseconds since epoch.
  final int updateTime;
  UpdateTimeTableData({required this.id, required this.updateTime});
  factory UpdateTimeTableData.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return UpdateTimeTableData(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      updateTime: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}update_time'])!,
    );
  }
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
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return UpdateTimeTableData(
      id: serializer.fromJson<int>(json['id']),
      updateTime: serializer.fromJson<int>(json['updateTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
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

class $UpdateTimeTableTable extends UpdateTimeTable
    with TableInfo<$UpdateTimeTableTable, UpdateTimeTableData> {
  final GeneratedDatabase _db;
  final String? _alias;
  $UpdateTimeTableTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _updateTimeMeta = const VerificationMeta('updateTime');
  late final GeneratedColumn<int?> updateTime = GeneratedColumn<int?>(
      'update_time', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true);
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
    return UpdateTimeTableData.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $UpdateTimeTableTable createAlias(String alias) {
    return $UpdateTimeTableTable(_db, alias);
  }
}

abstract class _$InsideDatabase extends GeneratedDatabase {
  _$InsideDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $SectionTableTable sectionTable = $SectionTableTable(this);
  late final $MediaTableTable mediaTable = $MediaTableTable(this);
  late final $UpdateTimeTableTable updateTimeTable =
      $UpdateTimeTableTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [sectionTable, mediaTable, updateTimeTable];
}
