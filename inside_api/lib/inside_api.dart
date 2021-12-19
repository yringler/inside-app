import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:dotenv/dotenv.dart' show env;
import 'package:inside_data/inside_data.dart';

/// Tell API what the newest version of data is.
Future<void> notifyApiOfLatest(DateTime date, String version) async {
  var request = Request(
      'GET',
      Uri.parse(env['updateUrlWithAuth']! +
          '&date=${date.millisecondsSinceEpoch}&v=$version'));

  final response = await request.send();

  if (response.statusCode != HttpStatus.noContent) {
    File('.errorlog').writeAsStringSync('Error! Setting failed');
  }
}

/// Upload newest version of data to dropbox.
/// (Thank you, Raj @https://stackoverflow.com/a/56572616)
Future<void> uploadToDropbox(SiteData site, String dataVersion) async {
  final key = env['dropBoxToken']!;
  final localFile = await createSqliteFile(site);
  final dropBoxFile = '/site.v$dataVersion.sqlite.gz';
  print('uploading...');

  var request = Request(
      'POST', Uri.parse('https://content.dropboxapi.com/2/files/upload'))
    ..headers.addAll({
      'Content-Type': 'application/octet-stream',
      'Authorization': 'Bearer $key',
      'Dropbox-API-Arg':
          json.encode({'path': dropBoxFile, 'mode': 'overwrite', 'mute': true}),
    })
    ..bodyBytes = GZipCodec(level: 9).encode(await localFile.readAsBytes());

  var response = await request.send();

  print(response.reasonPhrase);
}

Future<File> createSqliteFile(SiteData site) async {
  final dbFile = File(InsideDatabase.getFilePath('.'));
  final dbFile2 = File(InsideDatabase.getFilePath('.', number: 2));

  if (dbFile.existsSync()) {
    dbFile.deleteSync();
  }

  if (dbFile2.existsSync()) {
    dbFile2.deleteSync();
  }

  final drift = DriftInsideData.fromFolder(
      loader: MemoryLoader(data: site),
      topIds: topImagesInside.keys.map((e) => e.toString()).toList(),
      folder: '.');

  await drift.init();
  final dbNumber = await drift.prepareUpdateFromLoader();
  await drift.close();

  return dbNumber! == 1 ? dbFile : dbFile2;
}
