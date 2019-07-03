import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/siteSection.dart';

import 'lessonWidget.dart';

class LessonNavigator extends StatelessWidget {
  final Map<String, SiteSection> _sections;
  final String _currentSection;

  LessonNavigator([this._sections, this._currentSection]);

  @override
  Widget build(BuildContext context) {
    if (_sections == null) {
      return _futureNavigator(context);
    }

    List<SiteSection> sections;

    var currentSection = _sections[_currentSection];

    if (currentSection != null) {
      sections = currentSection.Sections?.map((id) => _sections[id]);
    } else {
      sections = _sections.values.where((section) => section.IsTopLevel);
    }

    bool hasLessons = currentSection?.Lessons?.isNotEmpty;

    return Column(
      children: [
        if (currentSection != null) _sectionHeading(currentSection),
        ListView(children: [
          for (var section in sections) _sectionTile(section, context),
          if (hasLessons) Divider(),
          for (var lesson in currentSection?.Lessons)
            _lessonTile(lesson, context)
        ]),
      ],
    );
  }

  Future<Map<String, SiteSection>> _getSiteSections(
      BuildContext context) async {
    String json =
        await DefaultAssetBundle.of(context).loadString("assets/data.json");

    Map<String, Map<String, dynamic>> rawJsonOut = jsonDecode(json);
    return rawJsonOut.map<String, SiteSection>((key, value) =>
        MapEntry<String, SiteSection>(key, SiteSection.fromJson(value)));
  }

  Widget _lessonTile(Lesson lesson, BuildContext context) {
    return ListTile(
      title: Text(lesson.Title),
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => LessonWidget(lesson))),
    );
  }

  Widget _sectionHeading(SiteSection section) {
    return Column(
        children: [Text(section.Title), Text(section.Description), Divider()]);
  }

  Widget _futureNavigator(BuildContext context) =>
      FutureBuilder<Map<String, SiteSection>>(
          future: _getSiteSections(context),
          builder: (context, snapShot) {
            if (!snapShot.hasData) {
              return CircularProgressIndicator();
            }

            return LessonNavigator(snapShot.data, _currentSection);
          });

  Widget _sectionTile(SiteSection section, BuildContext context) => ListTile(
        title: Text(section.Title),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LessonNavigator(_sections, section.ID))),
      );
}
