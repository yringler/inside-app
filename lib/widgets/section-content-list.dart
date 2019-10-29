import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/routes/lesson-route/lesson-route.dart';
import 'package:inside_chassidus/widgets/inside-data-retriever.dart';
import 'package:inside_chassidus/widgets/inside-navigator.dart';

typedef Widget InsideDataBuilder<T extends InsideDataBase>(
    BuildContext context, T data);

/// Given a section, provides simple way to build a list of it's sections
/// and lessons.
class SectionContentList extends StatelessWidget {
  final bool isSeperated;
  final SiteSection section;
  final InsideDataBuilder<SiteSection> sectionBuilder;
  final InsideDataBuilder<Lesson> lessonBuiler;

  /// A widget to go before other items in the list.
  final Widget leadingWidget;

  SectionContentList(
      {@required this.section,
      @required this.sectionBuilder,
      @required this.lessonBuiler,
      this.isSeperated = false,
      this.leadingWidget});

  @override
  Widget build(BuildContext context) =>
      InsideDataRetriever(builder: (context, data) {
        final sections = List<SiteSection>.from(data.getSections(section));
        final lessons = List<Lesson>.from(data.getLessons(section));
        // If there is a leading widget, index is 1 too many.
        final indexOffset = leadingWidget == null ? 0 : 1;
        final itemBuilder = (BuildContext context, int i) {
          if (i == 0 && leadingWidget != null) {
            return leadingWidget;
          }

          i -= indexOffset;

          if (i < sections.length) {
            return sectionBuilder(context, sections[i]);
          } else {
            final adjustedIndex = i - sections.length;
            final lesson = lessons[adjustedIndex];

            return InsideNavigator(
              child: lessonBuiler(context, lesson),
              routeName: LessonRoute.routeName,
              data: lesson,
            );
          }
        };

        final itemCount =  sections.length + lessons.length + indexOffset;

        if (isSeperated) {
          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 8),
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            separatorBuilder: (context, i) => Divider(),
          );
        } else {
          return ListView.builder(
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          );
        }
      });
}
