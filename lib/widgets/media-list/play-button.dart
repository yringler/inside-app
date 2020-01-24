import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:inside_chassidus/data/media-manager.dart';
import 'package:inside_chassidus/util/audio-service/util.dart';

class PlayButton extends StatelessWidget {
  final Media media;
  final double iconSize;
  final VoidCallback onPressed;

  PlayButton({this.media, this.onPressed, this.iconSize = 24});

  @override
  Widget build(BuildContext context) {
    final mediaManger = BlocProvider.getBloc<MediaManager>();

    return StreamBuilder<MediaState>(
      // It's tricky to get the button right during seeking, so just forget about it.
      stream: mediaManger.mediaState.where((state) => !isSeeking(state.state)),
      builder: (context, snapshot) {
        VoidCallback onPressed = () => mediaManger.play(media);
        var icon = Icons.play_circle_filled;

        if (snapshot.hasData && snapshot.data.media == media) {
          if (!snapshot.data.isLoaded) {
            return CircularProgressIndicator();
          }

          if (snapshot.data.state == BasicPlaybackState.playing || snapshot.data.state == BasicPlaybackState.buffering) {
            icon = Icons.pause_circle_filled;
            onPressed = () => mediaManger.pause();
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
