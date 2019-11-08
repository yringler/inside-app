import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:inside_chassidus/util/text-null-if-empty.dart';
import 'package:inside_chassidus/widgets/media-list/play-button.dart';

class MediaItem extends StatelessWidget {
  final Media media;
  final String fallbackTitle;

  MediaItem({this.media, this.fallbackTitle});

  @override
  Widget build(BuildContext context) {
    String title = media.title;
    Text subtitle;

    subtitle = textIfNotEmpty(media.description, maxLines: 1);

    if (title?.isEmpty ?? true) {
      title = fallbackTitle;
    }

    return ListTile(
      contentPadding: EdgeInsets.all(4),
      title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: subtitle,
      trailing: PlayButton(media: media),
    );
  }
}
