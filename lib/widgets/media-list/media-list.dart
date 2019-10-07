import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import './play-button.dart';

class MediaList extends StatelessWidget {
  final List<Media> media;

  MediaList({this.media});

  @override
  Widget build(BuildContext context) => ListView.builder(
      itemCount: this.media.length,
      itemBuilder: (context, i) {
        var media = this.media[i];

        return ListTile(
          contentPadding: EdgeInsets.all(4),
          title: Text(media.title),
          subtitle: Text(media.description, maxLines: 1),
          trailing: PlayButton(media: media),
        );
      });
}
