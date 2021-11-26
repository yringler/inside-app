import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';
import 'package:inside_data_flutter/inside_data_flutter.dart';
import 'package:just_audio_handlers/just_audio_handlers.dart';

class PlayButton extends StatelessWidget {
  final Media? media;

  /// If [media] can't be provided, it's enough to pass in [mediaSource].
  /// In such a case, play will not cause to be added to recently played.
  final String mediaSource;
  final double iconSize;
  final VoidCallback? onPressed;

  PlayButton(
      {this.media, String? mediaSource, this.onPressed, this.iconSize = 24})
      : mediaSource = media?.source ?? mediaSource!;

  @override
  Widget build(BuildContext context) {
    final audioHandler = BlocProvider.getDependency<AudioHandler>();

    return StreamBuilder<PositionState>(
      stream: getPositionState(audioHandler),
      // Default: play button (in case never gets stream, because from diffirent media not now playing)
      builder: (context, snapshot) {
        VoidCallback onPressed = () {
          audioHandler.playFromMediaId(mediaSource);

          if (media != null) {
            BlocProvider.getDependency<ChosenClassService>()
                .set(source: media!, isRecent: true);
          }
        };
        var icon = Icons.play_circle_filled;

        /// The id over here is URL used for download etc, so is URI encoded.
        /// TODO: update audio service to work with ids, can now add implementation somewhere which
        /// queries DB for metadata for a better lock screen etc experiance.
        if (snapshot.hasData &&
            _tryDecodeUri(snapshot.data!.mediaItem.id) ==
                _tryDecodeUri(mediaSource)) {
          if (snapshot.data!.state.processingState ==
              AudioProcessingState.loading) {
            return CircularProgressIndicator();
          }

          if (snapshot.data!.state.playing) {
            icon = Icons.pause_circle_filled;
            onPressed = () => audioHandler.pause();
          }
        }

        return IconButton(
          onPressed: () {
            onPressed();
            if (this.onPressed != null) {
              this.onPressed!();
            }
          },
          icon: Icon(icon),
          iconSize: this.iconSize,
        );
      },
    );
  }

  /// To make sure we test for equaility right, try to decode any URIs.
  /// If that fails, just return the literal string
  /// TODO: this is a bit kludgey, why suddenly are we getting URIs from audio service?
  /// Either way, when we upgrade audio service to use the media DB id, this will be less of an
  /// issue.
  String _tryDecodeUri(String uri) {
    try {
      return Uri.decodeFull(uri);
    } catch (_) {
      return uri;
    }
  }
}
