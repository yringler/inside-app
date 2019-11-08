import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';

class InsideScaffold extends StatelessWidget {
  final InsideDataBase insideData;
  final Widget body;

  InsideScaffold({@required this.insideData, @required this.body});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(insideData.title,
                style: Theme.of(context).appBarTheme.textTheme?.title)),
                body: body
      );
}
