import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/screens/lesson-screen/index.dart';
import 'package:inside_chassidus/screens/site-section/widgets/index.dart';
import 'package:inside_chassidus/widgets/inside-data-retriever.dart';
import 'package:inside_chassidus/widgets/inside-navigator.dart';
import 'package:inside_chassidus/widgets/inside-scaffold.dart';
import 'package:inside_chassidus/widgets/navigate-to-section.dart';

/// Displays contents of a site section. All subsections and lessons.
class SiteSectionScreen extends StatelessWidget {
  static const String routeName = "/sections";

  final SiteSection section;

  SiteSectionScreen({this.section});

  @override
  Widget build(BuildContext context) => InsideScaffold(
      insideData: section,
      body: InsideDataRetriever(builder: (context, data) {
        final sections = List<SiteSection>.from(data.getSections(section));
        final lessons = List<Lesson>.from(data.getLessons(section));

        return ListView.builder(
          itemCount: sections.length + lessons.length,
          itemBuilder: (context, i) {
            if (i < sections.length) {
              return NavigateToSection(
                  section: sections[i],
                  child: InsideDataCard(insideData: sections[i]));
            } else {
              int adjustedIndex = i - sections.length;
              final lesson = lessons[adjustedIndex];

              return InsideNavigator(
                child: InsideDataCard(insideData: lesson),
                routeName: LessonScreen.routeName, 
                data: lesson,
              );
            }
          },
        );
      }));
}
