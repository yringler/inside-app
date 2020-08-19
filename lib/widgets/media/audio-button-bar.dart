import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inside_chassidus/widgets/media-list/play-button.dart';
import 'package:just_audio_service/position-manager/position-manager.dart';

class AudioButtonBar extends StatelessWidget {
  final String mediaSource;

  AudioButtonBar({@required this.mediaSource});

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
          sectionId: null,
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
  static const speeds = [.75, 1.0, 1.25, 1.5, 2.0];

  _speedButton() => StreamBuilder<double>(
        stream: AudioService.playbackStateStream
            .map((event) => event?.speed ?? 1.0)
            .where((speed) => speed != 0),
        initialData: 1,
        builder: (context, state) {
          double currentSpeed = state.data;

          final nextSpeedIndex = speeds.indexOf(currentSpeed) + 1;
          final nextSpeed =
              speeds[nextSpeedIndex >= speeds.length ? 0 : nextSpeedIndex];
          final currentDisplaySpeed =
              currentSpeed.toStringAsFixed(2).replaceAll('.00', '');

          return MaterialButton(
              onPressed: () => AudioService.setSpeed(nextSpeed),
              child: Text('$currentDisplaySpeed x'));
        },
      );
}
