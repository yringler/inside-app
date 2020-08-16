import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inside_api/models.dart';
import 'package:inside_api/site-service.dart';
import 'package:inside_chassidus/widgets/navigate-to-section.dart';

class PrimarySectionsRoute extends StatelessWidget {
  static const String routeName = '/library';

  @override
  Widget build(BuildContext context) => _sections(context,
      BlocProvider.getDependency<SiteBoxes>().topItems.values.toList());

  Widget _sections(
          BuildContext context, List<TopItem> topLevel) =>
      GridView.extent(
          maxCrossAxisExtent: 200,
          padding: const EdgeInsets.all(4),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: [
            for (var topItem in topLevel) _primarySection(topItem, context)
          ]);

  Widget _primarySection(TopItem primaryInside, BuildContext context) =>
      NavigateToSection(
        section: primaryInside.section,
        child: Stack(
          overflow: Overflow.clip,
          alignment: Alignment.bottomLeft,
          children: <Widget>[
            CachedNetworkImage(
                imageUrl: primaryInside.image,
                repeat: ImageRepeat.noRepeat,
                fit: BoxFit.cover,
                height: 500,
                width: 500,
                color: Colors.black54,
                colorBlendMode: BlendMode.darken),
            Container(
                padding: EdgeInsets.fromLTRB(8, 0, 0, 8),
                child: Text(primaryInside.section.title.toUpperCase(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            Theme.of(context).textTheme.headline6.fontSize,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3)),
          ],
        ),
      );
}
