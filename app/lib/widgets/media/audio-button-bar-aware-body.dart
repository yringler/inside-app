import 'package:flutter/material.dart';
import 'package:inside_chassidus/widgets/media/current-media-button-bar.dart';
import 'package:inside_chassidus/widgets/media/is-global-buttons-showing-watcher.dart';

/// A widget which sizes its child based on how much size it has left over from the [CurrentMediaButtonBar].
class AudioButtonbarAwareBody extends StatelessWidget {
  final Widget? body;

  AudioButtonbarAwareBody({this.body});

  @override
  Widget build(BuildContext context) => IsGlobalMediaButtonsShowingWatcher(
      builder: (context, {required isGlobalButtonsShowing, mediaSource}) => Padding(
            child: body,
            padding: EdgeInsets.only(
                bottom: CurrentMediaButtonBar.heightOfMediaBar(context,
                    isPlaying: isGlobalButtonsShowing)),
          ));
}
