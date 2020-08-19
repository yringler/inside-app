import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:inside_api/models.dart';

part 'chosen-class.g.dart';

/// A class which has been given attention by the user.
@HiveType(typeId: 0)
class ChoosenClass extends HiveObject implements SectionReference {
  @HiveField(0)
  String url;
  @HiveField(1)
  bool isFavorite;
  @HiveField(2)
  bool isRecent;
  @HiveField(3)
  DateTime modifiedDate;
  @HiveField(4)
  int sectionId;

  Section section;

  ChoosenClass(
      {this.url,
      this.isFavorite = false,
      this.isRecent = false,
      this.modifiedDate,
      @required this.sectionId});
}
