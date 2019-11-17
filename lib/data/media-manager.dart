import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:rxdart/rxdart.dart';

class MediaManager extends BlocBase {
  final AudioPlayer audioPlayer = AudioPlayer();
  Observable<MediaState> get mediaState => _mediaSubject;
  Observable<WithMediaState<Duration>> get mediaPosition => _positionSubject;

  StreamSubscription<AudioPlayerState> _audioPlayerStateSubscription;
  StreamSubscription<Duration> _positionSubscription;

  BehaviorSubject<MediaState> _mediaSubject = BehaviorSubject();
  BehaviorSubject<WithMediaState<Duration>> _positionSubject;

  MediaManager() {
    _positionSubject = BehaviorSubject(
        onListen: () => _positionSubscription.resume(),
        onCancel: () => _positionSubscription.pause());

    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen(_onPlayerStateChanged);
    _positionSubscription =
        audioPlayer.onAudioPositionChanged.listen(_onPositionChanged);

    // We don't need to keep track of position if no one is listening.
    _positionSubscription.pause();
  }

  /// The media which is currently playing.
  MediaState get current => _mediaSubject.value;

  play(Media media) async {
    if (media == _mediaSubject.value?.media) {
      audioPlayer.resume();
      return;
    }

    // While getting a file to play, we want to manually handle the state streams.
    _audioPlayerStateSubscription.pause();
    _positionSubscription.pause();

    _mediaSubject.value =
        MediaState(media: media, isLoaded: false, duration: media.duration);

    await audioPlayer.play(media.source);
    var duration = await audioPlayer.onDurationChanged.first;

    _mediaSubject.value = current.copyWith(
        isLoaded: true, state: audioPlayer.state, duration: duration);

    _audioPlayerStateSubscription.resume();
    _positionSubscription.resume();
  }

  /// Updates the current location in given media.
  seek(Media media, Duration location) {
    if (media.source != _mediaSubject.value?.media?.source) {
      return;
    }

    audioPlayer.seek(location);
  }

  skip(Media media, Duration duration) async {
    final currentLocation = await audioPlayer.getCurrentPosition();
    seek(media, Duration(milliseconds: currentLocation) + duration);
  }

  void _onPlayerStateChanged(AudioPlayerState state) =>
      _mediaSubject.value = current.copyWith(state: state);

  @override
  void dispose() {
    _mediaSubject.close();
    _positionSubject.close();
    super.dispose();
  }

  void _onPositionChanged(Duration position) {
    this
        ._positionSubject
        .add(WithMediaState<Duration>(state: current, data: position));
  }
}

class MediaState {
  final Media media;
  final bool isLoaded;
  final AudioPlayerState state;
  final Duration duration;

  MediaState({this.media, this.isLoaded, this.state, this.duration});

  MediaState copyWith(
          {Media media,
          bool isLoaded,
          AudioPlayerState state,
          Duration duration}) =>
      MediaState(
          media: media ?? this.media,
          isLoaded: isLoaded ?? this.isLoaded,
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
