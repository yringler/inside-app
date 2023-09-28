import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_chassidus/util/text-null-if-empty.dart';
import 'package:inside_chassidus/widgets/media-length.dart';
import 'package:inside_data/inside_data.dart';

class MediaItem extends StatelessWidget {
  final Media media;
  final String? sectionId;
  final String? fallbackTitle;
  final IRoutDataService routeDataService;

  MediaItem(
      {required this.media,
      this.fallbackTitle,
      required this.sectionId,
      required this.routeDataService}) {
    if (sectionId != null && sectionId!.isNotEmpty) {
      media.parents.add(sectionId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = media.title;

    final subtitle = textIfNotEmpty(media.description, maxLines: 1);

    if (title.isEmpty) {
      title = fallbackTitle ?? '';
    }

    final handler = BlocProvider.getDependency<AudioHandler>();

    final style = handler.mediaItem.valueOrNull?.id == media.id
        ? Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(fontWeight: FontWeight.bold)
        : null;

    final onPressed = () => routeDataService.setActiveItem(media);

    return ListTile(
      onTap: onPressed,
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
      subtitle: subtitle,
      trailing: MediaLength(media: media),
    );
  }
}
