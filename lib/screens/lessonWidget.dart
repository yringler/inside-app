import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/siteSection.dart';

class LessonWidget extends StatelessWidget {
  final Lesson _lesson;

  LessonWidget(this._lesson);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(_lesson.Title, textScaleFactor: 1.2,),
      if (_lesson.Audio != null)
        for (var audio in _lesson.Audio)
          Text("For audio:" + audio)
      ],);
  }
}
