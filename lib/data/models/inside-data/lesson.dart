import 'dart:core';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'index.dart';

part 'lesson.g.dart';

@HiveType()
@JsonSerializable(fieldRename: FieldRename.pascal)
class Lesson extends InsideDataBase implements CountableInsideData {
  @HiveField(3)
  @JsonKey(name: "ID")
  final String id;

  @HiveField(4)
  final List<Media> audio;

  Lesson(
      {this.id, this.audio, String title, String description, List<String> pdf})
      : super(title: title, description: description, pdf: pdf);

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);

  @override
  int get audioCount => audio?.length ?? 0;
}
