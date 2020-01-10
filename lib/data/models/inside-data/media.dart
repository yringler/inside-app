import 'dart:core';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'index.dart';

part 'media.g.dart';

@HiveType(typeId: 4)
@JsonSerializable(fieldRename: FieldRename.pascal)
class Media implements InsideDataBase {
  @HiveField(3)
  final String source;

  @HiveField(5)
  String lessonId;

  Future<Lesson> getLesson() async {
    final Lesson lesson = await Hive.lazyBox<Lesson>('lessons').get(lessonId);
    return lesson;
  }

  Media({this.source, this.title, this.description, this.lessonId, this.pdf});

  @HiveField(0)
  @override
  String description;

  @HiveField(1)
  @override
  List<String> pdf;

  @HiveField(2)
  @override
  String title;

  Duration get duration {
    return _milliseconds != null ? Duration(milliseconds: _milliseconds) : null;
  }

  set duration(Duration d) => _milliseconds = d?.inMilliseconds;

  @HiveField(4)
  int _milliseconds;

  /// Returns a media item which is self standing; if it doesn't have its own title, use title of the lesson.
  Media resolve(Lesson lesson) {
    final title = (this.title?.isEmpty ?? true) ? lesson.title : this.title;
    final description = (this.description?.isEmpty ?? true)
        ? lesson.description
        : this.description;
    return copyWith(title: title, description: description);
  }

  Media copyWith(
          {String source,
          String title,
          String description,
          String lessonId,
          List<String> pdf,
          Duration duration}) =>
      Media(
          source: source ?? this.source,
          description: description ?? this.description,
          title: title ?? this.title,
          lessonId: lessonId ?? this.lessonId,
          pdf: pdf ?? this.pdf)
        ..duration = duration ?? this.duration;

  bool operator ==(dynamic other) => other is Media && other.source == source;

  int get hashCode => source.hashCode;

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
}
