import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/models/app-data.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:inside_chassidus/widgets/navigate-to-section.dart';

class PrimarySectionsRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: _title(context),
        ),
        body: Column(
          children: [_sectionsFuture(context)],
        ),
      );

  Widget _title(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text("Inside Chassidus",
            style: Theme.of(context).appBarTheme.textTheme?.title),
      );

  Widget _search() => Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        decoration:
            InputDecoration(hintText: "Search", suffixIcon: Icon(Icons.search)),
      ));

  Widget _sectionsFuture(BuildContext context) => Expanded(
        child: FutureBuilder<List<PrimaryInside>>(
          future: BlocProvider.getDependency<AppData>().getPrimaryInside(),
          builder: (context, snapShot) {
            if (snapShot.hasData) {
              return _sections(context, snapShot.data);
            } else if (snapShot.hasError) {
              return ErrorWidget(snapShot.error);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      );

  Widget _sections(BuildContext context, List<PrimaryInside> topLevel) => GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(4),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: [
            for (var topItem in topLevel) _primarySection(topItem, context)
          ]);

  Widget _primarySection(PrimaryInside primaryInside, BuildContext context) =>
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3)),
          ],
        ),
      );
}
