import 'package:flutter/material.dart';
import 'package:inside_chassidus/widgets/media/current-media-button-bar.dart';
import 'package:inside_chassidus/widgets/media/is-media-playing-watcher.dart';

/// A widget which sizes its child based on how much size it has left over from the [CurrentMediaButtonBar].
class AudioButtonbarAwareBody extends StatelessWidget {
  final Widget body;

  AudioButtonbarAwareBody({this.body});

  @override
  Widget build(BuildContext context) => IsMediaPlayingWatcher(
      builder: (context, {isPlaying, mediaSource}) => Padding(
            child: body,
            padding: EdgeInsets.only(
                bottom: CurrentMediaButtonBar.heightOfMediaBar(context,
                    isPlaying: isPlaying)),
          ));
}
