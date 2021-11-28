import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';
import 'package:inside_data_flutter/inside_data_flutter.dart';
import 'package:just_audio_handlers/just_audio_handlers.dart';

class NextMediaButton extends StatelessWidget {
  final Media? media;

  final double iconSize;
  final VoidCallback? onPressed;

  NextMediaButton({
    this.media,
    this.onPressed,
    this.iconSize = 24
  });

  @override
  Widget build(BuildContext context) {
    final audioHandler = BlocProvider.getDependency<AudioHandler>();

    return StreamBuilder<PositionState>(
      stream: getPositionState(audioHandler),
      builder: (context, snapshot) {
        VoidCallback? onPressed = null;

        if (media != null) {
          onPressed = () {
            if (this.onPressed != null)
              this.onPressed!();

            if (snapshot.hasData && snapshot.data!.state.playing)
              audioHandler.playFromMediaId(media!.source);

            BlocProvider.getDependency<ChosenClassService>().set(source: media!, isRecent: true);
          };
        }

        return IconButton(
          onPressed: onPressed,
          icon: Icon(FontAwesomeIcons.stepForward),
          iconSize: this.iconSize,
        );
      },
    );
  }
}
