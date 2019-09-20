import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/screens/site-section/widgets/informative-text-painter.dart';

class InsideDataCard extends StatefulWidget {
  final CountableInsideData insideData;

  InsideDataCard({this.insideData});

  @override
  State<StatefulWidget> createState() => _InsideDataCardData();
}

class _InsideDataCardData extends State<InsideDataCard> {
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        return Card(
            margin: EdgeInsets.all(8),
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _title(context),
                  if (widget.insideData.description?.trim()?.isNotEmpty ??
                      false)
                    _description()
                ],
              ),
            ));
      });

  Widget _title(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "${widget.insideData.audioCount} classes",
          style:
              Theme.of(context).textTheme.body1.merge(TextStyle(fontSize: 12)),
        ),
        Text(widget.insideData.title.trim(),
            style: Theme.of(context).textTheme.title)
      ]);

  Widget _description() => LayoutBuilder(builder: (context, constraints) {
        final descriptionPainter = InformativeTextPainter(
            widget.insideData.description.trim(),
            maxLines: 3,
            maxWidth: constraints.maxWidth,
            style: Theme.of(context).textTheme.body1);

        if (descriptionPainter.willOverflow())
          return _expandableDescription(context, descriptionPainter);
        else
          return Container(
              margin: EdgeInsets.only(top: 7),
              child: descriptionPainter.getPaint());
      });

  Widget _expandableDescription(
      BuildContext context, InformativeTextPainter descriptionPainter) {
    return ExpandableNotifier(
      child: ScrollOnExpand(
          child: Expandable(
              collapsed: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 7),
                      child: descriptionPainter.getPaint()),
                  ExpandableButton(
                      child: Text("See more".toUpperCase(),
                          style: Theme.of(context).textTheme.button))
                ],
              ),
              expanded: Container(
                margin: EdgeInsets.only(top: 7),
                child: Text(
                  widget.insideData.description.trim(),
                ),
              ))),
    );
  }
}
