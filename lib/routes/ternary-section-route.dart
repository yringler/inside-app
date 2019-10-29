import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/routes/lesson-route/lesson-route.dart';
import 'package:inside_chassidus/widgets/inside-navigator.dart';
import 'package:inside_chassidus/widgets/inside-scaffold.dart';
import 'package:inside_chassidus/widgets/section-content-list.dart';

class TernarySectionRoute extends StatelessWidget {
  static const routeName = 'ternary-section';
  final SiteSection section;

  TernarySectionRoute({this.section});

  @override
  Widget build(BuildContext context) => InsideScaffold(
      insideData: section,
      body: SectionContentList(
          isSeperated: true,
          section: section,
          leadingWidget: _text(section.description),
          sectionBuilder: (context, section) => InsideNavigator(
                data: section,
                child: _tile(section),
                routeName: TernarySectionRoute.routeName,
              ),
          lessonBuiler: (context, lesson) => _tile(lesson)));

  Widget _tile(CountableInsideData data) {
    var itemWord = data.audioCount > 1 ? 'classes' : 'class';

    return ListTile(
      title: _text(data.title),
      subtitle: _text('${data.audioCount} $itemWord'),
      contentPadding: _listTilePadding(),
      trailing: Icon(Icons.arrow_forward),
      dense: true,
    );
  }

  Widget _text(String text) {
    if (text?.isNotEmpty ?? false) {
      return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    return null;
  }

  EdgeInsets _listTilePadding() =>
      EdgeInsets.symmetric(horizontal: 8, vertical: 0);
}
