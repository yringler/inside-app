import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'insideData.g.dart';

// Some basic information which many inside data objects have.
abstract class InsideDataBase {
  final String title;
  final String description;
  final List<String> pdf;

  InsideDataBase({this.title, this.description, this.pdf});
}

/// All data about inside chassidus content.
@JsonSerializable(fieldRename: FieldRename.pascal)
class InsideData {
  Map<String, SiteSection> sections;
  Map<String, Lesson> lessons;
  List<PrimaryInside> topLevel;

  InsideData(this.sections, this.lessons, this.topLevel);

  factory InsideData.fromJson(Map<String, dynamic> json) {
    var insideData = _$InsideDataFromJson(json);
    insideData.topLevel
        .forEach((item) => item.section = insideData.sections[item.id]);
    return insideData;
  }

  /// Returns subsections of the given section.
  Iterable<SiteSection> getSections(SiteSection section) sync* {
    if (section?.sectionIds?.isEmpty ?? true) {
      return;
    }

    for (var childId in section.sectionIds) {
      yield sections[childId];
    }
  }

  /// Returns all lessons of given section.
  Iterable<Lesson> getLessons(SiteSection section) sync* {
    if (section?.lessonIds?.isEmpty ?? true) {
      return;
    }

    for (var lessonId in section.lessonIds) {
      yield lessons[lessonId];
    }
  }
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class PrimaryInside {
  final String id;
  final String image;

  @JsonKey(ignore: true)
  SiteSection section;

  PrimaryInside({this.id, this.image});

  factory PrimaryInside.fromJson(Map<String, dynamic> json) =>
      _$PrimaryInsideFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class SiteSection extends InsideDataBase {
  final String id;
  @JsonKey(name: "Sections")
  final List<String> sectionIds;
  @JsonKey(name: "Lessons")
  final List<String> lessonIds;

  SiteSection(
      {this.id,
      this.sectionIds,
      this.lessonIds,
      String title,
      String description,
      List<String> pdf})
      : super(title: title, description: description, pdf: pdf);

  factory SiteSection.fromJson(Map<String, dynamic> json) =>
      _$SiteSectionFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Lesson extends InsideDataBase {
  final String id;
  final List<Media> audio;

  Lesson(
      {this.id, this.audio, String title, String description, List<String> pdf})
      : super(title: title, description: description, pdf: pdf);

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Media extends InsideDataBase {
  String source;

  Media({this.source, String title, String description, List<String> pdf})
      : super(title: title, description: description, pdf: pdf);

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
}
