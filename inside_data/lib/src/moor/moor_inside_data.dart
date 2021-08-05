import 'dart:io';

import 'package:inside_data/inside_data.dart';
import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'moor_inside_data.g.dart';

class MediaTable extends Table {
  /// The ID of the section the media belongs to.
  TextColumn get parentId => text()();
  TextColumn get id => text()();
  IntColumn get sort => integer()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();

  /// How long the class is, in milliseconds.
  IntColumn get duration => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class SectionTable extends Table {
  TextColumn get id => text()();
  IntColumn get sort => integer()();

  /// A section can only have a single parent, but some sections kind of are
  /// in two places. So there's a placeholder section which redirects to the
  /// content.
  TextColumn get redirectId => text()();

  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The total number of classes in a section. Because this number is more subject
/// to change than other datums of a section, we move it to its own table.
class SectionAudioCountTable extends Table {
  TextColumn get id => text()();
  IntColumn get count => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Yes, an entire table. To store last upate time. Sue me.
class UpdateTimeTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Last time DB was updated, in milliseconds since epoch.
  IntColumn get updateTime => integer()();
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'insidedata.sqlite'));
    return VmDatabase(file);
  });
}

@UseMoor(
    tables: [SectionTable, MediaTable, SectionAudioCountTable, UpdateTimeTable])
class InsideDatabase extends _$InsideDatabase {
  InsideDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

class MoorInsideData extends SiteDataLayer {
  final SiteDataLoader loader;

  MoorInsideData({required this.loader});

  @override
  Future<void> init() {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  Future<Media> media(String id) {
    // TODO: implement media
    throw UnimplementedError();
  }

  @override
  Future<Section> parentOf(String id) {
    // TODO: implement parentOf
    throw UnimplementedError();
  }

  @override
  Future<Section> section(String id) {
    // TODO: implement section
    throw UnimplementedError();
  }

  @override
  List<Section> topLevel() {
    // TODO: implement topLevel
    throw UnimplementedError();
  }
}
