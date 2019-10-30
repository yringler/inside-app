import 'package:flutter/material.dart';

/// Returns a text widget, or null if the text is empty.
Widget textIfNotEmpty(String text, {int maxLines}) {
  if (text?.isNotEmpty ?? false) {
    return Text(text,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null);
  }

  return null;
}
