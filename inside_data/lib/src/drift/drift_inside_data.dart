import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:inside_data/inside_data.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:collection/collection.dart';
import 'dart:async';
import 'dart:isolate';
import 'package:drift/isolate.dart';

part 'drift_inside_data.g.dart';

class MediaParentsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mediaId => text()();
  TextColumn get parentSection => text()();
  IntColumn get sort => integer()();
}

class SectionParentsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sectionId => text()();
  TextColumn get parentSection => text()();
  IntColumn get sort => integer()();
}

/// Contains a single media/post
class MediaTable extends Table {
  /// In case there are multiple medias with same [source] and no post ID, this prevents
  /// unique constraint errors.
  IntColumn get pk => integer().autoIncrement()();

  /// The post ID if the class is it's own post. Otherwise, taken from media source.
  TextColumn get id => text()();

  TextColumn get source => text()();
  TextColumn get videoSource => text().withDefault(const Constant(''))();
  IntColumn get sort => integer()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get created => integer().withDefault(const Constant(0))();

  TextColumn get link => text().withDefault(const Constant(''))();

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

LazyDatabase _openConnection({required String folder, number = 1}) =>
    // the LazyDatabase util lets us find the right location for the file async.
    LazyDatabase(() async => NativeDatabase(
        File(InsideDatabase.getFilePath(folder, number: number))));

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
  static String getFilePath(String folder, {int number = 1}) =>
      p.join(folder, 'insidedata_$number.sqlite');

  InsideDatabase.fromNative({required NativeDatabase database})
      : super(database);

  InsideDatabase.fromFolder({required String folder, int number = 1})
      : super(_openConnection(folder: folder, number: number));

  InsideDatabase.connect(DatabaseConnection connection)
      : super.connect(connection);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (Migrator m) {
        return m.createAll();
      }, onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // we added the dueDate property in the change from version 1
          await m.addColumn(mediaTable, mediaTable.created);
        }
        if (from < 3) {
          await m.addColumn(mediaTable, mediaTable.link);
        }
        if (from < 4) {
          m.addColumn(mediaTable, mediaTable.videoSource);
        }
      });

  Future<void> addSections(
      Iterable<Section> sections, Map<String, List<String>> contentSort) async {
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
        .map((section) => section.parents
            .where((element) => element.isNotEmpty && element != '0')
            .map((parent) => SectionParentsTableCompanion.insert(
                sectionId: section.id,
                parentSection: parent,
                sort: contentSort[parent]!.indexOf(section.id))))
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

  Future<void> addMedia(
      Iterable<Media> medias, Map<String, List<String>> contentSort) async {
    final mediaCompanions = medias
        .map((e) => MediaTableCompanion.insert(
            videoSource: Value(e.videoSource),
            id: e.id,
            source: e.source,
            link: Value(e.link),
            sort: e.sort,
            duration: Value(e.length?.inMilliseconds),
            description: Value(e.description),
            created: Value(e.created!.millisecondsSinceEpoch),
            title: Value(e.title)))
        .toList();

    final mediaParents = medias
        .map((media) => media.parents.map((parent) =>
            MediaParentsTableCompanion.insert(
                mediaId: media.id,
                parentSection: parent,
                sort: contentSort[parent]!.indexOf(media.id))))
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
        videoSource: media.videoSource,
        id: id,
        sort: media.sort,
        created: DateTime.fromMillisecondsSinceEpoch(media.created),
        link: media.link,
        title: media.title ?? '',
        length: media.duration == null
            ? null
            : Duration(milliseconds: media.duration!),
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
    final childSectionsValue = (await childSectionsQuery.get())
        .map((e) => e.readTable(sectionTable))
        .toList();
    childSectionsValue.sort((a, b) => a.sort.compareTo(b.sort));

    final childSections = childSectionsValue
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

    final mediaRows = mediaValue.map((e) => e.readTable(mediaTable)).toList();
    mediaRows.sort((a, b) => a.sort.compareTo(b.sort));

    final media = mediaRows
        .map((e) => ContentReference.fromData(
            data: Media(
                source: e.source,
                videoSource: e.videoSource,
                id: e.id,
                sort: e.sort,
                link: e.link,
                created: DateTime.fromMillisecondsSinceEpoch(e.created),
                title: e.title ?? "'",
                length: e.duration == null
                    ? null
                    : Duration(milliseconds: e.duration!),
                description: e.description ?? '',
                parents: {id})))
        .toList();

    return Section.fromBase(base,
        audioCount: baseSectionRow.count,
        content: [...media, ...childSections]);
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

  Future<List<Media>> latestMedia() async {
    final latestMediaRows = await latest(10).get();

    final parentsMap =
        groupBy<LatestResult, String>(latestMediaRows, (row) => row.media.id);

    final medias = parentsMap.keys.map((e) {
      final base = parentsMap[e]!.first.media;

      return Media(
          source: base.source,
          videoSource: base.videoSource,
          created: DateTime.fromMillisecondsSinceEpoch(base.created),
          length: base.duration == null
              ? null
              : Duration(milliseconds: base.duration!),
          link: base.link,
          id: base.id,
          sort: base.sort,
          title: base.title ?? '',
          description: base.description ?? '',
          parents: parentsMap[e]!.map((e) => e.parent.parentSection).toSet());
    }).toList();

    medias.sort((m1, m2) => latestMediaRows
        .indexWhere((element) => element.media.id == m2.id)
        .compareTo(latestMediaRows
            .indexWhere((element) => element.media.id == m1.id)));

    return medias;
  }
}

/// We have two copies of the database, so that while one is being deleted and refreshed
/// with all of the latest data, user can still use the old one.
class _DataBasePair {
  final String folder;

  InsideDatabase get active => _active;

  /// Database for reading.
  late InsideDatabase _active;

  // Which number has the latest data and will be read from.
  late int activeNumber;

  int get writeNumber => activeNumber == 1 ? 2 : 1;

  _DataBasePair({required this.folder});

  Future<void> init() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

    final db1 = InsideDatabase.fromFolder(folder: folder, number: 1);
    final db2 = InsideDatabase.fromFolder(folder: folder, number: 2);

    final time1 = await db1.getUpdateTime();
    final time2 = await db2.getUpdateTime();

    if (time1 != null && time2 != null) {
      activeNumber = time1.isAfter(time2) ? 1 : 2;
    } else {
      // One or both DBs is null.
      // If db1 isn't null (or if both null), active is db1.
      activeNumber = time2 == null ? 1 : 2;
    }

    _active = activeNumber == 1 ? db1 : db2;

    final write = activeNumber == 1 ? db2 : db1;
    await write.close();
  }

  Future<void> close() async {
    await active.close();
  }

  /// Get the file which is not currently being used, to write to for next app load.
  File writeFile() {
    final path = InsideDatabase.getFilePath(folder, number: writeNumber);
    return File(path);
  }

  InsideDatabase getWriteDb(String folder) {
    return InsideDatabase.fromFolder(folder: folder, number: writeNumber);
  }
}

class DriftInsideData extends SiteDataLayer {
  final String? folder;
  final SiteDataLoader loader;
  final List<String> topIds;
  late _DataBasePair? _databases;

  /// Optionally, a single database can be set directly.
  final InsideDatabase? initDatabase;

  /// The number database to write to.
  final int? writeNumber;

  InsideDatabase get database => (_databases?.active ?? initDatabase)!;

  DriftInsideData.fromFolder(
      {required this.loader, required this.topIds, required String folder})
      : folder = folder,
        writeNumber = null,
        initDatabase = null,
        _databases = _DataBasePair(folder: folder);

  DriftInsideData.fromDatabase(
      {required this.loader,
      required this.topIds,
      required this.initDatabase,
      required this.writeNumber,
      required this.folder})
      : _databases = null;

  static Future<DriftInsideData> fromIsolate(
      {required SiteDataLoader loader,
      required List<String> topIds,
      required String folder}) async {
    // We have 2 DBs - one for writing, one for reading.
    // Figure out which one is for reading.
    final pair = _DataBasePair(folder: folder);
    await pair.init();
    final active = pair.activeNumber;
    final write = pair.writeNumber;
    await pair.close();

    // Create the connection.
    final driftIsolate = await _createDriftIsolate(
        path: InsideDatabase.getFilePath(folder, number: active));
    final connection = await driftIsolate.connect();

    return DriftInsideData.fromDatabase(
        loader: loader,
        folder: folder,
        topIds: topIds,
        writeNumber: write,
        initDatabase: InsideDatabase.connect(connection));
  }

  /// Init the database. The [preloadedDatabase] will be used if we don't have a database
  /// already. If there's already a DB, it will not be used, unless [forceRefresh] forces it
  /// to be updated from the resource. For example, app upgrade.
  @override
  Future<void> init(
      {File? preloadedDatabase, bool forceRefresh = false}) async {
    if (_databases != null) {
      await _databases!.init();
    }

    final lastUpdate = await database.getUpdateTime();

    /*
     * If this is the first app load, try to do the quick copy of asset database.
     * Or, trigger a new load of one of the databases in the background.
     */

    if ((lastUpdate == null || forceRefresh) && preloadedDatabase != null) {
      final writeFile = _getWriteFile();

      if (writeFile == null) {
        return;
      }

      await writeFile.writeAsBytes(await preloadedDatabase.readAsBytes());

      if (_databases != null) {
        // Re-init the database pair to use new file.
        await _databases!.close();
        await _databases!.init();
      }
    }
  }

  File? _getWriteFile() {
    final hasDbPair = _databases != null;
    final hasPathSpec = writeNumber != null && folder != null;
    if (!(hasDbPair || hasPathSpec)) {
      return null;
    }

    return _databases != null
        ? _databases!.writeFile()
        : File(InsideDatabase.getFilePath(folder!, number: writeNumber!));
  }

  @override
  Future<void> close() async => await _databases?.close();

  /// Prepare the write database, update it with data to be used next app load.
  @override
  Future<void> prepareUpdate() async {
    final newDb = await _getLatestDb(
        await lastUpdate() ?? DateTime.fromMillisecondsSinceEpoch(0));

    if (newDb != null) {
      _getWriteFile()?.writeAsBytes(newDb);
    }

    // Untill we have incremental updates, loading whole sites of JSON is too heavy, so we
    // download sqllite DBs.
  }

  /// Use loader to get update. For now, this is only here to prepare the DB on server.
  /// This is horrid. Returns the number of database which is being written to.
  Future<int?> prepareUpdateFromLoader() async {
    if (_databases == null) {
      return null;
    }

    assert(folder != null);

    if (folder == null) {
      return null;
    }

    var data = await loader
        .load(await lastUpdate() ?? DateTime.fromMillisecondsSinceEpoch(0));

    if (data != null) {
      final writeDb = _databases!.getWriteDb(folder!);
      await writeDb.transaction(() async {
        await addToDatabase(data);
      });
      await writeDb.close();

      return _databases!.writeNumber;
    }

    return null;
  }

  @override
  Future<Media?> media(String id) => database.media(id);

  @override
  Future<Section?> section(String id) => database.section(id);

  @override
  Future<List<Section>> topLevel() async =>
      (await Future.wait(topIds.map((e) async => (await database.section(e)))))
          .where((e) => e != null)
          .map((e) => e!)
          .toList();

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
      await database.addSections(
          data.sections.values.toSet(), data.contentSort);
      await database.addMedia(data.medias.values.toSet(), data.contentSort);
      await database.setUpdateTime(data.createdDate);
    });
  }

  @override
  Future<DateTime?> lastUpdate() => database.getUpdateTime();

  @override
  Future<List<Media>> recent() => database.latestMedia();
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

const dataVersion = JsonLoader.dataVersion;

/// Downloads newer DB from API if we don't already have the latest.
Future<List<int>?> _getLatestDb(DateTime lastLoadTime) async {
  final request = http.Request(
      'GET',
      Uri.parse(
          'https://inside-api-staging.herokuapp.com/check?date=${lastLoadTime.millisecondsSinceEpoch}&v=$dataVersion'));

  try {
    final response = await request.send();

    if (response.statusCode == HttpStatus.ok) {
      return GZipCodec().decode(await response.stream.toBytes());
    }
  } catch (ex) {
    print(ex);
  }

  return null;
}

/// Returns the core of the isolate based drift connection.
Future<DriftIsolate> _createDriftIsolate({required String path}) async {
  final receivePort = ReceivePort();

  await Isolate.spawn(
    _startBackground,
    _IsolateStartRequest(receivePort.sendPort, path),
  );

  // _startBackground will send the DriftIsolate to this ReceivePort
  return await receivePort.first as DriftIsolate;
}

void _startBackground(_IsolateStartRequest request) {
  final executor = NativeDatabase(File(request.targetPath));

  final driftIsolate = DriftIsolate.inCurrent(
    () => DatabaseConnection.fromExecutor(executor),
  );

  request.sendDriftIsolate.send(driftIsolate);
}

// used to bundle the SendPort and the target path, since isolate entry point
// functions can only take one parameter.
class _IsolateStartRequest {
  final SendPort sendDriftIsolate;
  final String targetPath;

  _IsolateStartRequest(this.sendDriftIsolate, this.targetPath);
}
