import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/blocs/is-player-buttons-showing.dart';
import 'package:just_audio_service/position-manager/position-manager.dart';
import 'package:rxdart/rxdart.dart';

typedef Widget GlobalMediaButtonsAwareBuilder(BuildContext context,
    {bool isGlobalButtonsShowing, String mediaSource});

class IsGlobalMediaButtonsShowingWatcher extends StatelessWidget {
  final GlobalMediaButtonsAwareBuilder builder;

  IsGlobalMediaButtonsShowingWatcher({@required this.builder});

  @override
  Widget build(BuildContext context) {
    final positionManager = BlocProvider.getDependency<PositionManager>();
    final isOtherButtonsShowing =
        BlocProvider.getBloc<IsPlayerButtonsShowingBloc>();

    return StreamBuilder<StateAndShowing>(
        stream: Rx.combineLatest2<PositionState, bool, StateAndShowing>(
            positionManager.positionStateStream.distinct(
                (a, b) => a.state?.processingState == b.state?.processingState),
            isOtherButtonsShowing.globalButtonsShowingStream,
            (a, b) => StateAndShowing(positionState: a, isGlobalShowing: b)),
        builder: (context, state) => builder(context,
            mediaSource: state.data?.positionState?.position?.id ?? null,
            isGlobalButtonsShowing: (state.data?.isGlobalShowing ?? false) &&
                _showState(state.data?.positionState?.state)));
  }

  /// If the given state can have a global player shown.
  bool _showState(PlaybackState state) {
    if (state == null) {
      return false;
    }

    return ![
      AudioProcessingState.completed,
      AudioProcessingState.error,
      AudioProcessingState.none
    ].contains(state.processingState);
  }
}

class StateAndShowing {
  final PositionState positionState;

  /// If global play buttons are showing.
  final bool isGlobalShowing;

  StateAndShowing({this.positionState, this.isGlobalShowing});
}
