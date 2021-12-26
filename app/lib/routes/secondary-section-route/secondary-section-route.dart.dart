import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/routes/secondary-section-route/widgets/index.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_chassidus/widgets/inside-breadcrumbs.dart';
import 'package:inside_chassidus/widgets/inside-navigator.dart';
import 'package:inside_chassidus/widgets/media-list/media-item.dart';
import 'package:inside_chassidus/widgets/section-content-list.dart';
import 'package:inside_data/inside_data.dart';

/// Displays contents of a site section. All subsections and lessons.
class SecondarySectionRoute extends StatelessWidget {
  static const String routeName = "/library/sections";

  final Section section;

  SecondarySectionRoute({required this.section});

  @override
  Widget build(BuildContext context) => SectionContentList(
        leadingWidget: InsideBreadcrumbs(),
        section: section,
        sectionBuilder: (context, section) => InsideNavigator(
            data: section, child: InsideDataCard(insideData: section)),
        lessonBuilder: (context, lesson) => InsideDataCard(insideData: lesson),
        mediaBuilder: (context, media) => MediaItem(
          media: media,
          sectionId: section.id,
          routeDataService:
              BlocProvider.getDependency<LibraryPositionService>(),
        ),
      );
}
