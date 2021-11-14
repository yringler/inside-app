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
])
class InsideDatabase extends _$InsideDatabase {
  InsideDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> addSections(List<Section> sections) {
    final sectionCompanions = sections
        .map((value) => SectionTableCompanion.insert(
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

  DriftInsideData({required this.loader, required this.database});

  @override
  Future<void> init() async {
    var lastUpdate =
        await database.select(database.updateTimeTable).getSingleOrNull();

    if (lastUpdate == null) {
      var data = await loader.load(DateTime.fromMillisecondsSinceEpoch(0));

      await database.transaction(() async {
        await addToDatabase(data);
      });
    } else {
      loader
          .load(DateTime.fromMillisecondsSinceEpoch(lastUpdate.updateTime),
              ensureLatest: true)
          .then((value) {
        database.transaction(() async {
          await addToDatabase(value);
        });
      });
    }
  }

  @override
  Future<Media> media(String id) {
    // TODO: implement media
    throw UnimplementedError();
  }

  @override
  Future<Section> section(String id) {
    // TODO: implement section
    throw UnimplementedError();
  }

  @override
  Future<List<Section>> topLevel() {
    // TODO: implement topLevel
    throw UnimplementedError();
  }

  Future<void> addToDatabase(SiteData data) async {
    // Might be faster to run all at the same time with Future.wait, but that might
    // be a bit much for an older phone, and probably won't make much diffirence in time.
    await database.addSections(data.sections.values.toList());
    await database.addMedia(data.medias.toList());
    await database.setUpdateTime(data.createdDate);
  }
}
