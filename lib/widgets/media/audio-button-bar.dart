import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inside_chassidus/data/media-manager.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:inside_chassidus/routes/player-route/index.dart';
import 'package:inside_chassidus/widgets/media-list/play-button.dart';

class AudioButtonBar extends StatelessWidget {
  final Media media;
  final Lesson lesson;

  AudioButtonBar({@required this.media, this.lesson});

  @override
  Widget build(BuildContext context) {
    final mediaManager = BlocProvider.getBloc<MediaManager>();

    return ButtonBar(
      children: <Widget>[
        IconButton(
          icon: Icon(FontAwesomeIcons.stepBackward),
          onPressed: () => mediaManager.seek(media, Duration.zero),
        ),
        IconButton(
            icon: Icon(FontAwesomeIcons.undo),
            onPressed: () => mediaManager.skip(media, Duration(seconds: -15))),
        PlayButton(
          media: media,
          iconSize: 48,
        ),
        IconButton(
            icon: Icon(FontAwesomeIcons.redo),
            onPressed: () => mediaManager.skip(media, Duration(seconds: 15))),
        _stopButton(mediaManager)
      ],
      alignment: MainAxisAlignment.spaceBetween,
    );
  }

  _stopButton(MediaManager mediaManager) => StreamBuilder<MediaState>(
        stream: mediaManager.mediaState,
        builder: (context, state) => IconButton(
          icon: Icon(Icons.stop),
          onPressed:
              media == state.data?.media ? () => mediaManager.stop() : null,
        ),
      );

  _playNext(BuildContext context) {
    if ((lesson?.audio?.isEmpty ?? true) || lesson.audio.length == 1) {
      return;
    }

    // The next class is first lesson or next lesson.
    final nextIndex =
        lesson.audio.last == media ? 0 : lesson.audio.indexOf(media) + 1;
    Navigator.of(context)
        .pushNamed(PlayerRoute.routeName, arguments: lesson.audio[nextIndex]);
  }
}
