import 'package:hive/hive.dart';

part 'class-position.g.dart';

@HiveType(typeId: 5)
class ClassPosition extends HiveObject {
  // The source URL.
  @HiveField(0)
  String mediaId;

  /// The position in milliseconds.
  @HiveField(1)
  int _position;

  /// The update time in milliseconds. This could be used to
  /// delete old records.
  @HiveField(2)
  int _updateTime;

  Duration get position => Duration(milliseconds: _position);

  DateTime get getupdateTime => DateTime.fromMillisecondsSinceEpoch(_updateTime);
}