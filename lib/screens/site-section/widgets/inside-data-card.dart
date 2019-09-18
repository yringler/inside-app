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
                  _description()
                ],
              ),
            ));
      });

  Widget _title(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "${widget.insideData.audioCount} classes",
        ),
        Text(widget.insideData.title.trim(),
            style: Theme.of(context).textTheme.title)
      ]);

  Widget _description() => LayoutBuilder(builder: (context, constraints) {
        final descriptionPainter = InformativeTextPainter(
            widget.insideData.description,
            maxWidth: constraints.maxWidth,
            style: Theme.of(context).textTheme.body1);

        if (descriptionPainter.willOverflow())
          return _expandableDescription(context, descriptionPainter);
        else
          return Text(widget.insideData.description);
      });

  Widget _expandableDescription(
      BuildContext context, InformativeTextPainter descriptionPainter) {
    return ExpandableNotifier(
      child: ScrollOnExpand(
        child: Expandable(
            collapsed: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                descriptionPainter.getPaint(),
                ExpandableButton(
                    child: Text("See more",
                        style: Theme.of(context).textTheme.button))
              ],
            ),
            expanded: Text(widget.insideData.description.trim())),
      ),
    );
  }
}
