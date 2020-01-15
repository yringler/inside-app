import 'package:hive/hive.dart';

part 'class-position.g.dart';

@HiveType(typeId: 5)
class ClassPosition extends HiveObject {

  ClassPosition({this.mediaId, Duration position}) {
    this.position = position;
  }

  // The source URL.
  @HiveField(0)
  final String mediaId;

  /// The position in milliseconds.
  @HiveField(1)
  int _position;

  /// The update time in milliseconds since epoch. This could be used to
  /// delete old records.
  @HiveField(2)
  int _updateTime;

  Duration get position => Duration(milliseconds: _position);

  set position(Duration duration) {
    _position = duration.inMilliseconds;
    _updateTime = DateTime.now().millisecondsSinceEpoch;
  }

  DateTime get updateTime => DateTime.fromMillisecondsSinceEpoch(_updateTime);
}