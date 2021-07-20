import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_api/models.dart';
import 'package:inside_chassidus/util/duration-helpers.dart';
import 'package:just_audio_handlers/just_audio_handlers.dart';

typedef Widget ProgressStreamBuilder(Duration state);

class ProgressBar extends StatelessWidget {
  final Media? media;

  ProgressBar({this.media});

  @override
  Widget build(BuildContext context) {
    final mediaManager = BlocProvider.getDependency<AudioHandler>();
    final positionManager = BlocProvider.getDependency<PositionSaver>();

    // As soon as we get to a class you're in the middle of, even before you play, show
    // the position that you're at.

    return FutureBuilder<Duration>(
      future: positionManager.get(media!.source!),
      initialData: Duration.zero,
      builder: (context, snapshot) => _progressBar(mediaManager, snapshot.data),
    );
  }

  Widget _progressBar(AudioHandler handler, Duration? start) {
    final stream = getPositionStateWithPersisted(
        handler, BlocProvider.getDependency<PositionSaver>(),
        mediaId: media!.source!);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _slider(handler, start: start, stream: stream),
        _timeLabels(handler, start: start, stream: stream)
      ],
    );
  }

  Row _timeLabels(AudioHandler handler,
      {Duration? start, required Stream<Duration> stream}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Show current time in class.
        _stateDurationStreamBuilder(stream,
            inactiveBuilder: (_) => _time(start),
            builder: (data) => _time(data)),
        // Show time remaining in class.
        _stateDurationStreamBuilder(
            getPositionStateFiltered(handler, media!.source!)
                .map((event) => event.state.position),
            inactiveBuilder: (_) => _time(media!.length - start!),
            builder: (position) => _time(media!.length - position))
      ],
    );
  }

  Widget _slider(AudioHandler handler,
      {Duration? start, required Stream<Duration> stream}) {
    final positionSaver = BlocProvider.getDependency<PositionSaver>();
    final maxSliderValue = media!.length.inMilliseconds.toDouble();

    if (maxSliderValue == 0) {
      return Container(child: Slider(onChanged: null, value: 0, max: 0));
    }

    final onChanged = (double newProgress) => positionSaver.set(
        media!.source!, Duration(milliseconds: newProgress.round()),
        handler: handler);

    return Container(
      child: _stateDurationStreamBuilder(stream,
          inactiveBuilder: (_) => Slider(
                onChanged: onChanged,
                value: start!.inMilliseconds.toDouble(),
                max: maxSliderValue,
              ),
          builder: (position) {
            double value = position.inMilliseconds.toDouble();

            value = value > maxSliderValue
                ? maxSliderValue
                : value < 0
                    ? 0
                    : value;

            return Slider(
              value: value,
              max: maxSliderValue,
              onChanged: onChanged,
            );
          }),
    );
  }

  /// Simplifies creating a [StreamBuilder] for [WithMediaState<Duration>]
  Widget _stateDurationStreamBuilder<T>(Stream<Duration> stream,
          {ProgressStreamBuilder? builder,
          ProgressStreamBuilder? inactiveBuilder}) =>
      StreamBuilder<Duration>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return inactiveBuilder!(Duration.zero);
          }

          return builder!(snapshot.data!);
        },
      );

  /// Text representation of the given [Duration].
  Widget _time(Duration? duration) => Text(toDurationString(duration));
}
