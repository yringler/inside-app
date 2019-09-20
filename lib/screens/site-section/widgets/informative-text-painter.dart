import 'package:flutter/material.dart';

typedef SizeCallback = void Function(Size size);

class InformativeTextPainter extends CustomPainter {
  final TextPainter _painter;

  InformativeTextPainter(text,
      {@required TextStyle style, @required double maxWidth, int maxLines})
      : _painter = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: TextDirection.ltr,
            maxLines: maxLines,
            ellipsis: "...") {
    _painter.layout(maxWidth: maxWidth);
  }

  @override
  void paint(Canvas canvas, Size size) => _painter.paint(canvas, Offset.zero);

  bool willOverflow() => _painter.didExceedMaxLines;

  CustomPaint getPaint() => CustomPaint(painter: this, size: _painter.size);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
