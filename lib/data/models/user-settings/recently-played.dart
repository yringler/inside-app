import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'recently-played.g.dart';

@HiveType(typeId: 5)
class RecentlyPlayed extends HiveObject {

  RecentlyPlayed({@required this.mediaId, @required this.parentId, Duration position}) {
    if (position != null) {
      this.position = position;
    }
  }

  // The source URL.
  @HiveField(0)
  final String mediaId;


  // This is usually a lesson ID, but can be a section ID if a section was turned into a lesson...
  // TODO: after #53, we can better keep track of the type of the parent.
  @HiveField(3)
  final String parentId;

  /// The position in milliseconds.
  @HiveField(1)
  int _position;

  /// The update time in milliseconds since epoch. This could be used to
  /// delete old records.
  @HiveField(2)
  int _updateTime;

  Duration get position => Duration(milliseconds: _position);

  set position(Duration duration) {
    if (duration != null) {
      _position = duration.inMilliseconds;
      _updateTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  DateTime get updateTime => DateTime.fromMillisecondsSinceEpoch(_updateTime);
}