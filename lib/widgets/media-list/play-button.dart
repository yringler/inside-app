import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/data/media-manager.dart';
import 'package:provider/provider.dart';

class PlayButton extends StatelessWidget {
  final Media media;

  PlayButton({this.media});

  @override
  Widget build(BuildContext context) {
    final mediaManger = Provider.of<MediaManager>(context);

    return StreamBuilder<MediaState>(
      stream: mediaManger.mediaState,
      builder: (context, snapshot) {
        VoidCallback onPressed;
        var icon = Icons.play_circle_filled;

        if (snapshot.hasData) {
          if (snapshot.data.state == AudioPlayerState.PLAYING) {
            icon = Icons.pause_circle_filled;
            onPressed = () => mediaManger.audioPlayer.pause();
          } else {
            onPressed = () => mediaManger.play(media);
          }
        }

        return IconButton(onPressed: onPressed, icon: Icon(icon));
      },
    );
  }
}
