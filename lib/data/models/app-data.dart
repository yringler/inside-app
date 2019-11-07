import 'package:hive/hive.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';

/// An entry point into all saved state in the app.
class AppData {
  Future<LazyBox> _getSectionsBox() async {
    if (Hive.isBoxOpen('sections')) {
      return Hive.box('sections');
    }

    return Hive.openBox('sections', lazy: true);
  }

  Future<Box<PrimaryInside>> _getPrimaryBox() async {
    if (Hive.isBoxOpen('primary')) {
      return Hive.box('primary');
    }

    return Hive.openBox('primary');
  }

  /// Get a list of all primary sections.
  Future<List<PrimaryInside>> getPrimaryInside() async {
    var primarySections = List<PrimaryInside>.from((await _getPrimaryBox()).values);

    for (var section in primarySections) {
      section.section = await (await _getSectionsBox()).get(section.id);
    }

    return primarySections;
  }
}
