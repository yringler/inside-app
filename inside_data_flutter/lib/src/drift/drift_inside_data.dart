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
  /// In case there are multiple medias with same [source] and no post ID, this prevents
  /// unique constraint errors.
  IntColumn get pk => integer().autoIncrement()();

  /// The post ID if the class is it's own post. Otherwise, taken from media source.
  TextColumn get id => text()();

  TextColumn get source => text()();
  IntColumn get sort => integer()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();

  /// How long the class is, in milliseconds.
  IntColumn get duration => integer().nullable()();
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

LazyDatabase _openConnection({String? folder}) {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    folder ??= await InsideDatabase.getFileFolder();
    final file = File(p.join(folder!, 'insidedata.sqlite'));
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
  static Future<String> getFileFolder() async =>
      (await getApplicationSupportDirectory()).path;

  /// Optionally pass in a [database] (this is mostly intended for unit testing, to pass
  /// in an in memory database).
  InsideDatabase({NativeDatabase? database, String? folder})
      : super(database ?? _openConnection(folder: folder));

  @override
  int get schemaVersion => 1;

  Future<void> addSections(Iterable<Section> sections) async {
    final sectionCompanions = sections
        .map((value) => SectionTableCompanion.insert(
            link: value.link,
            sort: value.sort,
            count: value.audioCount,
            description: Value(value.description),
            id: value.id,
            title: Value(value.title)))
        .toList();

    assert(sectionCompanions.map((e) => e.id).toSet().length ==
        sectionCompanions.length);

    final sectionParents = sections
        .map((section) => section.parents.map((parent) =>
            SectionParentsTableCompanion.insert(
                sectionId: section.id, parentSection: parent)))
        .expand((element) => element)
        .toList();

    for (var sectionCompanionGroups in groupsOf(sectionCompanions, 100)) {
      await batch((batch) {
        batch.insertAll(sectionTable, sectionCompanionGroups,
            mode: InsertMode.insertOrReplace);
      });
    }

    for (var sectionParentsGroups in groupsOf(sectionParents, 100)) {
      await batch((batch) {
        batch.insertAll(sectionParentsTable, sectionParentsGroups,
            mode: InsertMode.insertOrReplace);
      });
    }
  }

  Future<void> addMedia(Iterable<Media> medias) async {
    final mediaCompanions = medias
        .map((e) => MediaTableCompanion.insert(
            id: e.id,
            source: e.source,
            sort: e.sort,
            duration: Value(e.length?.inMilliseconds),
            description: Value(e.description),
            title: Value(e.title)))
        .toList();

    final mediaParents = medias
        .map((media) => media.parents.map((parent) =>
            MediaParentsTableCompanion.insert(
                mediaId: media.id, parentSection: parent)))
        .expand((element) => element)
        .toList();

    assert(mediaCompanions.map((e) => e.id).toSet().length ==
        mediaCompanions.length);

    for (var mediaGroups in groupsOf(mediaCompanions, 100)) {
      await batch((batch) {
        batch.insertAll(mediaTable, mediaGroups,
            mode: InsertMode.insertOrReplace);
      });
    }

    for (var parentGroups in groupsOf(mediaParents, 100)) {
      await batch((batch) {
        batch.insertAll(mediaParentsTable, parentGroups,
            mode: InsertMode.insertOrReplace);
      });
    }
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
    final baseSectionRows = baseSectionQueryValue
        .map((e) => e.readTableOrNull(sectionTable))
        .where((element) => element != null)
        .toList();

    if (baseSectionRows.isEmpty) {
      return null;
    }

    final baseSectionRow = baseSectionRows.first!;

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
                audioCount: e.count,
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
                length: e.duration == null
                    ? null
                    : Duration(milliseconds: e.duration!),
                description: e.description ?? '',
                parents: {id})))
        .toList();

    return Section.fromBase(base,
        audioCount: baseSectionRow.count,
        content: [...media, ...childSections]..sort());
  }

  Future<void> setUpdateTime(DateTime time) async {
    await delete(updateTimeTable).go();
    await into(updateTimeTable).insert(
        UpdateTimeTableCompanion.insert(
            id: const Value(0), updateTime: time.millisecondsSinceEpoch),
        mode: InsertMode.insertOrReplace);
  }

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
      {required this.loader,
      required this.topIds,
      InsideDatabase? database,
      String? dbFolder})
      : database = database ?? InsideDatabase(folder: dbFolder);

  @override
  Future<void> init() async {
    var lastUpdate = await database.getUpdateTime();

    if (lastUpdate == null) {
      var data = await loader.initialLoad();

      await database.transaction(() async {
        await addToDatabase(data);
      });
    } else {
      var data = await loader.load(lastUpdate);

      if (data != null) {
        await database.transaction(() async {
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
    await database.transaction(() async {
      // A bug was observed that, when new site data is added, it isn't replacing the records, it's adding.
      // So, clear the database.
      // When we add partial updates, we'll have to take a more granular approach.
      if (data.sections.length > 100 || data.medias.length > 100) {
        await Future.wait(
            database.allTables.map((e) => database.delete(e).go()));
      }

      // Might be faster to run all at the same time with Future.wait, but that might
      // be a bit much for an older phone, and probably won't make much diffirence in time.
      await database.addSections(data.sections.values.toSet());
      await database.addMedia(data.medias.toSet());
      await database.setUpdateTime(data.createdDate);
    });
  }

  @override
  Future<DateTime?> lastUpdate() => database.getUpdateTime();
}

Iterable<List<T>> groupsOf<T>(List<T> list, int groupSize) sync* {
  yield list;

  // int start = 0;
  // for (; start + groupSize <= list.length; start += groupSize) {
  //   yield list.sublist(start, start + groupSize);
  // }

  // if (start + groupSize > list.length) {
  //   yield list.sublist(start);
  // }
}
