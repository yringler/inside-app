import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:rxdart/rxdart.dart';

class MediaManager {
  final AudioPlayer audioPlayer = AudioPlayer();
  Observable<MediaState> get mediaState => _mediaState.stream;
  StreamSubscription<AudioPlayerState> _audioPlayerStateSubscription;
  BehaviorSubject<MediaState> _mediaState = BehaviorSubject();

  MediaManager() {
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen(onPlayerStateChanged);
  }

  play(Media media) async {
    if (media == _mediaState.value?.media) {
      audioPlayer.resume();
      return;
    }

    // While getting a file to play, we want to manually handle the state stream.
    _audioPlayerStateSubscription.pause();

    _mediaState.value = MediaState(media: media, isLoaded: false);

    await audioPlayer.play(media.source);
    var duration = await audioPlayer.onDurationChanged.first;

    _mediaState.value = MediaState(media: media, isLoaded: true, state: audioPlayer.state, duration: duration);

    _audioPlayerStateSubscription.resume();
  }

  void onPlayerStateChanged(AudioPlayerState state) {
    final current = _mediaState.value;

    _mediaState.value = MediaState(
        media: current.media, isLoaded: current.isLoaded, state: state, duration: current.duration);
  }
}

class MediaState {
  final Media media;
  final bool isLoaded;
  final AudioPlayerState state;
  final Duration duration;

  MediaState({this.media, this.isLoaded, this.state, this.duration});
}
