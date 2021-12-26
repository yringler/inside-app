import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inside_chassidus/widgets/media-list/next-media-button.dart';
import 'package:inside_chassidus/widgets/media-list/previous-media-button.dart';
import 'package:inside_data/inside_data.dart';
import 'package:just_audio_handlers/just_audio_handlers.dart';
import 'package:inside_chassidus/widgets/media-list/play-button.dart';

class AudioButtonBar extends StatelessWidget {
  final Media? media;

  /// Set [_mediaId] if [media] isn't available.
  final String? mediaId;

  final Media? nextMedia;

  final Media? previousMedia;

  String? get _mediaId => media?.id ?? mediaId;

  AudioButtonBar({
    required this.media,
    this.mediaId,
    this.nextMedia,
    this.previousMedia,
  });

  @override
  Widget build(BuildContext context) {
    final handler = BlocProvider.getDependency<AudioHandler>();
    final positionSaver = BlocProvider.getDependency<PositionSaver>();

    return ButtonBar(
      alignment: MainAxisAlignment.spaceAround,
      buttonPadding: const EdgeInsets.symmetric(vertical: 8.0),
      children: <Widget>[
        PreviousMediaButton(
          currentMedia: media,
          currentMediaId: _mediaId,
          previousMedia: previousMedia,
        ),
        IconButton(
            icon: Icon(FontAwesomeIcons.undo),
            onPressed: () => positionSaver
                .skip(_mediaId, Duration(seconds: -15), handler: handler)),
        PlayButton(
          media: media,
          mediaId: _mediaId,
          iconSize: 48,
        ),
        IconButton(
            icon: Icon(FontAwesomeIcons.redo),
            onPressed: () => positionSaver.skip(_mediaId, Duration(seconds: 15),
                handler: handler)),
        NextMediaButton(
          media: nextMedia,
        ),
        _speedButton(handler),
      ],
    );
  }

  /// Speeds, in integer percentages.
  static const speeds = [.75, 1.0, 1.25, 1.5, 2.0];

  _speedButton(AudioHandler audioHandler) => StreamBuilder<double>(
        stream: audioHandler.playbackState
            .map((event) => event.speed)
            .distinct()
            .where((speed) => speed != 0),
        initialData: 1,
        builder: (context, state) {
          double currentSpeed = state.data!;

          final nextSpeedIndex = speeds.indexOf(currentSpeed) + 1;
          final nextSpeed =
              speeds[nextSpeedIndex >= speeds.length ? 0 : nextSpeedIndex];
          final currentDisplaySpeed =
              currentSpeed.toStringAsFixed(2).replaceAll('.00', '');

          return MaterialButton(
              onPressed: () => audioHandler.setSpeed(nextSpeed),
              child: Text('$currentDisplaySpeed x'));
        },
      );
}
