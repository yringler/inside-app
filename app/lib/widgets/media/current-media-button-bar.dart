import 'package:flutter/material.dart';
import 'package:inside_chassidus/widgets/media/audio-button-bar.dart';
import 'package:inside_chassidus/widgets/media/is-global-buttons-showing-watcher.dart';

/// A button bar which always effects the current media, and is an empty
/// container if there's nothing going on.
class CurrentMediaButtonBar extends StatelessWidget {
  static const double _barHeight = 75;

  /// Given the context and wether media is currently playing, returns how much size
  /// the rest of the app has.
  static double heightOfMediaBar(BuildContext context,
          {required bool isPlaying}) =>
      isPlaying ? _barHeight : 0;

  @override
  Widget build(BuildContext context) {
    return IsGlobalMediaButtonsShowingWatcher(
        builder: (context, {required isGlobalButtonsShowing, mediaId}) =>
            isGlobalButtonsShowing
                ? Container(
                    child: AudioButtonBar(
                      mediaId: mediaId,
                    ),
                    color: Colors.grey.shade300,
                    height: _barHeight,
                  )
                : Container(
                    height: 0,
                  ));
  }
}
