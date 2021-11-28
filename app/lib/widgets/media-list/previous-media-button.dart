import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';
import 'package:inside_data_flutter/inside_data_flutter.dart';
import 'package:just_audio_handlers/just_audio_handlers.dart';

class PreviousMediaButton extends StatelessWidget {
  static final Duration tenSeconds = const Duration(seconds: 10);

  final Media? currentMedia;
  final Media? previousMedia;

  final double iconSize;
  final VoidCallback? onPressed;

  PreviousMediaButton({
    this.currentMedia,
    this.previousMedia,
    this.onPressed,
    this.iconSize = 24
  });

  @override
  Widget build(BuildContext context) {
    final audioHandler = BlocProvider.getDependency<AudioHandler>();
    final positionSaver = BlocProvider.getDependency<PositionSaver>();

    return StreamBuilder<PositionState>(
      stream: getPositionState(audioHandler),
      builder: (context, snapshot) {
        VoidCallback? onPressed = null;

        if (_shouldGoToPreviousMedia(snapshot)) {
          onPressed = () {
            if (this.onPressed != null)
              this.onPressed!();

            if (snapshot.hasData && snapshot.data!.state.playing)
              audioHandler.playFromMediaId(previousMedia!.source);

            BlocProvider.getDependency<ChosenClassService>().set(
                source: previousMedia!, isRecent: true
            );
          };
        } else if (_shouldGoToBeginningOfCurrentMedia(snapshot)) {
          onPressed = () =>
            positionSaver.set(currentMedia!.source, Duration.zero, handler: audioHandler);
        }

        return IconButton(
          onPressed: onPressed,
          icon: Icon(FontAwesomeIcons.stepBackward),
          iconSize: this.iconSize,
        );
      },
    );
  }

  bool _shouldGoToPreviousMedia(AsyncSnapshot<PositionState> snapshot) {
    return previousMedia != null &&
        _currentAudioPosition(snapshot) < tenSeconds;
  }

  bool _shouldGoToBeginningOfCurrentMedia(AsyncSnapshot<PositionState> snapshot) {
    return currentMedia != null &&
        (previousMedia == null || _currentAudioPosition(snapshot) > tenSeconds);
  }

  Duration _currentAudioPosition(AsyncSnapshot<PositionState> snapshot) {
    if (!snapshot.hasData)
      return Duration.zero;
    else
      return snapshot.data!.state.position;
  }
}
