import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/models/inside-data/media.dart';
import 'package:inside_chassidus/data/media-manager.dart';

typedef Widget ProgressStreamBuilder(WithMediaState<Duration> state);

class ProgressBar extends StatelessWidget {
  final Media media;

  ProgressBar({this.media});

  @override
  Widget build(BuildContext context) {
    final mediaManager = BlocProvider.getBloc<MediaManager>();
    final stream = mediaManager.mediaState.zipWith(
        mediaManager.audioPlayer.onAudioPositionChanged,
        (mediaState, duration) =>
            WithMediaState<Duration>(state: mediaState, data: duration));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _stateDurationStreamBuilder(stream,
            inactiveBuilder: (data) => Slider(onChanged: null, value: 0),
            builder: (data) => Slider(
                  value: data.data.inMilliseconds.toDouble(),
                  max: data.state.duration.inMilliseconds.toDouble(),
                  onChanged: (newProgress) => mediaManager.seek(
                      media, Duration(milliseconds: newProgress.round())),
                )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _stateDurationStreamBuilder(stream,
                inactiveBuilder: (data) => _time(null),
                builder: (data) => _time(data.data)),
            StreamBuilder<MediaState>(
              stream: mediaManager.mediaState,
              builder: (context, snapshot) {
                return !snapshot.hasData ||
                        snapshot.data.media.source != media.source
                    ? _time(null)
                    : _time(snapshot.data.duration);
              },
            )
          ],
        )
      ],
    );
  }

  /// Simplifies creating a [StreamBuilder] for [WithMediaState<Duration>]
  Widget _stateDurationStreamBuilder<T>(Stream<WithMediaState<Duration>> stream,
          {ProgressStreamBuilder builder,
          ProgressStreamBuilder inactiveBuilder}) =>
      StreamBuilder<WithMediaState<Duration>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data.state.media.source != media.source) {
            return inactiveBuilder(
                WithMediaState<Duration>(data: Duration.zero, state: null));
          }

          return builder(snapshot.data);
        },
      );

  /// Text representation of the given [Duration].
  Widget _time(Duration duration) {
    return duration == null
        ? Text("--:--")
        : Text("${duration.inMinutes}:${duration.inSeconds}");
  }
}
