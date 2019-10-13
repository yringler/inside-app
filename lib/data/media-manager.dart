import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show required;
import 'package:inside_chassidus/data/insideData.dart';
import 'package:rxdart/rxdart.dart';

class MediaManager {
  final AudioPlayer audioPlayer = AudioPlayer();
  Observable<MediaState> get mediaState => _mediaState.stream;

  bool _hasListeners;
  MediaState get _currentMediaState {
    return _mediaState.values.length > 0 ? _mediaState.values.first : null;
  }

  ReplaySubject<MediaState> _mediaState;

  MediaManager() {
    _mediaState = ReplaySubject(
        maxSize: 1,
        onListen: () => _hasListeners = true,
        onCancel: () => _hasListeners = false);

    audioPlayer.onPlayerStateChanged.listen(_onPlayerStateChanged);
  }

  play(Media media) {
    // Don't bother with this media if it's already being taken care of.
    if (media == _currentMediaState?.media) {
      return;
    }

    _safeAdd(MediaState(media: media, state: FileState.loading));

    audioPlayer.play(media.source);
  }

  _onPlayerStateChanged(AudioPlayerState state) {
    if (state == AudioPlayerState.PLAYING) {
      _safeAdd(MediaState(
          state: FileState.playing, media: _currentMediaState.media));
    } else {
      _safeAdd(null);
    }
  }

  _safeAdd(MediaState mediaState) {
    if (_hasListeners) {
      _mediaState.add(mediaState);
    }
  }
}

enum FileState { loading, playing }

class MediaState {
  final FileState state;
  final Media media;

  MediaState({@required this.state, @required this.media});
}
