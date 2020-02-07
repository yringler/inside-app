import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:inside_chassidus/data/media-manager.dart';
import 'package:inside_chassidus/widgets/media/audio-button-bar.dart';

/// A button bar which always effects the current media, and is an empty
/// container if there's nothing going on.
class CurrentMediaButtonBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaManager = BlocProvider.getBloc<MediaManager>();

    return StreamBuilder<MediaState>(
      stream: mediaManager.mediaState,
      builder: (context, state) {
        if (state.hasData &&
            state.data?.media != null &&
            _isMediaActive(state.data.state)) {
          return Container(
            child: AudioButtonBar(
              media: state.data.media,
            ),
            color: Colors.grey.shade300,
          );
        }

        return Container(height: 0,);
      },
    );
  }

  _isMediaActive(BasicPlaybackState state) =>
      state != null &&
      state != BasicPlaybackState.error &&
      state != BasicPlaybackState.none &&
      state != BasicPlaybackState.stopped;
}
