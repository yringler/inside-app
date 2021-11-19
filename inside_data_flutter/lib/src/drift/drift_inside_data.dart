import 'dart:io';

import 'package:inside_data/inside_data.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'drift_inside_data.g.dart';

class MediaParentsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mediaId => text()();
  TextColumn get parentSection => text()();
}

class SectionParentsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sectionId => text()();
  TextColumn get parentSection => text()();
}

/// Contains a single media/post
class MediaTable extends Table {
  /// The post ID if the class is it's own post. Otherwise, taken from media source.
  TextColumn get id => text()();

  TextColumn get source => text()();
  IntColumn get sort => integer()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();

  /// How long the class is, in milliseconds.
  IntColumn get duration => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SectionTable extends Table {
  TextColumn get id => text()();
  IntColumn get sort => integer()();

  /// A section can only have a single parent, but some sections kind of are
  /// in two places. So there's a placeholder section which redirects to the
  /// real section.
  /// NOTE: This is not yet used.
  TextColumn get redirectId => text().nullable()();

  TextColumn get link => text()();

  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get count => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Yes, an entire table. To store last upate time. Sue me.
class UpdateTimeTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();

  /// Last time DB was updated, in milliseconds since epoch.
  IntColumn get updateTime => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'insidedata.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables: [
  SectionTable,
  MediaTable,
  UpdateTimeTable,
  MediaParentsTable,
  SectionParentsTable
], include: {
  'inside.drift'
})
class InsideDatabase extends _$InsideDatabase {
  /// Optionally pass in a [database] (this is mostly intended for unit testing, to pass
  /// in an in memory database).
  InsideDatabase({NativeDatabase? database})
      : super(database ?? _openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> addSections(List<Section> sections) {
    final sectionCompanions = sections
        .map((value) => SectionTableCompanion.insert(
            link: value.link,
            sort: value.sort,
            count: value.audioCount,
            description: Value.ofNullable(value.description),
            id: value.id,
            title: Value.ofNullable(value.title)))
        .toList();

    final sectionParents = sections
        .map((section) => section.parents.map((parent) =>
            SectionParentsTableCompanion.insert(
                sectionId: section.id, parentSection: parent)))
        .expand((element) => element)
        .toList();

    return batch((batch) {
      batch.insertAll(sectionTable, sectionCompanions);
      batch.insertAll(sectionParentsTable, sectionParents);
    });
  }

  Future<void> addMedia(List<Media> medias) {
    final mediaCompanions = medias
        .map((e) => MediaTableCompanion.insert(
            id: e.id,
            source: e.source,
            sort: e.sort,
            duration: Value.ofNullable(e.length?.inMilliseconds),
            description: Value.ofNullable(e.description),
            title: Value.ofNullable(e.title)))
        .toList();

    final mediaParents = medias
        .map((media) => media.parents.map((parent) =>
            MediaParentsTableCompanion.insert(
                mediaId: media.id, parentSection: parent)))
        .expand((element) => element)
        .toList();

    return batch((batch) {
      batch.insertAll(mediaTable, mediaCompanions);
      batch.insertAll(mediaParentsTable, mediaParents);
    });
  }

  Future<Media?> media(String id) async {
    final query = (select(mediaTable)..where((tbl) => tbl.id.equals(id))).join([
      leftOuterJoin(
          mediaParentsTable, mediaParentsTable.mediaId.equalsExp(mediaTable.id))
    ]);

    final queryValue = await query.get();

    if (queryValue.isEmpty) {
      return null;
    }

    final parents = queryValue
        .map((e) => e.readTableOrNull(mediaParentsTable))
        .where((element) => element != null)
        .map((e) => e!.parentSection)
        .toSet();

    final media = queryValue.first.readTable(mediaTable);

    // TODO: should title and description be nullable?

    return Media(
        source: media.source,
        id: id,
        sort: media.sort,
        title: media.title ?? '',
        description: media.description ?? '',
        parents: parents);
  }

  /// Will load section and any child media or child sections.
  /// Will not load any media or sections of child sections.
  Future<Section?> section(String id) async {
    final baseSectionQuery =
        (select(sectionTable)..where((tbl) => tbl.id.equals(id))).join([
      leftOuterJoin(sectionParentsTable,
          sectionParentsTable.sectionId.equalsExp(sectionTable.id)),
    ]);

    final baseSectionQueryValue = await baseSectionQuery.get();
    final baseSectionRow = baseSectionQueryValue
        .map((e) => e.readTableOrNull(sectionTable))
        .where((element) => element != null)
        .first;

    if (baseSectionRow == null) {
      return null;
    }

    final parents = baseSectionQueryValue
        .map((e) => e.readTableOrNull(sectionParentsTable))
        .where((element) => element != null)
        .map((e) => e!.parentSection)
        .toSet();
    final base = SiteDataBase(
        id: id,
        title: baseSectionRow.title ?? '',
        description: baseSectionRow.description ?? '',
        sort: baseSectionRow.sort,
        link: baseSectionRow.link,
        parents: parents);

    // Query for child sections
    final childSectionsQuery = (select(sectionParentsTable)
          ..where((tbl) => tbl.parentSection.equals(id)))
        .join([
      innerJoin(sectionTable,
          sectionTable.id.equalsExp(sectionParentsTable.sectionId))
    ]);
    final childSectionsValue = await childSectionsQuery.get();
    final childSections = childSectionsValue
        .map((e) => e.readTable(sectionTable))
        .map((e) => ContentReference.fromData(
            data: Section(
                loadedContent: false,
                content: [],
                id: e.id,
                sort: e.sort,
                title: e.title ?? '',
                description: e.description ?? '',
                link: e.link,
                parents: {id})))
        .toList();

    // Query for media.
    final mediaQuery = (select(mediaParentsTable)
          ..where((tbl) => tbl.parentSection.equals(id)))
        .join([
      innerJoin(mediaTable, mediaTable.id.equalsExp(mediaParentsTable.mediaId))
    ]);
    final mediaValue = await mediaQuery.get();
    final media = mediaValue
        .map((e) => e.readTable(mediaTable))
        .map((e) => ContentReference.fromData(
            data: Media(
                source: e.source,
                id: e.id,
                sort: e.sort,
                title: e.title ?? "'",
                description: e.description ?? '',
                parents: {id})))
        .toList();

    return Section.fromBase(base,
        content: [...media, ...childSections]..sort());
  }

  Future<void> setUpdateTime(DateTime time) => into(updateTimeTable).insert(
      UpdateTimeTableCompanion.insert(updateTime: time.millisecondsSinceEpoch));

  Future<DateTime?> getUpdateTime() async {
    final row = await select(updateTimeTable).getSingleOrNull();
    return row == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(row.updateTime);
  }
}

class DriftInsideData extends SiteDataLayer {
  final SiteDataLoader loader;
  final InsideDatabase database;
  final List<String> topIds;

  DriftInsideData(
      {required this.loader, required this.topIds, InsideDatabase? database})
      : database = database ?? InsideDatabase();

  @override
  Future<void> init() async {
    var lastUpdate = await database.getUpdateTime();

    if (lastUpdate == null) {
      var data = await loader.initialLoad();

      await database.transaction(() async {
        await addToDatabase(data);
      });
    } else {
      var data = await loader.load(lastUpdate, ensureLatest: false);

      if (data != null) {
        database.transaction(() async {
          await addToDatabase(data);
        });
      }
    }
  }

  @override
  Future<Media?> media(String id) => database.media(id);

  @override
  Future<Section?> section(String id) => database.section(id);

  @override
  Future<List<Section>> topLevel() =>
      Future.wait(topIds.map((e) async => (await database.section(e))!));

  Future<void> addToDatabase(SiteData data) async {
    // Might be faster to run all at the same time with Future.wait, but that might
    // be a bit much for an older phone, and probably won't make much diffirence in time.
    await database.addSections(data.sections.values.toList());
    await database.addMedia(data.medias.toList());
    await database.setUpdateTime(data.createdDate);
  }
}
