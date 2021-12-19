import 'package:flutter/material.dart';
import 'package:inside_chassidus/routes/secondary-section-route/widgets/inside-data-card.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_chassidus/widgets/inside-navigator.dart';
import 'package:inside_chassidus/widgets/media-list/media-item.dart';
import 'package:inside_chassidus/widgets/section-content-list.dart';
import 'package:inside_data/inside_data.dart';

class SearchSectionRoute extends StatelessWidget {
  final List<ContentReference> content;
  final IRoutDataService routeDataService;

  const SearchSectionRoute(
      {required this.content, required this.routeDataService});

  @override
  Widget build(BuildContext context) => SectionContentList(
        content: content,
        sectionBuilder: (context, section) => InsideNavigator(
            data: section, child: InsideDataCard(insideData: section)),
        lessonBuilder: (context, lesson) => InsideDataCard(insideData: lesson),
        mediaBuilder: (context, media) => MediaItem(
          media: media,
          sectionId: null,
          routeDataService: routeDataService,
        ),
      );
}
