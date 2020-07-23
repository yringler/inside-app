import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_api/models.dart';
import 'package:inside_api/site-service.dart';
import 'package:inside_chassidus/routes/lesson-route/lesson-route.dart';
import 'package:inside_chassidus/widgets/inside-navigator.dart';
import 'package:inside_chassidus/widgets/media-list/media-list.dart';

typedef Widget InsideDataBuilder<T extends SiteDataItem>(
    BuildContext context, T data);

/// Given a section, provides simple way to build a list of it's sections
/// and lessons.
class SectionContentList extends StatelessWidget {
  final bool isSeperated;
  final Section section;
  final InsideDataBuilder<Section> sectionBuilder;
  final InsideDataBuilder<MediaSection> lessonBuiler;
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
  Widget build(BuildContext context) => FutureBuilder(
        future: BlocProvider.getDependency<SiteBoxes>().resolve(section),
        builder: (context, snapShot) {
          if (snapShot.hasData) {
            if (isSeperated) {
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 8),
                itemCount: section.content.length,
                itemBuilder: _sectionContent(),
                separatorBuilder: (context, i) => Divider(),
              );
            } else {
              return ListView.builder(
                itemCount: section.content.length,
                itemBuilder: _sectionContent(),
              );
            }
          } else if (snapShot.hasError) {
            return ErrorWidget(snapShot.error);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );

  IndexedWidgetBuilder _sectionContent() => (BuildContext context, int i) {
        if (i == 0 && leadingWidget != null) {
          return leadingWidget;
        }

        i -= indexOffset;

        final dataItem = section.content[i];
        if (dataItem.section != null) {
          return sectionBuilder(context, dataItem.section);
        } else if (dataItem.mediaSection != null) {
          return _lessonNavigator(context, dataItem.mediaSection);
        } else if (dataItem.media != null) {
          if (mediaBuilder != null) {
            return mediaBuilder(context, dataItem.media);
          }
        }
        throw 'Error: item contained no data';
      };

  _lessonNavigator(BuildContext context, MediaSection lesson) {
    if (lesson.audioCount == 1 && mediaBuilder != null) {
      return mediaBuilder(context, lesson.media[0]);
    }

    return InsideNavigator(
      child: lessonBuiler(context, lesson),
      routeName: LessonRoute.routeName,
      data: lesson,
    );
  }
}
