import 'package:flutter/material.dart';

typedef SizeCallback = void Function(Size size);

class TextUnderflowNotifyPainter extends CustomPainter {
  final String text;
  final TextStyle style;
  final VoidCallback onTextUnderflow;
  final SizeCallback onSize;

  TextUnderflowNotifyPainter(this.text,
      {@required this.onTextUnderflow, @required this.style, this.onSize});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 3,
        ellipsis: "...");
    textPainter.layout(maxWidth: size.width);
    textPainter.paint(canvas, Offset.zero);

    if (!textPainter.didExceedMaxLines) {
      onTextUnderflow();
    }

    if (this.onSize != null) {
      this.onSize(Size(textPainter.width, textPainter.height));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
