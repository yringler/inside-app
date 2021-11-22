import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';
import 'package:inside_data_flutter/inside_data_flutter.dart';
import 'package:just_audio_handlers/just_audio_handlers.dart';

class PlayButton extends StatelessWidget {
  final Media media;

  /// If [media] can't be provided, it's enough to pass in [mediaSource].
  /// In such a case, play will not cause to be added to recently played.
  final String? mediaSource;
  final double iconSize;
  final VoidCallback? onPressed;

  String? get _mediaSource => media.source;

  PlayButton(
      {required this.media,
      this.mediaSource,
      this.onPressed,
      this.iconSize = 24});

  @override
  Widget build(BuildContext context) {
    final audioHandler = BlocProvider.getDependency<AudioHandler>();

    return StreamBuilder<PositionState>(
      stream: getPositionState(audioHandler),
      // Default: play button (in case never gets stream, because from diffirent media not now playing)
      builder: (context, snapshot) {
        VoidCallback onPressed = () {
          audioHandler.playFromMediaId(_mediaSource!);

          if (media != null) {
            BlocProvider.getDependency<ChosenClassService>()
                .set(source: media, isRecent: true);
          }
        };
        var icon = Icons.play_circle_filled;

        if (snapshot.hasData && snapshot.data?.id == _mediaSource) {
          if (snapshot.data!.state.processingState ==
              AudioProcessingState.loading) {
            return CircularProgressIndicator();
          }

          if (snapshot.data!.state.playing) {
            icon = Icons.pause_circle_filled;
            onPressed = () => audioHandler.pause();
          }
        }

        return IconButton(
          onPressed: () {
            onPressed();
            if (this.onPressed != null) {
              this.onPressed!();
            }
          },
          icon: Icon(icon),
          iconSize: this.iconSize,
        );
      },
    );
  }
}
