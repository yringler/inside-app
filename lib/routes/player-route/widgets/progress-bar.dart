import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/models/inside-data/media.dart';
import 'package:inside_chassidus/data/media-manager.dart';
import 'package:inside_chassidus/data/repositories/recently-played-repository.dart';
import 'package:inside_chassidus/util/duration-helpers.dart';

typedef Widget ProgressStreamBuilder(WithMediaState<Duration> state);

class ProgressBar extends StatelessWidget {
  final Media media;

  ProgressBar({this.media});

  @override
  Widget build(BuildContext context) {
    final mediaManager = BlocProvider.getBloc<MediaManager>();
    final positionRepository =
        BlocProvider.getDependency<RecentlyPlayedRepository>();
    // As soon as we get to a class you're in the middle of, even before you play, show
    // the position that you're at.
    final startingPosition = positionRepository.getPosition(media);

    // Stream of media. A new media object is set when the duration is loaded.
    // Really, I should have all the durations offline, but I don't yet, so when I
    // get it rebuild.
    return StreamBuilder<MediaState>(
      stream: mediaManager.mediaState.where((state) =>
          state.media.source == media.source &&
          state.media.duration != media.duration),
      initialData:
          MediaState(media: media, state: BasicPlaybackState.connecting),
      builder: (context, snapshot) {
        final media = snapshot.data.media;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _slider(mediaManager, media, start: startingPosition),
            _timeLabels(mediaManager, media, start: startingPosition)
          ],
        );
      },
    );
  }

  Row _timeLabels(MediaManager mediaManager, Media media, {Duration start}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Show current time in class.
        _stateDurationStreamBuilder(mediaManager.mediaPosition,
            inactiveBuilder: (_) => _time(start),
            builder: (data) => _time(data.data)),
        // Show time remaining in class.
        _stateDurationStreamBuilder(mediaManager.mediaPosition,
            inactiveBuilder: (_) => _time(media.duration),
            builder: (data) => _time(media.duration - data.data))
      ],
    );
  }

  Container _slider(MediaManager mediaManager, Media media, {Duration start}) {
    final maxSliderValue = media.duration?.inMilliseconds?.toDouble() ?? 0;

    return Container(
      child: _stateDurationStreamBuilder(mediaManager.mediaPosition,
          inactiveBuilder: (_) => Slider(
                onChanged: null,
                value: start.inMilliseconds.toDouble(),
                max: maxSliderValue,
              ),
          builder: (data) {
            double value = data.data.inMilliseconds.toDouble();
            final maxSliderValue =
                data.state.media?.duration?.inMilliseconds?.toDouble() ?? 0;

            value =
                value > maxSliderValue ? maxSliderValue : value < 0 ? 0 : value;

            return Slider(
              value: value,
              max: maxSliderValue,
              onChanged: (newProgress) => mediaManager.seek(
                  media, Duration(milliseconds: newProgress.round())),
            );
          }),
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
              snapshot.data.state.media.source != media.source ||
              //(snapshot.data.state.duration == null && snapshot.data.data == null)
              !snapshot.data.state.isLoaded) {
            return inactiveBuilder(
                WithMediaState<Duration>(data: Duration.zero, state: null));
          }

          return builder(snapshot.data);
        },
      );

  /// Text representation of the given [Duration].
  Widget _time(Duration duration) => Text(toDurationString(duration));
}
