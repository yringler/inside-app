import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';

typedef InsideDataWidgetBuilder = Widget Function(
    BuildContext context, InsideData insideData);

/// When lesson data is available, calls build method with it. Untill then, renders a loading widget.
class InsideDataRetriever extends StatelessWidget {
  static InsideData _insideData;

  final InsideDataWidgetBuilder builder;

  InsideDataRetriever({this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<InsideData>(
      future: _getData(context),
      builder: (context, snapShot) {
        debugPrint("hasData: " + snapShot.hasData.toString());

        if (snapShot.hasData) {
          return builder(context, snapShot.data);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future<InsideData> _getData(BuildContext context) async {
    if (_insideData != null) {
      return _insideData;
    }

    var json =
        await DefaultAssetBundle.of(context).loadString("assets/data.json");
    _insideData = InsideData.fromJson(jsonDecode(json));
    return _insideData;
  }
}
