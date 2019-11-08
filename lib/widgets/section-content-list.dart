import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:inside_chassidus/routes/lesson-route/lesson-route.dart';
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

  /// If there is a leading widget, index is 1 too many.
  int get indexOffset => leadingWidget == null ? 0 : 1;

  SectionContentList(
      {@required this.section,
      @required this.sectionBuilder,
      @required this.lessonBuiler,
      this.isSeperated = false,
      this.leadingWidget});

  @override
  Widget build(BuildContext context) => _sectionsFuture(context);

  Widget _sectionsFuture(BuildContext context) => FutureBuilder<NestedContent>(
        future: section.getContent(),
        builder: (context, snapShot) {
          if (snapShot.hasData) {
            return _sections(context, snapShot.data);
          } else if (snapShot.hasError) {
            return ErrorWidget(snapShot.error);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );

  Widget _sections(BuildContext context, NestedContent content) {
    final itemCount =
        content.sections.length + content.lessons.length + indexOffset;

    if (isSeperated) {
      return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 8),
        itemCount: itemCount,
        itemBuilder: _builder(content, indexOffset),
        separatorBuilder: (context, i) => Divider(),
      );
    } else {
      return ListView.builder(
        itemCount: itemCount,
        itemBuilder: _builder(content, indexOffset),
      );
    }
  }

  IndexedWidgetBuilder _builder(NestedContent content, int indexOffset) =>
      (BuildContext context, int i) {
        if (i == 0 && leadingWidget != null) {
          return leadingWidget;
        }

        i -= indexOffset;

        if (i < content.sections.length) {
          return sectionBuilder(context, content.sections[i]);
        } else {
          final adjustedIndex = i - content.sections.length;
          final lesson = content.lessons[adjustedIndex];

          return InsideNavigator(
            child: lessonBuiler(context, lesson),
            routeName: LessonRoute.routeName,
            data: lesson,
          );
        }
      };
}
