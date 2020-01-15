import 'package:hive/hive.dart';
import 'package:inside_chassidus/util/audio-service/audio-task.dart';
import 'package:inside_chassidus/data/models/user-settings/class-position.dart';

/// Provide read access to where user is up to in a lesson.
/// (Writing only happens in [AudioTask])
class ClassPositionRepository {
  Map<String, ClassPosition> positions;

  /// Load class positions and save them to memory. Should be run once, at app
  /// startup.
  /// Loads the data and closes the connection to data source. This is done because
  /// only one thread can safely access a box at a time, and [AudioTask] must be it, because the UI
  /// thread isn't necessarily always going to be running; it can be closed, and the class will run
  /// in the background.
  init() async {
    final positionBox = await Hive.openBox<ClassPosition>('positions');

    // ...

    await positionBox.close();
  }
}