import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import './play-button.dart';

class MediaList extends StatelessWidget {
  final Widget leadingWidget;
  final List<Media> media;

  MediaList({this.media, this.leadingWidget});

  @override
  Widget build(BuildContext context) {
    if (media?.isEmpty ?? true) {
      return Center(child: Text('No lessons found'));
    }

    // If there is a leading widget, index is 1 too many.
    final indexOffset = leadingWidget == null ? 0 : 1;

    return ListView.builder(
        itemCount: this.media.length + indexOffset,
        itemBuilder: (context, i) {
          if (i == 0 && leadingWidget != null) {
            return leadingWidget;
          }

          i -= indexOffset;

          var media = this.media[i];
          String title = media.title;
          Text subtitle;

          if (media.description?.isNotEmpty ?? false) {
            subtitle = Text(media.description, maxLines: 1);
          }

          if (title?.isEmpty ?? true) {
            title = "Lesson ${i + 1}";
          }

          return ListTile(
            contentPadding: EdgeInsets.all(4),
            title: Text(title),
            subtitle: subtitle,
            trailing: PlayButton(media: media),
          );
        });
  }
}
