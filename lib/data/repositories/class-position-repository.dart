import 'package:hive/hive.dart';
import 'package:inside_chassidus/data/models/inside-data/media.dart';
import 'package:inside_chassidus/util/audio-service/audio-task.dart';
import 'package:inside_chassidus/data/models/user-settings/class-position.dart';

/// Provide read access to where user is up to in a lesson.
/// (Writing only happens in [AudioTask])
class ClassPositionRepository {
  Map<String, ClassPosition> _positions;

  /// Load class positions and save them to memory. Should be run once, at app
  /// startup.
  /// Loads the data and closes the connection to data source. This is done because
  /// only one thread can safely access a box at a time, and [AudioTask] must be it, because the UI
  /// thread isn't necessarily always going to be running; it can be closed, and the class will run
  /// in the background.
  init() async {
    final positionBox = await Hive.openBox<ClassPosition>('positions');

    _positions = Map<String, ClassPosition>.fromIterable(positionBox.values,
        key: (position) => position.mediaId);

    // Make sure that this doesn't grow out of control.
    // TODO: when there are 2000 entries, delete the oldest thousand. Must
    // have a way to test it before implementing.
    if (positionBox.length > 2000) {
      await positionBox.clear();
    }

    await positionBox.close();
  }

  Duration getPosition(Media media) => _positions.containsKey(media.source)
      ? _positions[media.source].position
      : Duration.zero;

  updatePosition(Media media, Duration position) {
    assert(position != null, "Position argument may not be null");

    if (_positions.containsKey(media.source)) {
      _positions[media.source].position = position;
    } else {
      _positions[media.source] = ClassPosition(mediaId: media.lessonId, position: position);
    }
  }
}
