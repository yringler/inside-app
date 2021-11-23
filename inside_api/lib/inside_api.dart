import 'dart:io';

import 'package:http/http.dart';
import 'package:dotenv/dotenv.dart' show env;

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
