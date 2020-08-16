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
            positionManager.positionStateStream
                .distinct((a, b) => a.state.playing == b.state.playing),
            isOtherButtonsShowing.buttonsShowingStream,
            (a, b) => StateAndShowing(positionState: a, isButtonsShowing: b)),
        builder: (context, state) => builder(context,
            mediaSource: state.data?.positionState?.position?.id ?? null,
            isGlobalButtonsShowing: !(state.data?.isButtonsShowing ?? false) &&
                (state.data?.positionState?.state?.playing ?? false)));
  }
}

class StateAndShowing {
  final PositionState positionState;

  /// If buttons are already showing, even without the global buttons. I.e, on
  /// player.
  final bool isButtonsShowing;

  StateAndShowing({this.positionState, this.isButtonsShowing});
}
