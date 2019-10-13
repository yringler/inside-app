import 'dart:async';

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
        if (snapshot.hasData && media == snapshot.data.media) {
          VoidCallback onPressed;
          if (snapshot.data.state == FileState.playing) {
            onPressed = () => mediaManger.audioPlayer.pause();
          }

          return IconButton(
              onPressed: onPressed, icon: Icon(Icons.pause_circle_filled));
        }

        return IconButton(
            onPressed: () => mediaManger.play(media),
            icon: Icon(Icons.play_circle_filled));
      },
    );
  }
}
