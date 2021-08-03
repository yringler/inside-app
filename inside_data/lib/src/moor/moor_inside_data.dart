import 'dart:io';

import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'moor_inside_data.g.dart';

class Media extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
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

@UseMoor()
class InsideDatabase extends _$InsideDatabase {
  InsideDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}
