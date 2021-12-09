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
  final dropBoxFile = '/site.v$dataVersion.json.gz';
  await File('.innnerDropbox.json').writeAsString(json.encode(site));

  print('uploading...');

  var request = Request(
      'POST', Uri.parse('https://content.dropboxapi.com/2/files/upload'))
    ..headers.addAll({
      'Content-Type': 'application/octet-stream',
      'Authorization': 'Bearer $key',
      'Dropbox-API-Arg':
          json.encode({'path': dropBoxFile, 'mode': 'overwrite', 'mute': true}),
    })
    ..bodyBytes = GZipCodec(level: 9).encode(utf8.encode(json.encode(site)));

  var response = await request.send();

  print(response.reasonPhrase);
}
