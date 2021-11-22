import 'package:hive/hive.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';
import 'package:inside_data_flutter/inside_data_flutter.dart';

part 'chosen-class.g.dart';

/// A class which has been given attention by the user.
@HiveType(typeId: 1)
class ChoosenClass extends HiveObject {
  @HiveField(1)
  bool? isFavorite;
  @HiveField(2)
  bool? isRecent;
  @HiveField(3)
  DateTime? modifiedDate;
  @HiveField(4)
  String mediaId;

  Section? section;
  Media? get media => ChosenClassService.mediaCache[mediaId];

  ChoosenClass(
      {required this.mediaId,
      this.isFavorite = false,
      this.isRecent = false,
      this.modifiedDate,
      this.section});
}
