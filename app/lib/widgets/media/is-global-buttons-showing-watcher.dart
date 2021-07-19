import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/blocs/is-player-buttons-showing.dart';
import 'package:rxdart/rxdart.dart';

typedef Widget GlobalMediaButtonsAwareBuilder(BuildContext context,
    {required bool isGlobalButtonsShowing, String? mediaSource});

class IsGlobalMediaButtonsShowingWatcher extends StatelessWidget {
  final GlobalMediaButtonsAwareBuilder builder;

  IsGlobalMediaButtonsShowingWatcher({required this.builder});

  @override
  Widget build(BuildContext context) {
    final positionManager = BlocProvider.getDependency<AudioHandler>();
    final isOtherButtonsShowing =
        BlocProvider.getBloc<IsPlayerButtonsShowingBloc>();

    return StreamBuilder<StateAndShowing>(
        stream:
            Rx.combineLatest3<MediaItem, PlaybackState, bool, StateAndShowing>(
                positionManager.mediaItem
                    .where((event) => event != null)
                    .map((event) => event!),
                positionManager.playbackState,
                isOtherButtonsShowing.globalButtonsShowingStream,
                (a, b, c) => StateAndShowing(
                    mediaItem: a, playbackState: b, isGlobalShowing: c)),
        builder: (context, state) => builder(context,
            mediaSource: state.data?.mediaItem.id ?? null,
            isGlobalButtonsShowing: (state.data?.isGlobalShowing ?? false) &&
                _showState(state.data?.playbackState)));
  }

  /// If the given state can have a global player shown.
  bool _showState(PlaybackState? state) {
    if (state == null) {
      return false;
    }

    return ![
      AudioProcessingState.completed,
      AudioProcessingState.error,
      AudioProcessingState.idle
    ].contains(state.processingState);
  }
}

class StateAndShowing {
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  /// If global play buttons are showing.
  final bool? isGlobalShowing;

  StateAndShowing(
      {required this.playbackState,
      required this.isGlobalShowing,
      required this.mediaItem});
}
