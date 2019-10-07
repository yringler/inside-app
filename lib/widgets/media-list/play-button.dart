import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:provider/provider.dart';

class PlayButton extends StatefulWidget {
  final Media media;

  PlayButton({@required this.media});

  @override
  State<StatefulWidget> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
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