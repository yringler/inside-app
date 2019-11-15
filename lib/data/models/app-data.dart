import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:inside_chassidus/data/models/audio-length.dart';
import 'package:inside_chassidus/data/models/inside-data-json-root.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:path_provider/path_provider.dart';

/// An entry point into all saved state in the app.
class AppData {
  /// Get a list of all primary sections.
  Future<List<PrimaryInside>> getPrimaryInside() async {
    var primarySections =
        List<PrimaryInside>.from(Hive.box<PrimaryInside>('primary').values);

    final sectionBox = Hive.box('sections') as LazyBox;
    for (var section in primarySections) {
      section.section = await sectionBox.get(section.id);
    }

    return primarySections;
  }

  /// Access data store, download data if needed. This method should only be called once per
  /// app run.
  static Future init(BuildContext context) async {
    if (Hive.isBoxOpen('primary')) {
      return;
    }

    final folder = await getApplicationSupportDirectory();
    final hiveFolder = new Directory('${folder.path}/hive');

    await hiveFolder.create();

    // For live reload causes an exception when it registers twice.
    try {
      Hive.init(hiveFolder.path);

      Hive.registerAdapter(PrimaryInsideAdapter(), 1);
      Hive.registerAdapter(SiteSectionAdapter(), 2);
      Hive.registerAdapter(LessonAdapter(), 3);
      Hive.registerAdapter(MediaAdapter(), 4);
    } catch (exception) {
      print(exception);
    }

    try {
      final primaryBox = await Hive.openBox<PrimaryInside>('primary');
      final sectionBox = await Hive.openBox('sections', lazy: true) as LazyBox;
      final lessonBox = await Hive.openBox('lessons', lazy: true) as LazyBox;

      if (primaryBox.keys.isEmpty || sectionBox.isEmpty || lessonBox.isEmpty) {
        await saveDataToHive(context);
      }
    } catch (error) {
      print(error);
      await hiveFolder.delete();
      await hiveFolder.create();
      await saveDataToHive(context);
    }
  }

  // Loads lessons, sections, and durations, and saves to hive.
  static Future saveDataToHive(BuildContext context) async {
    final mainJson =
        await DefaultAssetBundle.of(context).loadString("assets/data.json");
    final durationJson =
        await DefaultAssetBundle.of(context).loadString("assets/duration.json");

    final primaryBox = await Hive.openBox<PrimaryInside>('primary');
    final sectionBox = await Hive.openBox('sections', lazy: true) as LazyBox;
    final lessonBox = await Hive.openBox('lessons', lazy: true) as LazyBox;

    final insideData = InsideDataJsonRoot.fromJson(jsonDecode(mainJson));
    final rawDurations = jsonDecode(durationJson) as List;
    final durations = rawDurations
        .map((d) => AudioLength.fromJson(d as Map<String, dynamic>));
    final durationMap = Map<String, Duration>.fromIterable(durations,
        key: (d) => d.source,
        value: (d) => d.milliseconds > 1000 ? Duration(milliseconds: d.milliseconds) : null);

    for (var lesson in insideData.lessons.values) {
      if (lesson.audio?.isNotEmpty ?? false) {
        for (var media in lesson.audio) {
          media.duration = durationMap[media.source];
          media.lessonId = lesson.id;
        }
      }
    }

    final primaryMap = Map<String, PrimaryInside>.fromIterable(
        insideData.topLevel,
        key: (inside) => inside.id);

    await primaryBox.putAll(primaryMap);
    await sectionBox.putAll(insideData.sections);
    await lessonBox.putAll(insideData.lessons);
  }
}
