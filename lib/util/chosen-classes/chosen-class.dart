import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:inside_api/models.dart';

part 'chosen-class.g.dart';

/// A class which has been given attention by the user.
@HiveType(typeId: 1)
class ChoosenClass extends HiveObject implements SectionReference {
  @HiveField(0)
  final Media media;
  @HiveField(1)
  bool isFavorite;
  @HiveField(2)
  bool isRecent;
  @HiveField(3)
  DateTime modifiedDate;

  @override
  SiteDataItem parent;
  @override
  Section section;
  @override
  int get parentId => media?.parentId;
  @override
  int get sectionId => media?.sectionId;

  ChoosenClass(
      {@required this.media,
      this.isFavorite = false,
      this.isRecent = false,
      this.modifiedDate});
}
