import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/widgets/navigate-to-section.dart';
import 'package:inside_data_flutter/inside_data_flutter.dart';

class PrimarySectionRoute extends StatelessWidget {
  static const String routeName = '/library';

  @override
  Widget build(BuildContext context) {
    final layer = BlocProvider.getDependency<SiteDataLayer>();
    return FutureBuilder<List<Section>>(
        future: layer.topLevel(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return _sections(context, snapshot.data!, layer);
        });
  }

  Widget _sections(BuildContext context, List<Section> topLevel,
          SiteDataLayer dataLayer) =>
      GridView.extent(
          maxCrossAxisExtent: 200,
          padding: const EdgeInsets.all(4),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: [
            for (var topItem in topLevel)
              _primarySection(dataLayer, topItem, context)
          ]);

  Widget _primarySection(
      SiteDataLayer dataLayer, Section primaryInside, BuildContext context) {
    final image = dataLayer.getImageFor(primaryInside.id);
    return NavigateToSection(
      section: primaryInside,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.bottomLeft,
        children: <Widget>[
          if (image != null)
            CachedNetworkImage(
                imageUrl: image,
                repeat: ImageRepeat.noRepeat,
                fit: BoxFit.cover,
                height: 500,
                width: 500,
                color: Colors.black54,
                colorBlendMode: BlendMode.darken),
          Container(
              padding: EdgeInsets.fromLTRB(8, 0, 0, 8),
              child: Text(primaryInside.title.toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: Theme.of(context).textTheme.headline6!.fontSize,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3)),
        ],
      ),
    );
  }
}
