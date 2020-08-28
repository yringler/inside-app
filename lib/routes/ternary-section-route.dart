import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb_menu/flutter_breadcrumb_menu.dart';
import 'package:inside_api/models.dart';
import 'package:inside_chassidus/util/text-null-if-empty.dart';
import 'package:inside_chassidus/widgets/inside-navigator.dart';
import 'package:inside_chassidus/widgets/media-list/media-item.dart';
import 'package:inside_chassidus/widgets/section-content-list.dart';

class TernarySectionRoute extends StatelessWidget {
  static const routeName = '/library/ternary-section';
  final Section section;
  final List<Bread> breads;

  TernarySectionRoute({@required this.section, @required this.breads});

  @override
  Widget build(BuildContext context) => SectionContentList(
      isSeperated: true,
      section: section,
      leadingWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Breadcrumb(breads: breads),
          if (section.description?.isNotEmpty ?? false)
            textIfNotEmpty(section.description)
        ],
      ),
      sectionBuilder: (context, section) => InsideNavigator(
            data: section,
            child: section.title == breads.last.label ? null : _tile(section),
            routeName: TernarySectionRoute.routeName,
          ),
      lessonBuilder: (context, lesson) => _tile(lesson),
      mediaBuilder: (context, media) => MediaItem(
            media: media,
            sectionId: section.id,
          ));

  static Widget _tile(CountableSiteDataItem data) {
    var itemWord = data.audioCount > 1 ? 'classes' : 'class';

    return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4),
        title: textIfNotEmpty(data.title, maxLines: 1),
        subtitle: textIfNotEmpty('${data.audioCount} $itemWord'),
        trailing: Icon(Icons.arrow_forward_ios));
  }
}
