import 'dart:convert';

import 'dart:io';

import 'package:inside_data/inside_data.dart';

/// Load data into SQLlite, save file for preloading into app.
Future<void> main() async {
  final drift = DriftInsideData.fromFolder(
      loader: MemoryLoader(
          data: SiteData.fromJson(
              json.decode(await File('dropbox.json').readAsString()))),
      topIds: topImagesInside.keys.map((e) => e.toString()).toList(),
      folder: '.');

  await drift.init();
  exit(0);
}
