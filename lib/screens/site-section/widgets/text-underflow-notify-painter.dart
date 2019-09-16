import 'package:flutter/material.dart';

class TextUnderflowNotifyPainter extends CustomPainter {
  final String text;
  final TextStyle style;
  final VoidCallback onTextUnderflow;

  TextUnderflowNotifyPainter(this.text,
      {@required this.onTextUnderflow, @required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 3,
        ellipsis: "...");
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, 0));

    if (!textPainter.didExceedMaxLines) {
      onTextUnderflow();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
