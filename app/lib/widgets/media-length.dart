import 'package:flutter/material.dart';
import 'package:inside_chassidus/util/duration-helpers.dart';
import 'package:inside_data/inside_data.dart';

class MediaLength extends StatelessWidget {
  const MediaLength({
    Key? key,
    required this.media,
  }) : super(key: key);

  final Media media;

  @override
  Widget build(BuildContext context) {
    return Text(
      media.length != null ? toDurationString(media.length) : ' ',
      style: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(color: Theme.of(context).disabledColor),
    );
  }
}
