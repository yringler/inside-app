import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/screens/site-section/widgets/text-underflow-notify-painter.dart';

class InsideDataCard extends StatefulWidget {
  final CountableInsideData insideData;

  InsideDataCard({this.insideData});

  @override
  State<StatefulWidget> createState() => _InsideDataCardData();
}

class _InsideDataCardData extends State<InsideDataCard> {
  /// Wether should have a "Show more button", etc.
  /// Initially, based on wether there's a description.
  /// If, after we create the description widget, all the text is showing,
  /// setState to not expandable.
  bool createExpandable;

  Size textSize = Size.zero;

  @override
  void initState() {
    super.initState();

    createExpandable = widget.insideData.description?.isNotEmpty ?? false;
  }

  @override
  Widget build(BuildContext context) => Card(
      margin: EdgeInsets.all(8),
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _title(context),
            if (createExpandable)
              _expandableDescription(context)
            else
              Text(widget.insideData.description)
          ],
        ),
      ));

  Widget _title(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "${widget.insideData.audioCount} classes",
        ),
        Text(widget.insideData.title, style: Theme.of(context).textTheme.title)
      ]);

  Widget _expandableDescription(BuildContext context) {
    return ExpandableNotifier(
      child: ScrollOnExpand(
        child: Expandable(
            collapsed: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomPaint(
                    size: textSize,
                    painter: TextUnderflowNotifyPainter(
                        widget.insideData.description,
                        onTextUnderflow: () =>
                            setState(() => createExpandable = false),
                        onSize: (size) => setState(() => textSize = size),
                        style: Theme.of(context).textTheme.body1)),
                ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: [
                    ExpandableButton(
                        child: Text("See more",
                            style: Theme.of(context).textTheme.button))
                  ],
                )
              ],
            ),
            expanded: Text(widget.insideData.description)),
      ),
    );
  }
}
