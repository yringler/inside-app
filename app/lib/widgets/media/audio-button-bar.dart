import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inside_chassidus/widgets/media-list/next-media-button.dart';
import 'package:inside_chassidus/widgets/media-list/previous-media-button.dart';
import 'package:inside_data/inside_data.dart';
import 'package:just_audio_handlers/just_audio_handlers.dart';
import 'package:inside_chassidus/widgets/media-list/play-button.dart';

class AudioButtonBar extends StatefulWidget {
  final Media? media;

  /// Set [_mediaId] if [media] isn't available.
  final String? mediaId;

  AudioButtonBar({this.media, this.mediaId});

  @override
  State<AudioButtonBar> createState() =>
      _AudioButtonBarState(mediaId: (media?.id ?? mediaId)!);

  /// Speeds, in integer percentages.
  static const speeds = [.75, 1.0, 1.25, 1.5, 2.0];
}

class _AudioButtonBarState extends State<AudioButtonBar> {
  Media? _media;
  Section? _section;

  final String mediaId;

  final PositionSaver positionSaver =
      BlocProvider.getDependency<PositionSaver>();

  final AudioHandler handler = BlocProvider.getDependency<AudioHandler>();

  final SiteDataLayer dataLayer = BlocProvider.getDependency<SiteDataLayer>();

  _AudioButtonBarState({required this.mediaId});

  @override
  void initState() {
    super.initState();

    if (widget.media != null) {
      _media = widget.media;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_section == null) {
      final mediaFuture = widget.media != null
          ? Future.value(widget.media)
          : dataLayer.media(mediaId);
      return FutureBuilder<Media?>(
          future: mediaFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _media ??= snapshot.data;
            }

            if (_media == null || _media!.parents.isEmpty) {
              return _buttonBar();
            }

            return _sectionBuilder(media: widget.media!);
          });
    }

    return _sectionBuilder(media: widget.media!);
  }

  /// Try to get the next/back buttons from section.
  FutureBuilder<Section?> _sectionBuilder({required Media media}) =>
      FutureBuilder<Section?>(
          future: _section == null
              ? dataLayer.section(media.firstParent!)
              : Future.value(_section!),
          builder: (context, snapshot) {
            if (snapshot.hasData && _section == null) {
              _section = snapshot.data;
            }
            return _buttonBar(media: media, section: _section);
          });

  ButtonBar _buttonBar({Media? media, Section? section}) {
    Media? nextMedia =
        section?.getRelativeSibling(media!, SiblingDirection.next);
    Media? prevMedia =
        section?.getRelativeSibling(media!, SiblingDirection.previous);

    return ButtonBar(
      alignment: MainAxisAlignment.spaceAround,
      buttonPadding: const EdgeInsets.symmetric(vertical: 8.0),
      children: <Widget>[
        PreviousMediaButton(
          currentMedia: media,
          currentMediaId: mediaId,
          previousMedia: prevMedia,
        ),
        IconButton(
            icon: Icon(FontAwesomeIcons.undo),
            onPressed: () => positionSaver.skip(mediaId, Duration(seconds: -15),
                handler: handler)),
        PlayButton(
          media: media,
          mediaId: mediaId,
          iconSize: 48,
        ),
        IconButton(
            icon: Icon(FontAwesomeIcons.redo),
            onPressed: () => positionSaver.skip(mediaId, Duration(seconds: 15),
                handler: handler)),
        NextMediaButton(
          media: nextMedia,
        ),
        _speedButton(handler),
      ],
    );
  }

  _speedButton(AudioHandler audioHandler) => StreamBuilder<double>(
        stream: audioHandler.playbackState
            .map((event) => event.speed)
            .distinct()
            .where((speed) => speed != 0),
        initialData: 1,
        builder: (context, state) {
          double currentSpeed = state.data!;

          final nextSpeedIndex =
              AudioButtonBar.speeds.indexOf(currentSpeed) + 1;
          final nextSpeed = AudioButtonBar.speeds[
              nextSpeedIndex >= AudioButtonBar.speeds.length
                  ? 0
                  : nextSpeedIndex];
          final currentDisplaySpeed =
              currentSpeed.toStringAsFixed(2).replaceAll('.00', '');

          return MaterialButton(
              onPressed: () => audioHandler.setSpeed(nextSpeed),
              child: Text('$currentDisplaySpeed x'));
        },
      );
}
