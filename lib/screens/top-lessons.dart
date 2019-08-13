import 'package:flutter/material.dart';
import 'package:inside_chassidus/widgets/inside-data-retriever.dart';

class TopLessons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: _title(context),
      ),
      body: Column(
        children: [_search(), _sections()],
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text("Inside Chassidus",
          style: Theme.of(context).appBarTheme.textTheme?.title ),
    );
  }

  Widget _search() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          decoration: InputDecoration(
              hintText: "Search", suffixIcon: Icon(Icons.search)),
        ));
  }

  Widget _sections() =>
    InsideDataRetriever(builder: (context, data) {
      return GridView.extent(
        maxCrossAxisExtent: 200,
        padding: const EdgeInsets.all(4),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: List.from(data.topLevel.map((topLevel) => Image.network(
              topLevel.image,
              scale: 1.0,
              repeat: ImageRepeat.noRepeat,
              fit: BoxFit.cover,
            ))),
      );
    });
}
