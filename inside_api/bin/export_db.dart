import 'dart:convert';

import 'dart:io';

import 'package:inside_api/inside_api.dart';
import 'package:inside_data/inside_data.dart';

/// Load data into SQLlite, save file for preloading into app.
Future<void> main() async {
  createSqliteFile(SiteData.fromJson(
      json.decode(await File('dropbox.json').readAsString())));

  exit(0);
}
