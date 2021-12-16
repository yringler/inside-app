import 'dart:io';
import 'package:flutter/cupertino.dart';
// ignore: implementation_imports
import 'package:hive/src/hive_impl.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class.dart';
import 'package:inside_chassidus/util/extract-id.dart';
import 'package:inside_data/inside_data.dart';
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

  /// Cache of all medias which are chosen.
  static Map<String, Media> mediaCache = {};

  final HiveImpl? hive;
  final Box<ChoosenClass>? classes;

  ChosenClassService({this.hive, this.classes});

  Future<void> set(
      {required Media media, bool? isFavorite, bool? isRecent}) async {
    mediaCache[media.id] = media;
    var chosen = classes!.get(media.id.toHiveId());

    await classes!.put(
        media.id.toHiveId(),
        ChoosenClass(
            mediaId: media.id,
            isFavorite: isFavorite ?? chosen?.isFavorite ?? false,
            isRecent: isRecent ?? chosen?.isRecent ?? false,
            modifiedDate: DateTime.now()));

    final newClass = classes!.get(media.id.toHiveId())!;
    if (!newClass.isRecent! && !newClass.isFavorite!) {
      await newClass.delete();
    }
  }

  Widget isFavoriteValueListenableBuilder(String id,
      {ValueBuilder<bool>? builder}) {
    if (!classes!.containsKey(id.toHiveId())) {
      // classes.put(source.toHiveId(), ChoosenClass(media: null));
    }

    return ValueListenableBuilder<Box<ChoosenClass>>(
      valueListenable: classes!.listenable(keys: [id.toHiveId()]),
      builder: (context, value, child) =>
          builder!(context, value.get(id.toHiveId())?.isFavorite ?? false),
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

  static Future<ChosenClassService> create(SiteDataLayer dataLayer) async {
    final hive = HiveImpl();
    final folder = await getApplicationDocumentsDirectory();
    hive.init(p.join(folder.path, 'chosen'));

    if (!hive.isAdapterRegistered(0)) {
      hive.registerAdapter(ChoosenClassAdapter());
    }

    Box<ChoosenClass>? classesBox;

    try {
      classesBox = await hive.openBox<ChoosenClass>('classes');
    } catch (_) {
      try {
        await classesBox?.close();
      } catch (_) {}

      final transferredData = await _getDataFromOldBox(folder);
      classesBox = await hive.openBox<ChoosenClass>('classes');
      await classesBox.addAll(transferredData);
    }

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

      final medias = (await Future.wait(classesBox.values
              .map((e) => dataLayer.media(e.mediaId))
              .toList()))
          .where((element) => element != null)
          .map((e) => e!)
          .map((e) => MapEntry(e.id, e))
          .toList();

      mediaCache.addEntries(medias);

      // In case an ID changes or something, or otherwise no longer available.
      for (var i in classesBox.values.toList()) {
        if (i.media == null) {
          await i.delete();
        }
      }
    }

    return ChosenClassService(hive: hive, classes: classesBox);
  }

  /// Old versions of the app (pre 3.6.0) also stored (the old inside-api) Media object
  /// directly. This, as long as its type adapter, don't really exist anymore.
  /// This method migrates the old format to the new and returns the new data style.
  static Future<List<ChoosenClass>> _getDataFromOldBox(Directory folder) async {
    final oldHive = HiveImpl();
    oldHive.init(p.join(folder.path, 'chosen'));
    oldHive.registerAdapter(MediaShimAdapter());
    oldHive.registerAdapter(ChoosenClassShimAdapter());

    final oldBox = await oldHive.openBox<ChoosenClassShim>('classes');

    final returnValue = oldBox.values
        .where((element) => element.media?.id != null)
        .map((e) => ChoosenClass(
            mediaId: e.media!.id!.toString(),
            isFavorite: e.isFavorite,
            isRecent: e.isRecent,
            modifiedDate: e.modifiedDate))
        .toList();

    await oldBox.deleteFromDisk();
    return returnValue;
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
