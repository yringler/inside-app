import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:inside_chassidus/util/audio-service/audio-task.dart';
import 'package:rxdart/rxdart.dart';

class MediaManager extends BlocBase {
  Observable<MediaState> get mediaState => _mediaSubject;
  Observable<WithMediaState<Duration>> get mediaPosition => _positionSubject;

  StreamSubscription<PlaybackState> _audioPlayerStateSubscription;

  BehaviorSubject<MediaState> _mediaSubject = BehaviorSubject();
  BehaviorSubject<WithMediaState<Duration>> _positionSubject =
      BehaviorSubject();

  // Ensure that seeks don't happen to frequently.
  final PublishSubject<Duration> _seekingValues = PublishSubject();

  MediaManager() {
    _audioPlayerStateSubscription =
        AudioService.playbackStateStream.listen((state) {
      if (state != null && state.basicState != BasicPlaybackState.none) {
        _mediaSubject.value = current.copyWith(state: state.basicState);
      }

      if (state.basicState == BasicPlaybackState.stopped) {
        _mediaSubject.value = MediaState(duration: null, media: null, state: BasicPlaybackState.none);
      }
    });

    Observable.combineLatest2<PlaybackState, int, WithMediaState<Duration>>(
            AudioService.playbackStateStream
                .where((state) => state?.basicState != BasicPlaybackState.none),
            Observable.periodic(Duration(milliseconds: 20)),
            (state, _) => _onPositionUpdate(state))
        .listen((state) => _positionSubject.value = state);

    _seekingValues
        .debounceTime(Duration(milliseconds: 50))
        .listen((position) => AudioService.seekTo(position.inMilliseconds));
  }

  /// The media which is currently playing.
  MediaState get current => _mediaSubject.value;

  pause() => AudioService.pause();

  play(Media media) async {
    if (media == _mediaSubject.value?.media) {
      AudioService.play();
      return;
    }

    if (!await AudioService.running) {
      await AudioService.start(
          backgroundTaskEntrypoint: backgroundTaskEntrypoint,
          androidNotificationChannelName: "Inside Chassidus Class");
    }

    // While getting a file to play, we want to manually handle the state streams.
    _audioPlayerStateSubscription.pause();

    _mediaSubject.value = MediaState(
        media: media,
        duration: media.duration,
        state: BasicPlaybackState.connecting);

    AudioService.playFromMediaId(media.source);
    var durationState = await AudioService.currentMediaItemStream
        .where((item) =>
            item != null &&
            item.duration != null &&
            item.id == media?.source &&
            item.duration > 0)
        .first;

    _mediaSubject.value = current.copyWith(
        state: AudioService.playbackState.basicState,
        duration: Duration(milliseconds: durationState.duration));

    _audioPlayerStateSubscription.resume();
  }

  /// Updates the current location in given media.
  seek(Media media, Duration location) {
    if (media.source != _mediaSubject.value?.media?.source) {
      return;
    }

    _seekingValues.add(location);
  }

  skip(Media media, Duration duration) async {
    final currentLocation = _positionSubject.value.data.inMilliseconds;
    seek(media, Duration(milliseconds: currentLocation) + duration);
  }

  WithMediaState<Duration> _onPositionUpdate(PlaybackState state) {
    if (state == null) {
      print("Warning: state is null");
      return null;
    }

    final timeSinceUpdate = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(state.updateTime));
    int position = state.position + timeSinceUpdate.inMilliseconds;

    // If playback is paused, then we're in the same place as last update.
    if (state.basicState != BasicPlaybackState.playing) {
      position = state.position;
    }

    return WithMediaState(
        state: current, data: Duration(milliseconds: position));
  }

  @override
  void dispose() {
    _mediaSubject.close();
    _positionSubject.close();
    _seekingValues.close();
    super.dispose();
  }
}

backgroundTaskEntrypoint() async =>
    await AudioServiceBackground.run(() => AudioTask());

class MediaState {
  final Media media;
  final BasicPlaybackState state;
  final bool isLoaded;
  final Duration duration;

  MediaState({this.media, this.state, this.duration})
      : isLoaded = state != BasicPlaybackState.connecting &&
            state != BasicPlaybackState.error &&
            state != BasicPlaybackState.none;

  MediaState copyWith(
          {Media media, BasicPlaybackState state, Duration duration}) =>
      MediaState(
          media: media ?? this.media,
          state: state ?? this.state,
          duration: duration ?? this.duration);
}

/// Allows strongly typed binding of media state with any other value.
/// For example, to associate a stram of audio postions with current file.
class WithMediaState<T> {
  final MediaState state;
  final T data;

  WithMediaState({this.state, this.data});

  WithMediaState<T> copyWith({MediaState state, T data}) => WithMediaState(state: state ?? this.state, data: data ?? this.data);
}
