import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_api/models.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_chassidus/util/text-null-if-empty.dart';
import 'package:inside_chassidus/widgets/inside-breadcrumbs.dart';
import 'package:inside_chassidus/widgets/media-list/index.dart';

/// Route to display all of the lessons for a given section.
class LessonRoute extends StatelessWidget {
  static const String routeName = "/library/lessons";

  final MediaSection lesson;

  LessonRoute({this.lesson});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 8).copyWith(top: 8),
        child: MediaList(
          routeDataService:
              BlocProvider.getDependency<LibraryPositionService>(),
          media: lesson.media,
          sectionId: lesson.parentId,
          leadingWidget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InsideBreadcrumbs(),
              if (lesson.description?.isNotEmpty ?? false)
                textIfNotEmpty(lesson.description)
            ],
          ),
        ),
      );
}
