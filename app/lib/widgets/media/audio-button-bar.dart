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
  final String mediaId;

  AudioButtonBar({required this.mediaId, this.media})
      : super(key: ValueKey(mediaId));

  AudioButtonBar.fromMedia({required Media media})
      : this(media: media, mediaId: media.id);

  @override
  State<AudioButtonBar> createState() => _AudioButtonBarState();

  /// Speeds, in integer percentages.
  static const speeds = [.75, 1.0, 1.25, 1.5, 2.0];
}

class _AudioButtonBarState extends State<AudioButtonBar> {
  Media? _media;
  Section? _section;

  String get mediaId => widget.mediaId;

  final PositionSaver positionSaver =
      BlocProvider.getDependency<PositionSaver>();

  final AudioHandler handler = BlocProvider.getDependency<AudioHandler>();

  final SiteDataLayer dataLayer = BlocProvider.getDependency<SiteDataLayer>();

  @override
  void initState() {
    super.initState();

    if (widget.media != null) {
      _media = widget.media;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Try to get the media section, so we can set up the previous/next medias to play.

    if (_section == null) {
      final mediaFuture =
          _media != null ? Future.value(_media) : dataLayer.media(mediaId);
      return FutureBuilder<Media?>(
          future: mediaFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _media ??= snapshot.data;
            }

            if (_media == null || _media!.parents.isEmpty) {
              return _buttonBar();
            }

            return _sectionBuilder(media: _media!);
          });
    }

    return _sectionBuilder(media: _media!);
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
          double currentSpeed = state.data ?? 1;

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
