import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:inside_chassidus/widgets/media-list/play-button.dart';
import 'package:just_audio_service/position-manager/position-manager.dart';

class AudioButtonBar extends StatelessWidget {
  final String mediaSource;
  final Lesson lesson;

  AudioButtonBar({@required this.mediaSource, this.lesson});

  @override
  Widget build(BuildContext context) {
    final mediaManager = BlocProvider.getDependency<PositionManager>();

    return ButtonBar(
      children: <Widget>[
        IconButton(
          icon: Icon(FontAwesomeIcons.stepBackward),
          onPressed: () => mediaManager.seek(Duration.zero, id: mediaSource),
        ),
        IconButton(
            icon: Icon(FontAwesomeIcons.undo),
            onPressed: () =>
                mediaManager.skip(Duration(seconds: -15), id: mediaSource)),
        PlayButton(
          mediaSource: mediaSource,
          iconSize: 48,
        ),
        IconButton(
            icon: Icon(FontAwesomeIcons.redo),
            onPressed: () =>
                mediaManager.skip(Duration(seconds: 15), id: mediaSource)),
        _speedButton()
      ],
      alignment: MainAxisAlignment.spaceBetween,
    );
  }

  /// Speeds, in integer percentages.
  static const speeds = [75, 100, 125, 150, 200];

  _speedButton() => StreamBuilder<PlaybackState>(
        stream: AudioService.playbackStateStream,
        builder: (context, state) {
          final currentSpeed = ((state.data?.speed ?? 1) * 100).floor();
          final nextSpeedIndex = speeds.indexOf(currentSpeed) + 1;
          final nextSpeed =
              speeds[nextSpeedIndex >= speeds.length ? 0 : nextSpeedIndex];
          final currentDisplaySpeed = (currentSpeed.toDouble() / 100)
              .toStringAsFixed(2)
              .replaceAll('.00', '');

          return MaterialButton(
              onPressed: () =>
                  AudioService.setSpeed(nextSpeed.toDouble() / 100),
              child: Text('$currentDisplaySpeed x'));
        },
      );
}
