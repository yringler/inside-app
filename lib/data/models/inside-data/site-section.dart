import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'index.dart';

part 'site-section.g.dart';

@HiveType()
@JsonSerializable(fieldRename: FieldRename.pascal)
class SiteSection implements CountableInsideData {
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

  @HiveField(0)
  @override
  String description;

  @HiveField(1)
  @override
  List<String> pdf;

  @HiveField(2)
  @override
  String title;

  Future<List<SiteSection>> getSections() async =>
      _getItems<SiteSection>(sectionIds, _sectionsBox);

  Future<List<Lesson>> getLessons() async =>
      _getItems<Lesson>(lessonIds, _lessonBox);

  Future<NestedContent> getContent() async {
    return NestedContent(
        lessons: await getLessons(), sections: await getSections());
  }

  SiteSection(
      {this.id,
      this.sectionIds,
      this.lessonIds,
      this.audioCount,
      this.title,
      this.description,
      List<String> pdf});

  /// Return what this section really is.
  /// If it contains only a single section, recursively evalute until resolved.
  /// If it contains only a single lesson, return it.
  Future<InsideDataBase> resolve() async {
    if (audioCount == 1) {
      if (lessonIds.isNotEmpty) {
        final lesson = (await getLessons())[0];
        return lesson.audio[0].resolve(lesson);
      }

      return (await getSections())[0].resolve();
    }

    if (sectionIds?.length == 1) {
      return (await getSections())[0].resolve();
    }

    if (sectionIds?.isNotEmpty ?? false) {
      var sections = await getSections();
      if (sections.every((section) => section.audioCount == 1)) {
        final audio = List<Media>();

        for (var section in sections) {
          final media = await section.resolve() as Media;
          audio.add(media);
        }

        return Lesson(audio: audio, description: description, title: title);
      }
    } else {
      var lessons = await getLessons();
      if (lessons.every((lesson) => lesson.audioCount == 1)) {
        final audio =
            List<Media>.from(lessons.map((lesson) => lesson.audio[0].resolve(lesson)));
        return Lesson(audio: audio, description: description, title: title);
      }
    }

    return this;
  }

  factory SiteSection.fromJson(Map<String, dynamic> json) =>
      _$SiteSectionFromJson(json);

  static Future<List<T>> _getItems<T extends CountableInsideData>(
      List<String> ids, LazyBox box) async {
    final items = List<T>();

    if (ids?.isEmpty ?? true) {
      return items;
    }

    for (var id in ids) {
      CountableInsideData item = await box.get(id);
      if (item.audioCount > 0) {
        items.add(item);
      }
    }

    return items;
  }
}

/// The lessons and sections that a section contains.
class NestedContent {
  final List<Lesson> lessons;
  final List<SiteSection> sections;

  NestedContent({this.lessons, this.sections});
}
