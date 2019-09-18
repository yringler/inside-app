import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/screens/site-section/site-section-widget.dart';
import 'package:inside_chassidus/widgets/inside-data-retriever.dart';
import 'package:inside_chassidus/widgets/navigate-to-section.dart';

class TopLessons extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: _title(context),
        ),
        body: Column(
          children: [_search(), _sections(context)],
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

  Widget _sections(BuildContext context) => Expanded(
      child: InsideDataRetriever(
          builder: (context, data) => GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(4),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: [
                    for (var topItem in data.topLevel)
                      _primarySection(topItem, context)
                  ])));

  Widget _primarySection(PrimaryInside primaryInside, BuildContext context) =>
      NavigateToSection(
        section: primaryInside.section,
        child: Stack(
          overflow: Overflow.clip,
          alignment: Alignment.bottomLeft,
          children: <Widget>[
            Image.network(
              primaryInside.image,
              scale: 1.0,
              repeat: ImageRepeat.noRepeat,
              fit: BoxFit.cover,
              height: 500,
              width: 500,
              color: Colors.black54,
              colorBlendMode: BlendMode.darken,
            ),
            Container(
                padding: EdgeInsets.fromLTRB(8, 0, 0, 8),
                child: Text(primaryInside.section.title.toUpperCase(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.clip,
                    maxLines: 1)),
          ],
        ),
      );
}
