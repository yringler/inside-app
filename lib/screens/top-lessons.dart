import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/widgets/inside-data-retriever.dart';

class TopLessons extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: _title(context),
        ),
        body: Column(
          children: [_search(), _sections()],
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

  Widget _sections() => Expanded(
      child: InsideDataRetriever(
          builder: (context, data) => GridView.extent(
                  maxCrossAxisExtent: 200,
                  padding: const EdgeInsets.all(4),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: [
                    for (var topItem in data.topLevel) _primarySection(topItem)
                  ])));

  Widget _primarySection(PrimaryInside primaryInside) => Image.network(
        primaryInside.image,
        scale: 1.0,
        repeat: ImageRepeat.noRepeat,
        fit: BoxFit.cover,
        height: 50,
        width: 50,
      );
}
