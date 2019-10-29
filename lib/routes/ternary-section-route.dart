import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/util/text-null-if-empty.dart';
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
          leadingWidget: textIfNotEmpty(section.description),
          sectionBuilder: (context, section) => InsideNavigator(
                data: section,
                child: _tile(section),
                routeName: TernarySectionRoute.routeName,
              ),
          lessonBuiler: (context, lesson) => _tile(lesson)));

  static Widget _tile(CountableInsideData data) {
    var itemWord = data.audioCount > 1 ? 'classes' : 'class';

    return ListTile(
      title: textIfNotEmpty(data.title, maxLines: 1),
      subtitle: textIfNotEmpty('${data.audioCount} $itemWord'),
      contentPadding: _listTilePadding(),
      trailing: Icon(Icons.arrow_forward_ios),
      dense: true,
    );
  }

  static EdgeInsets _listTilePadding() =>
      EdgeInsets.symmetric(horizontal: 8, vertical: 0);
}
