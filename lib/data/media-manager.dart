import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:rxdart/rxdart.dart';

class MediaManager extends BlocBase {
  Observable<MediaState> get mediaState => _mediaSubject;
  Observable<WithMediaState<Duration>> get mediaPosition => _positionSubject;

  StreamSubscription<PlaybackState> _audioPlayerStateSubscription;

  BehaviorSubject<MediaState> _mediaSubject = BehaviorSubject();
  BehaviorSubject<WithMediaState<Duration>> _positionSubject;

  MediaManager() {
    _audioPlayerStateSubscription =
        AudioService.playbackStateStream.listen(_onPlayerStateChanged);

    Observable.combineLatest2<PlaybackState, int, WithMediaState<Duration>>(
        AudioService.playbackStateStream,
        Observable.periodic(Duration(milliseconds: 20), (x) => x), (state, _) {
      final position = state.updateTime + state.position;
      return WithMediaState(
          state: current, data: Duration(milliseconds: position));
    }).listen((state) => _positionSubject.value = state);
  }

  /// The media which is currently playing.
  MediaState get current => _mediaSubject.value;

  pause() => AudioService.pause();

  play(Media media) async {
    if (media == _mediaSubject.value?.media) {
      AudioService.play();
      return;
    }

    // While getting a file to play, we want to manually handle the state streams.
    _audioPlayerStateSubscription.pause();

    _mediaSubject.value = MediaState(
        media: media,
        duration: media.duration,
        state: BasicPlaybackState.connecting);

    AudioService.play();
    var durationState = await AudioService.currentMediaItemStream
        .where((item) => item.id == media.source && item.duration > 0)
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

    AudioService.seekTo(location.inMilliseconds);
  }

  skip(Media media, Duration duration) async {
    final currentLocation = _positionSubject.value.data.inMilliseconds;
    seek(media, Duration(milliseconds: currentLocation) + duration);
  }

  void _onPlayerStateChanged(PlaybackState state) {
    _mediaSubject.value = current.copyWith(state: state.basicState);
  }

  void _onPositionChanged(Duration position) {
    this
        ._positionSubject
        .add(WithMediaState<Duration>(state: current, data: position));
  }

  @override
  void dispose() {
    _mediaSubject.close();
    _positionSubject.close();
    super.dispose();
  }
}

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
}
