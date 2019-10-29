import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import './play-button.dart';

class MediaList extends StatelessWidget {
  final List<Media> media;

  MediaList({this.media});

  @override
  Widget build(BuildContext context) {
    if (media?.isEmpty ?? true) {
      return Center(child: Text('No lessons found'));
    }

   return Expanded(
        child: ListView.builder(
            itemCount: this.media.length,
            itemBuilder: (context, i) {
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
                trailing: PlayButton(
                  media: media
                ),
              );
            }),
      );
  }
}
