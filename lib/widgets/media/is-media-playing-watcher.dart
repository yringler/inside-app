import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_service/position-manager/position-manager.dart';

typedef Widget PlayerAwareBuilder(BuildContext context,
    {bool isPlaying, String mediaSource});

class IsMediaPlayingWatcher extends StatelessWidget {
  final PlayerAwareBuilder builder;

  IsMediaPlayingWatcher({@required this.builder});

  @override
  Widget build(BuildContext context) {
    final positionManager = BlocProvider.getBloc<PositionManager>();

    return StreamBuilder<PositionState>(
        stream: positionManager.positionStateStream,
        builder: (context, state) => builder(context,
            mediaSource:state.data.position.id , isPlaying: state.data.state?.playing ?? false));
  }
}
