import 'package:hive/hive.dart';
import 'package:inside_chassidus/data/models/inside-data/media.dart';
import 'package:inside_chassidus/data/models/user-settings/recently-played.dart';
import 'package:inside_chassidus/util/extract-id.dart';

/// Provide read access to where user is up to in a lesson.
/// (Writing only happens in [AudioTask])
class RecentlyPlayedRepository {
  Box<RecentlyPlayed> _recent;

  /// Load class positions and save them to memory. Should be run once, at app
  /// startup.
  /// Loads the data and closes the connection to data source. This is done because
  /// only one thread can safely access a box at a time, and [AudioTask] must be it, because the UI
  /// thread isn't necessarily always going to be running; it can be closed, and the class will run
  /// in the background.
  init({bool loadBackgroundPositions}) async {
    _recent = await Hive.openBox<RecentlyPlayed>('uipositions');

    await _mantainSize(_recent);

    if (loadBackgroundPositions) {
      // Not sure if this is the best place for this.
      final backgroundPositionBox =
          await Hive.openBox<RecentlyPlayed>('positions');
      await _mantainSize(backgroundPositionBox);
      await backgroundPositionBox.close();
    }
  }

  Future<void> _mantainSize(Box positions) async {
    // Make sure that this doesn't grow out of control.
    // TODO: when there are too many entries, delete the oldest. Must
    // have a way to test it before implementing.
    if (positions.length > 200) {
      await positions.clear();
    }
  }

  Duration getPosition(Media media) => _recent.containsKey(media.hiveID)
      ? _recent.get(media.hiveID).position
      : Duration.zero;

  RecentlyPlayed getRecentlyPlayed(String id) {
    return _recent.get(extractID(id));
  }

  updatePosition(Media media, Duration position) {
    assert(position != null, "Position argument may not be null");

    if (_recent.containsKey(media.hiveID)) {
      var recent = _recent.get(media.hiveID);
      recent.position = position;
      recent.save();
    } else {
      _recent.put(
          media.hiveID,
          RecentlyPlayed(
              mediaId: media.source,
              parentId: media.lessonId,
              position: position));
    }
  }
}
