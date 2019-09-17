import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/screens/site-section/widgets/index.dart';
import 'package:inside_chassidus/widgets/inside-data-retriever.dart';

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
      body: InsideDataRetriever(
          builder: (context, data) => SingleChildScrollView(
                child: Column(
                  children: [
                    for (var subSection in data.getSections(section))
                      InsideDataCard(insideData: subSection),
                    for (var lesson in data.getLessons(section))
                      InsideDataCard(insideData: lesson)
                  ],
                ),
              )));
}
