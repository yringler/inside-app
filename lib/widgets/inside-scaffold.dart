import 'package:flutter/material.dart';
import 'package:inside_api/models.dart';
import 'package:inside_chassidus/widgets/home-button.dart';
import 'package:inside_chassidus/widgets/media/audio-button-bar-aware-body.dart';
import 'package:inside_chassidus/widgets/media/current-media-button-bar.dart';

class InsideScaffold extends StatelessWidget {
  final SiteDataItem insideData;
  final Widget body;

  InsideScaffold({@required this.insideData, @required this.body});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(insideData.title,
            style: Theme.of(context).appBarTheme.textTheme?.title),
        actions: <Widget>[HomeButton()],
      ),
      body: AudioButtonbarAwareBody(body: body),
      bottomSheet: CurrentMediaButtonBar());
}
