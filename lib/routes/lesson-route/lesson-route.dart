import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/widgets/inside-scaffold.dart';
import 'package:inside_chassidus/widgets/media-list/index.dart';

/// Route to display all of the lessons for a given section.
class LessonRoute extends StatelessWidget {
  static const String routeName = "/lessons";

  final Lesson lesson;

  LessonRoute({this.lesson});

  @override
  Widget build(BuildContext context) => InsideScaffold(
      insideData: lesson,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8).copyWith(top: 8),
        child: Column(children: <Widget>[
          if (lesson.description?.isNotEmpty) Text(lesson.description),
          MediaList(media: lesson.audio)
        ]),
      ));
}