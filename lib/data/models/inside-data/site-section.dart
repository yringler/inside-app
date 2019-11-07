import 'dart:core';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'index.dart';

part 'site-section.g.dart';

@HiveType()
@JsonSerializable(fieldRename: FieldRename.pascal)
class SiteSection extends InsideDataBase implements CountableInsideData {
  final LazyBox _sectionsBox = Hive.box("sections");
  final LazyBox _lessonBox = Hive.box("lessons");

  @HiveField(3)
  @JsonKey(name: "ID")
  final String id;

  @HiveField(4)
  @JsonKey(name: "Sections")
  final List<String> sectionIds;

  @HiveField(5)
  @JsonKey(name: "Lessons")
  final List<String> lessonIds;

  /// The number of lessons in this section.
  @HiveField(6)
  @override
  final int audioCount;

  Future<List<SiteSection>> getSections() async =>
      _getItems(sectionIds, _sectionsBox);

  Future<List<Lesson>> getLessons() async => _getItems(lessonIds, _lessonBox);

  Future<NestedContent> getContent() async {
    return NestedContent(
        lessons: await getLessons(), sections: await getSections());
  }

  SiteSection(
      {this.id,
      this.sectionIds,
      this.lessonIds,
      this.audioCount,
      String title,
      String description,
      List<String> pdf})
      : super(title: title, description: description, pdf: pdf);

  static Future<List<T>> _getItems<T>(List<String> ids, LazyBox box) async {
    final items = List<T>();

    for (var id in ids) {
      items.add(await box.get(id));
    }

    return items;
  }

  factory SiteSection.fromJson(Map<String, dynamic> json) =>
      _$SiteSectionFromJson(json);
}

/// The lessons and sections that a section contains.
class NestedContent {
  final List<Lesson> lessons;
  final List<SiteSection> sections;

  NestedContent({this.lessons, this.sections});
}
