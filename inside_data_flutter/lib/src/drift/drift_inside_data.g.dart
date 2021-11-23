// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_inside_data.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class MediaParentsTableData extends DataClass
    implements Insertable<MediaParentsTableData> {
  final int id;
  final String mediaId;
  final String parentSection;
  MediaParentsTableData(
      {required this.id, required this.mediaId, required this.parentSection});
  factory MediaParentsTableData.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return MediaParentsTableData(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      mediaId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}media_id'])!,
      parentSection: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}parent_section'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['media_id'] = Variable<String>(mediaId);
    map['parent_section'] = Variable<String>(parentSection);
    return map;
  }

  MediaParentsTableCompanion toCompanion(bool nullToAbsent) {
    return MediaParentsTableCompanion(
      id: Value(id),
      mediaId: Value(mediaId),
      parentSection: Value(parentSection),
    );
  }

  factory MediaParentsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaParentsTableData(
      id: serializer.fromJson<int>(json['id']),
      mediaId: serializer.fromJson<String>(json['mediaId']),
      parentSection: serializer.fromJson<String>(json['parentSection']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mediaId': serializer.toJson<String>(mediaId),
      'parentSection': serializer.toJson<String>(parentSection),
    };
  }

  MediaParentsTableData copyWith(
          {int? id, String? mediaId, String? parentSection}) =>
      MediaParentsTableData(
        id: id ?? this.id,
        mediaId: mediaId ?? this.mediaId,
        parentSection: parentSection ?? this.parentSection,
      );
  @override
  String toString() {
    return (StringBuffer('MediaParentsTableData(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('parentSection: $parentSection')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mediaId, parentSection);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaParentsTableData &&
          other.id == this.id &&
          other.mediaId == this.mediaId &&
          other.parentSection == this.parentSection);
}

class MediaParentsTableCompanion
    extends UpdateCompanion<MediaParentsTableData> {
  final Value<int> id;
  final Value<String> mediaId;
  final Value<String> parentSection;
  const MediaParentsTableCompanion({
    this.id = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.parentSection = const Value.absent(),
  });
  MediaParentsTableCompanion.insert({
    this.id = const Value.absent(),
    required String mediaId,
    required String parentSection,
  })  : mediaId = Value(mediaId),
        parentSection = Value(parentSection);
  static Insertable<MediaParentsTableData> custom({
    Expression<int>? id,
    Expression<String>? mediaId,
    Expression<String>? parentSection,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaId != null) 'media_id': mediaId,
      if (parentSection != null) 'parent_section': parentSection,
    });
  }

  MediaParentsTableCompanion copyWith(
      {Value<int>? id, Value<String>? mediaId, Value<String>? parentSection}) {
    return MediaParentsTableCompanion(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      parentSection: parentSection ?? this.parentSection,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaParentsTableCompanion(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('parentSection: $parentSection')
          ..write(')'))
        .toString();
  }
}

class $MediaParentsTableTable extends MediaParentsTable
    with TableInfo<$MediaParentsTableTable, MediaParentsTableData> {
  final GeneratedDatabase _db;
  final String? _alias;
  $MediaParentsTableTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _mediaIdMeta = const VerificationMeta('mediaId');
  late final GeneratedColumn<String?> mediaId = GeneratedColumn<String?>(
      'media_id', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _parentSectionMeta =
      const VerificationMeta('parentSection');
  late final GeneratedColumn<String?> parentSection = GeneratedColumn<String?>(
      'parent_section', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, mediaId, parentSection];
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaParentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    return MediaParentsTableData.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $MediaParentsTableTable createAlias(String alias) {
    return $MediaParentsTableTable(_db, alias);
  }
}

class SectionParentsTableData extends DataClass
    implements Insertable<SectionParentsTableData> {
  final int id;
  final String sectionId;
  final String parentSection;
  SectionParentsTableData(
      {required this.id, required this.sectionId, required this.parentSection});
  factory SectionParentsTableData.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return SectionParentsTableData(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      sectionId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}section_id'])!,
      parentSection: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}parent_section'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['section_id'] = Variable<String>(sectionId);
    map['parent_section'] = Variable<String>(parentSection);
    return map;
  }

  SectionParentsTableCompanion toCompanion(bool nullToAbsent) {
    return SectionParentsTableCompanion(
      id: Value(id),
      sectionId: Value(sectionId),
      parentSection: Value(parentSection),
    );
  }

  factory SectionParentsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SectionParentsTableData(
      id: serializer.fromJson<int>(json['id']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      parentSection: serializer.fromJson<String>(json['parentSection']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sectionId': serializer.toJson<String>(sectionId),
      'parentSection': serializer.toJson<String>(parentSection),
    };
  }

  SectionParentsTableData copyWith(
          {int? id, String? sectionId, String? parentSection}) =>
      SectionParentsTableData(
        id: id ?? this.id,
        sectionId: sectionId ?? this.sectionId,
        parentSection: parentSection ?? this.parentSection,
      );
  @override
  String toString() {
    return (StringBuffer('SectionParentsTableData(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('parentSection: $parentSection')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sectionId, parentSection);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SectionParentsTableData &&
          other.id == this.id &&
          other.sectionId == this.sectionId &&
          other.parentSection == this.parentSection);
}

class SectionParentsTableCompanion
    extends UpdateCompanion<SectionParentsTableData> {
  final Value<int> id;
  final Value<String> sectionId;
  final Value<String> parentSection;
  const SectionParentsTableCompanion({
    this.id = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.parentSection = const Value.absent(),
  });
  SectionParentsTableCompanion.insert({
    this.id = const Value.absent(),
    required String sectionId,
    required String parentSection,
  })  : sectionId = Value(sectionId),
        parentSection = Value(parentSection);
  static Insertable<SectionParentsTableData> custom({
    Expression<int>? id,
    Expression<String>? sectionId,
    Expression<String>? parentSection,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sectionId != null) 'section_id': sectionId,
      if (parentSection != null) 'parent_section': parentSection,
    });
  }

  SectionParentsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? sectionId,
      Value<String>? parentSection}) {
    return SectionParentsTableCompanion(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      parentSection: parentSection ?? this.parentSection,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionParentsTableCompanion(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('parentSection: $parentSection')
          ..write(')'))
        .toString();
  }
}

class $SectionParentsTableTable extends SectionParentsTable
    with TableInfo<$SectionParentsTableTable, SectionParentsTableData> {
  final GeneratedDatabase _db;
  final String? _alias;
  $SectionParentsTableTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _sectionIdMeta = const VerificationMeta('sectionId');
  late final GeneratedColumn<String?> sectionId = GeneratedColumn<String?>(
      'section_id', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _parentSectionMeta =
      const VerificationMeta('parentSection');
  late final GeneratedColumn<String?> parentSection = GeneratedColumn<String?>(
      'parent_section', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, sectionId, parentSection];
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SectionParentsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    return SectionParentsTableData.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $SectionParentsTableTable createAlias(String alias) {
    return $SectionParentsTableTable(_db, alias);
  }
}

class MediaTableData extends DataClass implements Insertable<MediaTableData> {
  /// In case there are multiple medias with same [source] and no post ID, this prevents
  /// unique constraint errors.
  final int pk;

  /// The post ID if the class is it's own post. Otherwise, taken from media source.
  final String id;
  final String source;
  final int sort;
  final String? title;
  final String? description;

  /// How long the class is, in milliseconds.
  final int? duration;
  MediaTableData(
      {required this.pk,
      required this.id,
      required this.source,
      required this.sort,
      this.title,
      this.description,
      this.duration});
  factory MediaTableData.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return MediaTableData(
      pk: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}pk'])!,
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
          .mapFromDatabaseResponse(data['${effectivePrefix}duration']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pk'] = Variable<int>(pk);
    map['id'] = Variable<String>(id);
    map['source'] = Variable<String>(source);
    map['sort'] = Variable<int>(sort);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String?>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String?>(description);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int?>(duration);
    }
    return map;
  }

  MediaTableCompanion toCompanion(bool nullToAbsent) {
    return MediaTableCompanion(
      pk: Value(pk),
      id: Value(id),
      source: Value(source),
      sort: Value(sort),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
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
      sort: serializer.fromJson<int>(json['sort']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
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
      'sort': serializer.toJson<int>(sort),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'duration': serializer.toJson<int?>(duration),
    };
  }

  MediaTableData copyWith(
          {int? pk,
          String? id,
          String? source,
          int? sort,
          String? title,
          String? description,
          int? duration}) =>
      MediaTableData(
        pk: pk ?? this.pk,
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
          ..write('pk: $pk, ')
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
      Object.hash(pk, id, source, sort, title, description, duration);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaTableData &&
          other.pk == this.pk &&
          other.id == this.id &&
          other.source == this.source &&
          other.sort == this.sort &&
          other.title == this.title &&
          other.description == this.description &&
          other.duration == this.duration);
}

class MediaTableCompanion extends UpdateCompanion<MediaTableData> {
  final Value<int> pk;
  final Value<String> id;
  final Value<String> source;
  final Value<int> sort;
  final Value<String?> title;
  final Value<String?> description;
  final Value<int?> duration;
  const MediaTableCompanion({
    this.pk = const Value.absent(),
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.sort = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.duration = const Value.absent(),
  });
  MediaTableCompanion.insert({
    this.pk = const Value.absent(),
    required String id,
    required String source,
    required int sort,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.duration = const Value.absent(),
  })  : id = Value(id),
        source = Value(source),
        sort = Value(sort);
  static Insertable<MediaTableData> custom({
    Expression<int>? pk,
    Expression<String>? id,
    Expression<String>? source,
    Expression<int>? sort,
    Expression<String?>? title,
    Expression<String?>? description,
    Expression<int?>? duration,
  }) {
    return RawValuesInsertable({
      if (pk != null) 'pk': pk,
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (sort != null) 'sort': sort,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (duration != null) 'duration': duration,
    });
  }

  MediaTableCompanion copyWith(
      {Value<int>? pk,
      Value<String>? id,
      Value<String>? source,
      Value<int>? sort,
      Value<String?>? title,
      Value<String?>? description,
      Value<int?>? duration}) {
    return MediaTableCompanion(
      pk: pk ?? this.pk,
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
    if (pk.present) {
      map['pk'] = Variable<int>(pk.value);
    }
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
      map['duration'] = Variable<int?>(duration.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaTableCompanion(')
          ..write('pk: $pk, ')
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
  final VerificationMeta _pkMeta = const VerificationMeta('pk');
  late final GeneratedColumn<int?> pk = GeneratedColumn<int?>(
      'pk', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
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
      'duration', aliasedName, true,
      typeName: 'INTEGER', requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [pk, id, source, sort, title, description, duration];
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pk};
  @override
  MediaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    return MediaTableData.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $MediaTableTable createAlias(String alias) {
    return $MediaTableTable(_db, alias);
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
  SectionTableData(
      {required this.id,
      required this.sort,
      this.redirectId,
      required this.link,
      this.title,
      this.description,
      required this.count});
  factory SectionTableData.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return SectionTableData(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      sort: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}sort'])!,
      redirectId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}redirect_id']),
      link: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}link'])!,
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
    map['id'] = Variable<String>(id);
    map['sort'] = Variable<int>(sort);
    if (!nullToAbsent || redirectId != null) {
      map['redirect_id'] = Variable<String?>(redirectId);
    }
    map['link'] = Variable<String>(link);
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
          String? redirectId,
          String? link,
          String? title,
          String? description,
          int? count}) =>
      SectionTableData(
        id: id ?? this.id,
        sort: sort ?? this.sort,
        redirectId: redirectId ?? this.redirectId,
        link: link ?? this.link,
        title: title ?? this.title,
        description: description ?? this.description,
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
  const SectionTableCompanion({
    this.id = const Value.absent(),
    this.sort = const Value.absent(),
    this.redirectId = const Value.absent(),
    this.link = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.count = const Value.absent(),
  });
  SectionTableCompanion.insert({
    required String id,
    required int sort,
    this.redirectId = const Value.absent(),
    required String link,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    required int count,
  })  : id = Value(id),
        sort = Value(sort),
        link = Value(link),
        count = Value(count);
  static Insertable<SectionTableData> custom({
    Expression<String>? id,
    Expression<int>? sort,
    Expression<String?>? redirectId,
    Expression<String>? link,
    Expression<String?>? title,
    Expression<String?>? description,
    Expression<int>? count,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sort != null) 'sort': sort,
      if (redirectId != null) 'redirect_id': redirectId,
      if (link != null) 'link': link,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (count != null) 'count': count,
    });
  }

  SectionTableCompanion copyWith(
      {Value<String>? id,
      Value<int>? sort,
      Value<String?>? redirectId,
      Value<String>? link,
      Value<String?>? title,
      Value<String?>? description,
      Value<int>? count}) {
    return SectionTableCompanion(
      id: id ?? this.id,
      sort: sort ?? this.sort,
      redirectId: redirectId ?? this.redirectId,
      link: link ?? this.link,
      title: title ?? this.title,
      description: description ?? this.description,
      count: count ?? this.count,
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
      map['redirect_id'] = Variable<String?>(redirectId.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
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
          ..write('sort: $sort, ')
          ..write('redirectId: $redirectId, ')
          ..write('link: $link, ')
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
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _sortMeta = const VerificationMeta('sort');
  late final GeneratedColumn<int?> sort = GeneratedColumn<int?>(
      'sort', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true);
  final VerificationMeta _redirectIdMeta = const VerificationMeta('redirectId');
  late final GeneratedColumn<String?> redirectId = GeneratedColumn<String?>(
      'redirect_id', aliasedName, true,
      typeName: 'TEXT', requiredDuringInsert: false);
  final VerificationMeta _linkMeta = const VerificationMeta('link');
  late final GeneratedColumn<String?> link = GeneratedColumn<String?>(
      'link', aliasedName, false,
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
    return SectionTableData.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $SectionTableTable createAlias(String alias) {
    return $SectionTableTable(_db, alias);
  }
}

class UpdateTimeTableData extends DataClass
    implements Insertable<UpdateTimeTableData> {
  final int id;

  /// Last time DB was updated, in milliseconds since epoch.
  final int updateTime;
  UpdateTimeTableData({required this.id, required this.updateTime});
  factory UpdateTimeTableData.fromData(Map<String, dynamic> data,
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
      defaultValue: const Constant(0));
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
    return UpdateTimeTableData.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $UpdateTimeTableTable createAlias(String alias) {
    return $UpdateTimeTableTable(_db, alias);
  }
}

abstract class _$InsideDatabase extends GeneratedDatabase {
  _$InsideDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $MediaParentsTableTable mediaParentsTable =
      $MediaParentsTableTable(this);
  late final $SectionParentsTableTable sectionParentsTable =
      $SectionParentsTableTable(this);
  late final $MediaTableTable mediaTable = $MediaTableTable(this);
  late final $SectionTableTable sectionTable = $SectionTableTable(this);
  late final $UpdateTimeTableTable updateTimeTable =
      $UpdateTimeTableTable(this);
  Selectable<TestResult> test(String id) {
    return customSelect('SELECT id, title FROM section_table\nWHERE id = :id',
        variables: [
          Variable<String>(id)
        ],
        readsFrom: {
          sectionTable,
        }).map((QueryRow row) {
      return TestResult(
        id: row.read<String>('id'),
        title: row.read<String?>('title'),
      );
    });
  }

  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        mediaParentsTable,
        sectionParentsTable,
        mediaTable,
        sectionTable,
        updateTimeTable
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
