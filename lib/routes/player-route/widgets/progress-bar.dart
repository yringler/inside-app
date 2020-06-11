import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/models/inside-data/media.dart';
import 'package:inside_chassidus/util/duration-helpers.dart';
import 'package:just_audio_service/position-manager/position-manager.dart';
import 'package:just_audio_service/position-manager/position.dart';

typedef Widget ProgressStreamBuilder(PositionState state);

class ProgressBar extends StatelessWidget {
  final Media media;

  ProgressBar({this.media});

  @override
  Widget build(BuildContext context) {
    final mediaManager = BlocProvider.getBloc<PositionManager>();

    // As soon as we get to a class you're in the middle of, even before you play, show
    // the position that you're at.

    return FutureBuilder<Duration>(
      future: mediaManager.positionDataManager.getPosition(media.source),
      initialData: Duration.zero,
      builder: (context, snapshot) => _progressBar(mediaManager, snapshot.data),
    );
  }

  StreamBuilder<PositionState> _progressBar(
      PositionManager mediaManager, Duration start) {
    // Stream of media. A new media object is set when the duration is loaded.
    // Really, I should have all the durations offline, but I don't yet, so when I
    // get it rebuild.
    // TODO: get all durations.
    return StreamBuilder<PositionState>(
      stream: mediaManager.positionStateStream
          .where((state) => state.position.id == media.source),
      initialData:
          PositionState(position: Position(id: media.source, position: start)),
      builder: (context, snapshot) {
        final duration = snapshot.data.mediaItem?.duration;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _slider(mediaManager, duration, start: start),
            _timeLabels(mediaManager, duration, start: start)
          ],
        );
      },
    );
  }

  Row _timeLabels(PositionManager mediaManager, Duration duration,
      {Duration start}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Show current time in class.
        _stateDurationStreamBuilder(mediaManager.positionStateStream,
            inactiveBuilder: (_) => _time(start),
            builder: (data) => _time(data.position.position)),
        // Show time remaining in class.
        _stateDurationStreamBuilder(mediaManager.positionStateStream,
            inactiveBuilder: (_) => _time(null),
            builder: (data) => _time(duration - data.position.position))
      ],
    );
  }

  Widget _slider(PositionManager positionManager, Duration duration,
      {Duration start}) {
    final maxSliderValue = duration?.inMilliseconds?.toDouble() ?? 0;

    if (maxSliderValue == 0) {
      return Container(child: Slider(onChanged: null, value: 0, max: 0));
    }

    return Container(
      child: _stateDurationStreamBuilder(positionManager.positionStateStream,
          inactiveBuilder: (_) => Slider(
                onChanged: null,
                value: start.inMilliseconds.toDouble(),
                max: maxSliderValue,
              ),
          builder: (data) {
            double value = data.position.position.inMilliseconds.toDouble();

            value =
                value > maxSliderValue ? maxSliderValue : value < 0 ? 0 : value;

            return Slider(
              value: value,
              max: maxSliderValue,
              onChanged: (newProgress) => positionManager.seek(
                  Duration(milliseconds: newProgress.round()),
                  id: media.source),
            );
          }),
    );
  }

  /// Simplifies creating a [StreamBuilder] for [WithMediaState<Duration>]
  Widget _stateDurationStreamBuilder<T>(Stream<PositionState> stream,
          {ProgressStreamBuilder builder,
          ProgressStreamBuilder inactiveBuilder}) =>
      StreamBuilder<PositionState>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data.position?.position == null) {
            return inactiveBuilder(PositionState(
                position: Position(id: media.source, position: Duration.zero)));
          }

          return builder(snapshot.data);
        },
      );

  /// Text representation of the given [Duration].
  Widget _time(Duration duration) => Text(toDurationString(duration));
}
