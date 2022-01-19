import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inside_chassidus/util/library-navigator/library-position-service.dart';
import 'package:inside_data/inside_data.dart';
import 'package:just_audio_handlers/just_audio_handlers.dart';

class NextMediaButton extends StatelessWidget {
  final Media? media;

  final double iconSize;

  final VoidCallback? onPressed;

  NextMediaButton({this.media, this.onPressed, this.iconSize = 24});

  @override
  Widget build(BuildContext context) {
    final audioHandler = BlocProvider.getDependency<AudioHandler>();
    final libraryPositionService =
        BlocProvider.getDependency<LibraryPositionService>();

    return StreamBuilder<PositionState>(
      stream: getPositionState(audioHandler),
      builder: (context, snapshot) {
        VoidCallback? onPressed;

        if (media != null) {
          onPressed = () {
            libraryPositionService.setActiveItem(media);

            if (snapshot.hasData && snapshot.data!.state.playing)
              audioHandler.playFromMediaId(media!.id);
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
