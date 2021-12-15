import 'package:hive/hive.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';
import 'package:inside_data/inside_data.dart';

part 'chosen-class.g.dart';

/// A class which has been given attention by the user.
@HiveType(typeId: 1)
class ChoosenClass extends HiveObject {
  // Hive ID 0 is kept blank for backwards compatability.

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

/// Temporary migrate class to support moving over old style chosen class box.
/// A class which has been given attention by the user.
@HiveType(typeId: 1)
class ChoosenClassShim extends HiveObject {
  /// This is only here for backwards compatability, this isn't
  /// used anymore.
  @HiveField(0)
  MediaShim? media;

  @HiveField(1)
  bool? isFavorite;
  @HiveField(2)
  bool? isRecent;
  @HiveField(3)
  DateTime? modifiedDate;

  ChoosenClassShim(
      {this.isFavorite = false, this.isRecent = false, this.modifiedDate});
}

/// We used to store the actual media with the class.
/// We don't anymore, but still have to create and register
/// a type adapter so that we can continue reading older archives.
@HiveType(typeId: 3)
class MediaShim {
  @HiveField(0)
  int? id;
}
