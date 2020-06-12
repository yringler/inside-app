import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/util/audio-service/audio-task.dart';
import 'package:just_audio_service/position-manager/position-manager.dart';

class PlayButton extends StatelessWidget {
  final String mediaSource;
  final double iconSize;
  final VoidCallback onPressed;

  PlayButton({this.mediaSource, this.onPressed, this.iconSize = 24});

  @override
  Widget build(BuildContext context) {
    final mediaManger = BlocProvider.getDependency<PositionManager>();

    return StreamBuilder<PositionState>(
      stream: mediaManger.positionStateStream,
      // Default: play button (in case never gets stream, because from diffirent media not now playing)
      builder: (context, snapshot) {
        VoidCallback onPressed = () {
          if (!AudioService.running) {
            AudioService.start(
                    backgroundTaskEntrypoint: _audioServiceEntryPoint,
                    androidNotificationChannelName: "Inside Chassidus Class",
                    androidStopForegroundOnPause: true)
                .then((_) => AudioService.playFromMediaId(mediaSource));
          } else {
            AudioService.playFromMediaId(mediaSource);
          }
        };
        var icon = Icons.play_circle_filled;

        if (snapshot.hasData &&
            snapshot.data.position?.id == mediaSource &&
            snapshot.data.state != null) {
          if (snapshot.data.state.processingState ==
              AudioProcessingState.connecting) {
            return CircularProgressIndicator();
          }

          if (snapshot.data.state.playing) {
            icon = Icons.pause_circle_filled;
            onPressed = () => AudioService.pause();
          }
        }

        return IconButton(
          onPressed: () {
            onPressed();
            if (this.onPressed != null) {
              this.onPressed();
            }
          },
          icon: Icon(icon),
          iconSize: this.iconSize,
        );
      },
    );
  }
}

_audioServiceEntryPoint() {
  AudioServiceBackground.run(() => LoggingAudioTask());
}
