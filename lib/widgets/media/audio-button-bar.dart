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
        _speedButton(mediaManager)
      ],
      alignment: MainAxisAlignment.spaceBetween,
    );
  }

  /// Speeds, in integer percentages.
  static const speeds = [75, 100, 125, 150, 200];

  _speedButton(MediaManager mediaManager) => StreamBuilder<MediaState>(
        stream: mediaManager.mediaState,
        builder: (context, state) {
          final currentSpeed = ((state.data?.speed ?? 1) * 100).floor();
          final nextSpeedIndex = speeds.indexOf(currentSpeed) + 1;
          final nextSpeed =
              speeds[nextSpeedIndex >= speeds.length ? 0 : nextSpeedIndex];
          final currentDisplaySpeed = (currentSpeed.toDouble() / 100).toStringAsFixed(2).replaceAll('.00', '');

          return MaterialButton(
              onPressed: () => mediaManager.setSpeed(nextSpeed),
              child: Text('$currentDisplaySpeed x'));
        },
      );

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
