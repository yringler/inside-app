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
    final mediaManager = BlocProvider.getDependency<PositionManager>();

    // As soon as we get to a class you're in the middle of, even before you play, show
    // the position that you're at.

    return FutureBuilder<Duration>(
      future: mediaManager.positionDataManager.getPosition(media.source),
      initialData: Duration.zero,
      builder: (context, snapshot) => _progressBar(mediaManager, snapshot.data),
    );
  }

  Widget _progressBar(PositionManager mediaManager, Duration start) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _slider(mediaManager, start: start),
        _timeLabels(mediaManager, start: start)
      ],
    );
  }

  Row _timeLabels(PositionManager positionManager, {Duration start}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Show current time in class.
        _stateDurationStreamBuilder(positionManager.positionStateStreamOf(media.source),
            inactiveBuilder: (_) => _time(start),
            builder: (data) => _time(data.position.position)),
        // Show time remaining in class.
        _stateDurationStreamBuilder(positionManager.positionStateStreamOf(media.source),
            inactiveBuilder: (_) => _time(media.duration - start),
            builder: (data) => _time(media.duration - data.position.position))
      ],
    );
  }

  Widget _slider(PositionManager positionManager, {Duration start}) {
    final maxSliderValue = media.duration.inMilliseconds.toDouble();

    if (maxSliderValue == 0) {
      return Container(child: Slider(onChanged: null, value: 0, max: 0));
    }

    final onChanged = (double newProgress) => positionManager.seek(
                  Duration(milliseconds: newProgress.round()),
                  id: media.source);

    return Container(
      child: _stateDurationStreamBuilder(positionManager.positionStateStreamOf(media.source),
          inactiveBuilder: (_) => Slider(
                onChanged: onChanged,
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
              onChanged: onChanged,
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
          if (!snapshot.hasData ||
              snapshot.data.position?.position == null) {
            return inactiveBuilder(PositionState(
                position: Position(id: media.source, position: Duration.zero)));
          }

          return builder(snapshot.data);
        },
      );

  /// Text representation of the given [Duration].
  Widget _time(Duration duration) => Text(toDurationString(duration));
}
