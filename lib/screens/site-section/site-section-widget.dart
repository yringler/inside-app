import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/screens/site-section/widgets/index.dart';
import 'package:inside_chassidus/widgets/inside-data-retriever.dart';
import 'package:inside_chassidus/widgets/navigate-to-section.dart';

/// Displays contents of a site section. All subsections and lessons.
class SiteSectionWidget extends StatelessWidget {
  static const String routeName = "/sections";

  final SiteSection section;

  SiteSectionWidget({this.section});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: Text(section.title,
              style: Theme.of(context).appBarTheme.textTheme?.title)),
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
              return InsideDataCard(insideData: lessons[adjustedIndex]);
            }
          },
        );
      }));
}
