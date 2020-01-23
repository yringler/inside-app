import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:inside_chassidus/data/models/audio-length.dart';
import 'package:inside_chassidus/data/models/inside-data-json-root.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:inside_chassidus/data/models/user-settings/class-position.dart';
import 'package:path_provider/path_provider.dart';

/// An entry point into all saved state in the app.
class AppData {
  static const dataTypeVersion = 6;

  /// Get a list of all primary sections.
  Future<List<PrimaryInside>> getPrimaryInside() async {
    var primarySections =
        List<PrimaryInside>.from(Hive.box<PrimaryInside>('primary').values);

    final sectionBox = Hive.lazyBox<SiteSection>('sections');
    for (var section in primarySections) {
      section.section = await sectionBox.get(section.id);
    }

    return primarySections;
  }

  /// Set up hive folder for use.
  static Future<Directory> initHiveFolder() async {
    final folder = await getApplicationSupportDirectory();
    final hiveFolder = new Directory('${folder.path}/hive');

    await hiveFolder.create();

    return hiveFolder;
  }

  /// Access data store, download data if needed. This method should only be called once per
  /// app run.
  static Future init(BuildContext context) async {
    if (Hive.isBoxOpen('primary')) {
      return;
    }

    final hiveFolder = await initHiveFolder();

    // For live reload causes an exception when it registers twice.
    try {
      Hive.init(hiveFolder.path);

      Hive.registerAdapter(PrimaryInsideAdapter());
      Hive.registerAdapter(SiteSectionAdapter());
      Hive.registerAdapter(LessonAdapter());
      Hive.registerAdapter(MediaAdapter());
      Hive.registerAdapter(ClassPositionAdapter());
    } catch (exception) {
      print(exception);
    }

    try {
      final primaryBox = await Hive.openBox<PrimaryInside>('primary');
      final sectionBox = await Hive.openLazyBox<SiteSection>('sections');
      final lessonBox = await Hive.openLazyBox<Lesson>('lessons');
      final appsettingsBox = await Hive.openBox('settings');

      if (primaryBox.keys.isEmpty ||
          sectionBox.isEmpty ||
          lessonBox.isEmpty ||
          appsettingsBox.isEmpty) {
        await _getData(context);
        await _initSettings();
      }

      if (appsettingsBox.get("dataversion", defaultValue: 0) <
          dataTypeVersion) {
        primaryBox.deleteFromDisk();
        sectionBox.deleteFromDisk();
        lessonBox.deleteFromDisk();
        await _getData(context);
        await _initSettings();
      }
    } catch (error) {
      print(error);
      // If there's an error, bail out - clear all data.
      // This will cause loss of settings etc, but hopefully
      // makes it less likely for the app to end up in a non-openable state.
      await Hive.close();
      await hiveFolder.delete(recursive: true);
      await hiveFolder.create();
      await _refreshData(hiveFolder, context);
    }
  }

  static Future _refreshData(Directory hiveFolder, BuildContext context) async {
    try {
      await Hive.deleteFromDisk();
    } finally {
      await _getData(context);
      await _initSettings();
    }
  }

  static Future _initSettings() async {
    final appsettingsBox = await Hive.openBox('settings');
    await appsettingsBox.put('dataversion', dataTypeVersion);
  }

  // Loads lessons, sections, and durations, and saves to hive.
  static Future _getData(BuildContext context) async {
    // Load the JSON.
    final mainJson =
        await DefaultAssetBundle.of(context).loadString("assets/data.json");
    final durationJson =
        await DefaultAssetBundle.of(context).loadString("assets/duration.json");

    // Open the boxes.
    final primaryBox = await Hive.openBox<PrimaryInside>('primary');
    final sectionBox = await Hive.openLazyBox<SiteSection>('sections');
    final lessonBox = await Hive.openLazyBox<Lesson>('lessons');
    final insideData = await compute(_parseJSON, [mainJson, durationJson]);

    // Create a key/value map for hive.
    final primaryMap = Map<String, PrimaryInside>.fromIterable(
        insideData.topLevel,
        key: (inside) => inside.id);

    // Save all data to hive.
    await primaryBox.putAll(primaryMap);
    await sectionBox.putAll(insideData.sections);
    await lessonBox.putAll(insideData.lessons);
  }

  static Future<InsideDataJsonRoot> _parseJSON(List<String> json) async {
    final mainJson = json[0];
    final durationJson = json[1];

    // Parse the main data and the durations data.
    final insideData = InsideDataJsonRoot.fromJson(jsonDecode(mainJson));
    final rawDurations = jsonDecode(durationJson) as List;
    final durations = rawDurations
        .map((d) => AudioLength.fromJson(d as Map<String, dynamic>));
    final durationMap = Map<String, Duration>.fromIterable(durations,
        key: (d) => d.source,
        value: (d) => d.milliseconds > 1000
            ? Duration(milliseconds: d.milliseconds)
            : null);

    // Set the lesson id and the duration.
    for (var lesson in insideData.lessons.values) {
      if (lesson.audio?.isNotEmpty ?? false) {
        for (var media in lesson.audio) {
          media.duration = durationMap[media.source];
          media.lessonId = lesson.id;
        }
      }
    }

    return insideData;
  }
}
