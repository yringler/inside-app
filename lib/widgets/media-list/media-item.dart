import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/media-manager.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:inside_chassidus/routes/player-route/index.dart';
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

    final mediaManager = BlocProvider.getBloc<MediaManager>();

    final style = mediaManager.current?.media == media
        ? Theme.of(context)
            .textTheme
            .body1
            .copyWith(fontWeight: FontWeight.bold)
        : null;

    final onPressed = () => Navigator.of(context)
        .pushNamed(PlayerRoute.routeName, arguments: media);

    return GestureDetector(
      onTap: onPressed,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
        subtitle: subtitle,
        trailing: PlayButton(
          media: media,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
