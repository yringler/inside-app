import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
  static const maxRecentClasses = 1;
  static const deleteRecentClassesAt = maxRecentClasses * 2;

  final HiveImpl hive;
  final Box<ChoosenClass> classes;

  ChosenClassService({this.hive, this.classes});

  Future<void> set(
      {@required Media source, bool isFavorite, bool isRecent}) async {
    var chosen = classes.get(source.source.toHiveId());

    await classes.put(
        source.source.toHiveId(),
        ChoosenClass(
            media: source,
            isFavorite: isFavorite ?? chosen?.isFavorite ?? false,
            isRecent: isRecent ?? chosen?.isRecent ?? false,
            modifiedDate: DateTime.now()));

    final newClass = classes.get(source.source.toHiveId());
    if (!newClass.isRecent && !newClass.isFavorite) {
      await newClass.delete();
    }
  }

  bool isFavorite(String source) =>
      classes.get(source.toHiveId())?.isFavorite ?? false;

  Widget isFavoriteValueListenableBuilder(String source,
      {ValueBuilder<bool> builder}) {
    if (!classes.containsKey(source.toHiveId())) {
      // classes.put(source.toHiveId(), ChoosenClass(media: null));
    }

    return ValueListenableBuilder<Box<ChoosenClass>>(
      valueListenable: classes.listenable(keys: [source.toHiveId()]),
      builder: (context, value, child) =>
          builder(context, value.get(source.toHiveId())?.isFavorite ?? false),
    );
  }

  List<ChoosenClass> getSorted({bool recent, bool favorite}) {
    return classes.values
        .where((element) =>
            (recent == null || element.isRecent == recent) &&
            (favorite == null || element.isFavorite == favorite))
        .toList()
          // Compare b to a to sort by most recent first.
          ..sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));
  }

  static Future<ChosenClassService> create() async {
    final hive = HiveImpl();
    final folder = await getApplicationDocumentsDirectory();
    hive.init(p.join(folder.path, 'chosen'));

    if (!hive.isAdapterRegistered(0)) {
      hive.registerAdapter(ChoosenClassAdapter());
      hive.registerAdapter(MediaAdapter());
    }

    final classes = await hive.openBox<ChoosenClass>('classes');

    // Don't save too many recent classes.
    if (classes.isNotEmpty) {
      final recent = classes.values.toList()
        ..sort((a, b) => a.modifiedDate.compareTo(b.modifiedDate));

      if (recent.length > deleteRecentClassesAt) {
        final deleting = recent
            .take(recent.length - maxRecentClasses)
            .map((e) => e.delete())
            .toList();

        await Future.wait(deleting);
      }
    }

    return ChosenClassService(hive: hive, classes: classes);
  }
}