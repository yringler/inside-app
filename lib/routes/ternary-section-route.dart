import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/routes/lesson-route/lesson-route.dart';
import 'package:inside_chassidus/widgets/inside-navigator.dart';
import 'package:inside_chassidus/widgets/inside-scaffold.dart';
import 'package:inside_chassidus/widgets/section-content-list.dart';

class TernarySectionRoute extends StatelessWidget {
  static const routeName = 'ternary-section';
  final SiteSection section;

  TernarySectionRoute({this.section});

  @override
  Widget build(BuildContext context) => InsideScaffold(
      insideData: section,
      body: SectionContentList(
          isSeperated: true,
          section: section,
          sectionBuilder: (context, section) => InsideNavigator(
                data: section,
                child: ListTile(title: Text(section.title), contentPadding: _listTilePadding()),
                routeName: TernarySectionRoute.routeName,
              ),
          lessonBuiler: (context, lesson) => InsideNavigator(
                data: lesson,
                routeName: LessonRoute.routeName,
                child: ListTile(
                  title: Text(lesson.title),
                  contentPadding: _listTilePadding()
                ),
              )));

    EdgeInsets _listTilePadding() => EdgeInsets.symmetric(horizontal: 8, vertical: 0);
}
