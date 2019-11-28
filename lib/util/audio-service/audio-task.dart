import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

final playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
final pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
final stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

class AudioTask extends BackgroundAudioTask {
  final _audioPlayer = AudioPlayer();

  /// Position in milliseconds.
  int _position;

  final Completer _completer = Completer();

  StreamSubscription playerCompletedSubscription;

  /// The source for the current audio file.
  String mediaSource;

  @override
  void onPlayFromMediaId(String mediaId) {
    if (mediaSource != null) {
      // Don't close the service during switch.
      playerCompletedSubscription.pause();

      if (mediaSource != mediaId) {
        _position = null;
      }

      // Set class property.
      mediaSource = mediaId;
      // Now, onPlay will play new audio.
      onPlay();
    } else {
      mediaSource = mediaId;
    }
  }

  @override
  Future<void> onStart() async {
    if (mediaSource?.isEmpty ?? true) {
      return;
    }

    playerCompletedSubscription = _audioPlayer.onPlayerStateChanged
        .where((state) => state == AudioPlayerState.COMPLETED)
        .listen((state) {
      _handlePlaybackCompleted();
    });

    var audioPositionSubscription =
        _audioPlayer.onAudioPositionChanged.listen(_onPositionChanged);

    await _completer.future;
    audioPositionSubscription.cancel();
    playerCompletedSubscription.cancel();
  }

  @override
  void onPlay() {
    _audioPlayer.play(mediaSource);

    // If the audio was already loaded, and we're just resuming.
    if (_position != null) {
      _setPlayState();
    }
  }

  @override
  void onPause() {
    _audioPlayer.pause();
    _setState(state: BasicPlaybackState.paused, position: _position);
  }

  @override
  void onSeekTo(int position) {
    _audioPlayer.seek(Duration(milliseconds: position));
    final state = AudioServiceBackground.state.basicState;
    _setState(state: state, position: position);
  }

  @override
  void onClick(MediaButton button) {
    _playPause();
  }

  @override
  void onStop() {
    _audioPlayer.stop();
    _setState(state: BasicPlaybackState.stopped);
    _completer.complete();
  }

  void _playPause() {
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      onPause();
    else
      onPlay();
  }

  void _setState({@required BasicPlaybackState state, int position = 0}) {
    AudioServiceBackground.setState(
      controls: _getControls(state),
      basicState: state,
      position: position,
    );
  }

  void _onPositionChanged(Duration position) {
    final wasConnecting = _position == null;
    _position = position.inMilliseconds;
    if (wasConnecting) {
      // After a delay, we finally start receiving audio positions from the
      // AudioPlayer plugin, so we can broadcast the playing state.
      _setPlayState();
    }
  }

  void _handlePlaybackCompleted() => onStop();

  void _setPlayState() {
    _setState(state: BasicPlaybackState.playing, position: _position);
  }

  List<MediaControl> _getControls(BasicPlaybackState state) {
    switch (state) {
      case BasicPlaybackState.playing:
        return [pauseControl, stopControl];
      case BasicPlaybackState.paused:
        return [playControl, stopControl];
      default:
        return [stopControl];
    }
  }
}
