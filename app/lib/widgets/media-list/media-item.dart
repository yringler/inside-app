import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_chassidus/util/text-null-if-empty.dart';
import 'package:inside_chassidus/widgets/media-list/play-button.dart';
import 'package:inside_data/inside_data.dart';

class MediaItem extends StatelessWidget {
  // TODO: this probably shouldn't be nullable.
  final Media? media;
  final String? sectionId;
  final String? fallbackTitle;
  final IRoutDataService routeDataService;

  MediaItem(
      {this.media,
      this.fallbackTitle,
      required this.sectionId,
      required this.routeDataService}) {
    if (sectionId != null && sectionId!.isNotEmpty) {
      media!.parents.add(sectionId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? title = media!.title;
    Text? subtitle;

    subtitle = textIfNotEmpty(media!.description, maxLines: 1) as Text?;

    if (title.isEmpty) {
      title = fallbackTitle;
    }

    final handler = BlocProvider.getDependency<AudioHandler>();

    final style = handler.mediaItem.valueOrNull?.id == media?.id
        ? Theme.of(context)
            .textTheme
            .bodyText2!
            .copyWith(fontWeight: FontWeight.bold)
        : null;

    final onPressed = () => routeDataService.setActiveItem(media);

    return ListTile(
      onTap: onPressed,
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      title: Text(
        title!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
      subtitle: subtitle,
      trailing: PlayButton(
        media: media!,
        onPressed: onPressed,
      ),
    );
  }
}
