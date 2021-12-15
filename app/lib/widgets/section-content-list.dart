import 'package:flutter/material.dart';
import 'package:inside_data/inside_data.dart';

typedef Widget InsideDataBuilder<T extends SiteDataBase>(
    BuildContext context, T data);

/// Given a section, provides simple way to build a list of it's sections
/// and lessons.
class SectionContentList extends StatelessWidget {
  final bool isSeperated;
  final Section section;
  final InsideDataBuilder<Section> sectionBuilder;
  final InsideDataBuilder<Section> lessonBuilder;
  final InsideDataBuilder<Media>? mediaBuilder;

  /// A widget to go before other items in the list.
  final Widget? leadingWidget;

  /// If there is a leading widget, index is 1 too many.
  int get indexOffset => leadingWidget == null ? 0 : 1;

  SectionContentList(
      {required this.section,
      required this.sectionBuilder,
      required this.lessonBuilder,
      required this.mediaBuilder,
      this.isSeperated = false,
      this.leadingWidget});

  @override
  Widget build(BuildContext context) => FutureBuilder<List<ContentReference>>(
        // TODO: implement navigation optimization again - eg, navigating to section with one class should navigate to class.
        // Could be this isn't the place to implement it - maybe in router.
        future: Future.value(_withContent(section.content)),
        builder: (context, snapShot) {
          if (snapShot.hasData && snapShot.data != null) {
            if (isSeperated) {
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 8),
                itemCount: snapShot.data!.length + indexOffset,
                itemBuilder: _sectionContent(snapShot.data!),
                separatorBuilder: (context, i) => Divider(),
              );
            } else {
              return ListView.builder(
                itemCount: snapShot.data!.length + indexOffset,
                itemBuilder: _sectionContent(snapShot.data!),
              );
            }
          } else if (snapShot.hasError) {
            return ErrorWidget(snapShot.error!);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );

  IndexedWidgetBuilder _sectionContent(List<ContentReference> content) =>
      (BuildContext context, int i) {
        if (i == 0 && leadingWidget != null) {
          return leadingWidget!;
        }

        i -= indexOffset;

        final dataItem = content[i];
        if (dataItem.section != null) {
          return sectionBuilder(context, dataItem.section!);

          // TODO: consider if to remove lesson navigator (used to mean section with just lessons)
          // now that there are only sections.
          // if (dataItem.section!.content.every((element) => element.isMedia)) {
          //   return _lessonNavigator(context, dataItem.section!);
          // } else {
          //   return sectionBuilder(context, dataItem.section!);
          // }
        } else if (dataItem.media != null && mediaBuilder != null) {
          return mediaBuilder!(context, dataItem.media!);
        }
        throw 'Error: item contained no data';
      };

  /// Only return content with audio children.
  /// TODO: Optimization (not showing empty content, skipping through sections which have only a single content etc) has to be done better.
  List<ContentReference> _withContent(List<ContentReference> contents) =>
      contents
          .where((element) =>
              (element.hasMedia && element.media!.source.isNotEmpty) ||
              (element.hasSection && element.section!.audioCount > 0))
          .toList();

  // _lessonNavigator(BuildContext context, Section lesson) {
  //   if (lesson.audioCount == 1 && mediaBuilder != null) {
  //     return mediaBuilder!(context, lesson.content.map((e) => e.media).first!);
  //   }

  //   return InsideNavigator(
  //     child: lessonBuilder(context, lesson),
  //     data: lesson,
  //   );
  // }
}
