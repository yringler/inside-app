import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:rxdart/rxdart.dart';

class MediaManager extends BlocBase {
  final AudioPlayer audioPlayer = AudioPlayer();
  Observable<MediaState> get mediaState => _mediaState.stream;
  StreamSubscription<AudioPlayerState> _audioPlayerStateSubscription;
  BehaviorSubject<MediaState> _mediaState = BehaviorSubject();

  MediaManager() {
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen(_onPlayerStateChanged);
  }

  /// The media which is currently playing.
  MediaState get current => _mediaState.value;

  play(Media media) async {
    if (media == _mediaState.value?.media) {
      audioPlayer.resume();
      return;
    }

    // While getting a file to play, we want to manually handle the state stream.
    _audioPlayerStateSubscription.pause();

    _mediaState.value = MediaState(media: media, isLoaded: false, duration: media.duration);

    await audioPlayer.play(media.source);
    var duration = await audioPlayer.onDurationChanged.first;

    _mediaState.value = MediaState(
        media: media,
        isLoaded: true,
        state: audioPlayer.state,
        duration: duration);

    _audioPlayerStateSubscription.resume();
  }

  /// Updates the current location in given media.
  seek(Media media, Duration location) {
    if (media.source != _mediaState.value?.media?.source) {
      return;
    }

    audioPlayer.seek(location);
  }

  skip(Media media, Duration duration) async {
    final currentLocation = await audioPlayer.getCurrentPosition();
    seek(media, Duration(milliseconds: currentLocation) + duration);
  }

  void _onPlayerStateChanged(AudioPlayerState state) {
    final current = _mediaState.value;

    _mediaState.value = MediaState(
        media: current.media,
        isLoaded: current.isLoaded,
        state: state,
        duration: current.duration);
  }

  @override
  void dispose() {
    _mediaState.close();
    super.dispose();
  }
}

class MediaState {
  final Media media;
  final bool isLoaded;
  final AudioPlayerState state;
  final Duration duration;

  MediaState({this.media, this.isLoaded, this.state, this.duration});
}

/// Allows strongly typed binding of media state with any other value.
/// For example, to associate a stram of audio postions with current file.
class WithMediaState<T> {
  final MediaState state;
  final T data;

  WithMediaState({this.state, this.data});
}
