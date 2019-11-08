import 'package:audioplayers/audioplayers.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:inside_chassidus/data/media-manager.dart';

class PlayButton extends StatelessWidget {
  final Media media;

  PlayButton({this.media});

  @override
  Widget build(BuildContext context) {
    final mediaManger = BlocProvider.getBloc<MediaManager>();

    return StreamBuilder<MediaState>(
      stream: mediaManger.mediaState,
      builder: (context, snapshot) {
        VoidCallback onPressed = () => mediaManger.play(media);
        var icon = Icons.play_circle_filled;

        if (snapshot.hasData && snapshot.data.media == media) {
          if (!snapshot.data.isLoaded) {
            return CircularProgressIndicator();
          }

          if (snapshot.data.state == AudioPlayerState.PLAYING) {
            icon = Icons.pause_circle_filled;
            onPressed = () => mediaManger.audioPlayer.pause();
          }
        }

        return IconButton(onPressed: onPressed, icon: Icon(icon));
      },
    );
  }
}
