import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/siteSection.dart';

class LessonWidget extends StatelessWidget {
  final Lesson _lesson;

  LessonWidget(this._lesson);

  @override
  Widget build(BuildContext context) {
    return Text(_lesson.Title);
  }
}
