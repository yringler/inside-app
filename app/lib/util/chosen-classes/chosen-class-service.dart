import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
// ignore: implementation_imports
import 'package:hive/src/hive_impl.dart';
import 'package:inside_api/models.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class.dart';
import 'package:inside_chassidus/util/extract-id.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:hive_flutter/hive_flutter.dart';

typedef ValueBuilder<T> = Widget Function(BuildContext context, T value);

class ChosenClassService {
  /// The most recent classes to save.
  static const int maxRecent = 30;

  /// The most favorites to save.
  static const int maxFavorite = 200;

  /// How many extra to have before deleting.
  static const int deleteAtMultiplier = 2;

  final HiveImpl? hive;
  final Box<ChoosenClass>? classes;

  ChosenClassService({this.hive, this.classes});

  Future<void> set(
      {required Media source, bool? isFavorite, bool? isRecent}) async {
    var chosen = classes!.get(source.source!.toHiveId());

    await classes!.put(
        source.source!.toHiveId(),
        ChoosenClass(
            media: source,
            isFavorite: isFavorite ?? chosen?.isFavorite ?? false,
            isRecent: isRecent ?? chosen?.isRecent ?? false,
            modifiedDate: DateTime.now()));

    final newClass = classes!.get(source.source!.toHiveId())!;
    if (!newClass.isRecent! && !newClass.isFavorite!) {
      await newClass.delete();
    }
  }

  bool isFavorite(String source) =>
      classes!.get(source.toHiveId())?.isFavorite ?? false;

  Widget isFavoriteValueListenableBuilder(String source,
      {ValueBuilder<bool>? builder}) {
    if (!classes!.containsKey(source.toHiveId())) {
      // classes.put(source.toHiveId(), ChoosenClass(media: null));
    }

    return ValueListenableBuilder<Box<ChoosenClass>>(
      valueListenable: classes!.listenable(keys: [source.toHiveId()]),
      builder: (context, value, child) =>
          builder!(context, value.get(source.toHiveId())?.isFavorite ?? false),
    );
  }

  List<ChoosenClass> getSorted({bool? recent, bool? favorite}) {
    return classes!.values
        .where((element) =>
            (recent == null || element.isRecent == recent) &&
            (favorite == null || element.isFavorite == favorite))
        .toList()
          // Compare b to a to sort by most recent first.
          ..sort((a, b) => b.modifiedDate!.compareTo(a.modifiedDate!));
  }

  static Future<ChosenClassService> create() async {
    final hive = HiveImpl();
    final folder = await getApplicationDocumentsDirectory();
    hive.init(p.join(folder.path, 'chosen'));

    if (!hive.isAdapterRegistered(0)) {
      hive.registerAdapter(ChoosenClassAdapter());
      hive.registerAdapter(MediaAdapter());
    }

    final classesBox = await hive.openBox<ChoosenClass>('classes');

    // Don't save too much.
    if (classesBox.isNotEmpty) {
      // Recent classes which aren't favorite.
      await _deleteTooMany(
          classBox: classesBox,
          isRecent: true,
          isFavorite: false,
          max: maxRecent);

      // Favorite classes which aren't recent.
      await _deleteTooMany(
          classBox: classesBox,
          isFavorite: true,
          isRecent: false,
          max: maxFavorite);

      // Favorite classes, recent or not.
      await _deleteTooMany(
          classBox: classesBox, isFavorite: true, max: maxFavorite);
    }

    return ChosenClassService(hive: hive, classes: classesBox);
  }

  static Future<void> _deleteTooMany(
      {required Box<ChoosenClass> classBox,
      required int max,
      bool? isFavorite,
      bool? isRecent}) async {
    // Don't do anything if there isn't anything to delete.
    if (classBox.length < max * deleteAtMultiplier) {
      return;
    }

    // Get the matching classes.
    final classes = classBox.values.where((element) {
      if (isFavorite != null && isFavorite != element.isFavorite) {
        return false;
      }
      if (isRecent != null && isRecent != element.isRecent) {
        return false;
      }
      return true;
    }).toList();

    // Sort, least recent first.
    classes.sort((a, b) => a.modifiedDate!.compareTo(b.modifiedDate!));

    // Delete as many as we need to get back down to size.
    final deleting =
        classes.take(classes.length - max).map((e) => e.delete()).toList();

    await Future.wait(deleting);
  }
}
