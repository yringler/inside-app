import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'siteSection.g.dart';

@JsonSerializable()
class SiteSection {
  final String ID;
  final String Title;
  final String Description;
  final List<String> Sections;
  final List<Lesson> Lessons;
  final bool IsTopLevel;

  SiteSection(this.ID,
      {this.Title,
      this.Description,
      this.Sections,
      this.Lessons,
      this.IsTopLevel});

  factory SiteSection.fromJson(Map<String, dynamic> json) =>
      _$SiteSectionFromJson(json);
}

@JsonSerializable()
class Media {
  final String Title;
  final String Source;

  Media(this.Source, [this.Title]);

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
}

@JsonSerializable()
class Lesson {
  final String Title;
  final String Description;
  final List<String> Audio;
  final List<Media> Pdf;

  Lesson(this.Title, this.Description, [this.Audio, this.Pdf]);
  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
}
