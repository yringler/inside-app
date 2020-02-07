import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/media-manager.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';

typedef Widget PlayerAwareBuilder(BuildContext context,
    {bool isPlaying, Media media});

class IsMediaPlayingWatcher extends StatelessWidget {
  final PlayerAwareBuilder builder;

  IsMediaPlayingWatcher({@required this.builder});

  @override
  Widget build(BuildContext context) {
    final mediaManager = BlocProvider.getBloc<MediaManager>();

    return StreamBuilder<MediaState>(
        stream: mediaManager.mediaState,
        builder: (context, state) => builder(context,
            media: state.data?.media, isPlaying: _isMediaActive(state.data?.state)));
  }

  _isMediaActive(BasicPlaybackState state) =>
      state != null &&
      state != BasicPlaybackState.error &&
      state != BasicPlaybackState.none &&
      state != BasicPlaybackState.stopped;
}
