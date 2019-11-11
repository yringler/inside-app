import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:inside_chassidus/routes/lesson-route/lesson-route.dart';
import 'package:inside_chassidus/widgets/inside-navigator.dart';
import 'package:inside_chassidus/widgets/media-list/media-list.dart';

typedef Widget InsideDataBuilder<T extends InsideDataBase>(
    BuildContext context, T data);

/// Given a section, provides simple way to build a list of it's sections
/// and lessons.
class SectionContentList extends StatelessWidget {
  final bool isSeperated;
  final SiteSection section;
  final InsideDataBuilder<SiteSection> sectionBuilder;
  final InsideDataBuilder<Lesson> lessonBuiler;
  final InsideDataBuilder<Media> mediaBuilder;

  /// A widget to go before other items in the list.
  final Widget leadingWidget;

  /// If there is a leading widget, index is 1 too many.
  int get indexOffset => leadingWidget == null ? 0 : 1;

  SectionContentList(
      {@required this.section,
      @required this.sectionBuilder,
      @required this.lessonBuiler,
      this.mediaBuilder,
      this.isSeperated = false,
      this.leadingWidget});

  @override
  Widget build(BuildContext context) => _sectionsFuture(context);

  Widget _sectionsFuture(BuildContext context) => FutureBuilder(
        future: section.resolve(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data is SiteSection) {
              return FutureBuilder<NestedContent>(
                future: snapshot.data.getContent(),
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
            } else {
              final lesson = snapshot.data as Lesson;
              return MediaList(media: lesson.audio);
            }
          }

          return Container();
        },
      );

  Widget _sections(BuildContext context, NestedContent content) {
    final itemCount =
        content.sections.length + content.lessons.length + indexOffset;

    return FutureBuilder<List<InsideDataBase>>(
      future: _getResolvedData(content),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (isSeperated) {
            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: itemCount,
              itemBuilder: _builder(content, snapshot.data, indexOffset),
              separatorBuilder: (context, i) => Divider(),
            );
          } else {
            return ListView.builder(
              itemCount: itemCount,
              itemBuilder: _builder(content, snapshot.data, indexOffset),
            );
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<List<InsideDataBase>> _getResolvedData(NestedContent content) async {
    var data = List<InsideDataBase>();

    for (var section in content.sections) {
      data.add(await section.resolve());
    }

    data.addAll(content.lessons);

    return data;
  }

  IndexedWidgetBuilder _builder(NestedContent content,
          List<InsideDataBase> dataList, int indexOffset) =>
      (BuildContext context, int i) {
        if (i == 0 && leadingWidget != null) {
          return leadingWidget;
        }

        i -= indexOffset;

        if (i < content.sections.length) {
          final dataItem = dataList[i];
          if (dataItem is SiteSection) {
            return sectionBuilder(context, dataItem);
          } else if (dataItem is Lesson) {
            return _lessonNavigator(context, dataItem);
          } else if (dataItem is Media) {
            if (mediaBuilder != null) {
              return mediaBuilder(context, dataItem);
            }
          }
          return sectionBuilder(context, content.sections[i]);
        } else {
          final adjustedIndex = i - content.sections.length;
          final lesson = content.lessons[adjustedIndex];

          return _lessonNavigator(context, lesson);
        }
      };

  _lessonNavigator(BuildContext context, Lesson lesson) {
    if (lesson.audioCount == 1 && mediaBuilder != null) {
      return mediaBuilder(
          context, Media(title: lesson.title, source: lesson.audio[0].source));
    }

    return InsideNavigator(
      child: lessonBuiler(context, lesson),
      routeName: LessonRoute.routeName,
      data: lesson,
    );
  }
}
