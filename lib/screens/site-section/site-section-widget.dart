import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
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
                      _sectionOrLesson(subSection, context),
                    for (var lesson in data.getLessons(section))
                      _sectionOrLesson(lesson, context)
                  ],
                ),
              )));

  Widget _sectionOrLesson(CountableInsideData section, BuildContext context) => Card(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          _title(section, context),
          if ((section.description?.length ?? 0) > 0) _description(section)
        ],
      ));

  Widget _title(CountableInsideData section, BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "${section.audioCount} classes",
        ),
        Text(section.title, style: Theme.of(context).textTheme.title)
      ]);

  Widget _description(InsideDataBase data) => ExpandableNotifier(
        child: Column(
          children: [
            ScrollOnExpand(
              child: Expandable(
                  collapsed: Column(
                    children: [
                      Text(
                        data.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      ExpandableButton(
                          child: ButtonBar(
                        alignment: MainAxisAlignment.start,
                        children: [Text("See more")],
                      ))
                    ],
                  ),
                  expanded: Text(data.description)),
            ),
          ],
        ),
      );
}
