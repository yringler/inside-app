import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/widgets/inside-scaffold.dart';
import 'package:inside_chassidus/widgets/media-list/index.dart';

/// Route to display all of the lessons for a given section.
class LessonScreen extends StatelessWidget {
  static const String routeName = "/lessons";

  final Lesson lesson;

  LessonScreen({this.lesson});

  @override
  Widget build(BuildContext context) => InsideScaffold(
      insideData: lesson,
      body: Row(children: <Widget>[
        if (lesson.description?.isNotEmpty) Text(lesson.description),
        MediaList(media: lesson.audio)
      ]));
}
