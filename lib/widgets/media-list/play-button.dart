import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:provider/provider.dart';

class PlayButton extends StatefulWidget {
  final Media media;
  final AudioPlayer audioPlayer;

  PlayButton({@required this.media, @required this.audioPlayer});

  @override
  State<StatefulWidget> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  bool isPlaying;
  StreamSubscription<AudioPlayerState> subscription;

  @override void initState() {
    super.initState();

   subscription = widget.audioPlayer.onPlayerStateChanged.listen(_listenToStateChange);
  }

  @override void dispose() {
    subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isPlaying = widget.audioPlayer.state == AudioPlayerState.PLAYING;

    return GestureDetector(
        onTap: () {
          this.setState(() => this.isPlaying = !this.isPlaying);

          var player = Provider.of<AudioPlayer>(context);

          if (this.isPlaying) {
            player.play(this.widget.media.source);
          } else {
            player.pause();
          }
        },
        child: Icon(this.isPlaying ? Icons.pause : Icons.play_arrow));
  }

  _listenToStateChange(AudioPlayerState state) {
    bool isPlaying = state == AudioPlayerState.PLAYING;
    
    if (isPlaying != this.isPlaying) {
      this.setState(() => this.isPlaying = isPlaying);
    }
  }
}
