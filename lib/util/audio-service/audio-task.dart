import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

const playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);

const pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);

const stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

class AudioTask extends BackgroundAudioTask {
  final _audioPlayer = AudioPlayer();

  final Completer _completer = Completer();

  /// just_audio triggers a stop event when source is set. Don't end service
  /// because of it.
  bool isStoppingToLoadNext = false;

  /// Closes the background service as soon as there's a stop.
  /// This behaviour is paused when one lesson is played in middle of another.
  StreamSubscription _playerCompletedSubscription;

  /// The source for the current audio file.
  String mediaSource;

  /// This is only briefly set before setting the file path. It is set
  /// to null as soon as it becomes active, namely after [AudioPlaybackState.stopped]
  /// untill [AudioPlaybackState.connecting].
  String nextMediaSource;

  @override
  void onPlayFromMediaId(String mediaId) => _playFromMediaId(mediaId);

  Future<void> _playFromMediaId(String mediaId) async {
    mediaSource = mediaId;
    Duration length;

    nextMediaSource = mediaId;
    isStoppingToLoadNext = true;

    try {
      length = await _audioPlayer.setUrl(mediaId);
      nextMediaSource = null;
      mediaSource = mediaId;
    } finally {
      isStoppingToLoadNext = false;
    }

    _setMediaItem(length: length);
    onPlay();
  }

  @override
  Future<void> onStart() async {
    final playbackStateSubscription =
        _audioPlayer.playerStateStream.listen(_onPlaybackEvent);
    _playerCompletedSubscription = _audioPlayer.playbackStateStream
        .where((state) =>
            !isStoppingToLoadNext && state == AudioPlaybackState.stopped)
        .listen((state) => onStop());

    await _completer.future;

    _playerCompletedSubscription.cancel();
    playbackStateSubscription.cancel();
    await _audioPlayer.dispose();
  }

  @override
  void onPlay() {
    if (canPlay()) {
      _audioPlayer.play();
    }
  }

  @override
  void onPause() {
    final state = _audioPlayer.playerState.state;

    if (state == AudioPlaybackState.buffering ||
        state == AudioPlaybackState.playing) _audioPlayer.pause();
  }

  @override
  void onSeekTo(int position) => _seekTo(position);

  void _seekTo(int position) async {
    final interimState =
        position < _audioPlayer.playerState.position.inMilliseconds
            ? BasicPlaybackState.rewinding
            : BasicPlaybackState.fastForwarding;

    _setState(state: interimState);
    await _audioPlayer.seek(Duration(milliseconds: position));

    if (AudioServiceBackground.state.basicState != stateToStateMap[_audioPlayer.playerState.state]) {
          _setState(state: stateToStateMap[_audioPlayer.playerState.state]);
    }
  }

  @override
  void onClick(MediaButton button) {
    // TODO: it would be great if general click on notification would open the app...
    if (canPlay()) {
      onPlay();
    } else {
      onPause();
    }
  }

  @override
  void onStop() => _stop();

  void _stop() async {
    await _audioPlayer.stop();
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  void _setState({@required BasicPlaybackState state}) {
    // TODO: Confirm that connecting state (which is after stopped state) has
    // null position and updateTime.

    AudioServiceBackground.setState(
        controls: _getControls(state),
        basicState: state,
        position: _audioPlayer.playerState?.updatePosition?.inMilliseconds ??
            Duration.zero,
        updateTime: _audioPlayer.playerState?.updateTime?.inMilliseconds ??
            DateTime.now().millisecondsSinceEpoch);
  }

  List<MediaControl> _getControls(BasicPlaybackState state) {
    switch (state) {
      case BasicPlaybackState.paused:
        return [playControl, stopControl];
      default:
        return [pauseControl, stopControl];
    }
  }

  void _onPlaybackEvent(AudioPlayerState event) {
    switch (event.state) {
      case AudioPlaybackState.connecting:
        // Tell background service of the new media.

        if (nextMediaSource?.isEmpty ?? true) {
          break;
        }

        mediaSource = nextMediaSource;
        nextMediaSource = null;

        if (AudioService.currentMediaItem?.id != mediaSource) {
          _setMediaItem();
        }

        _setState(state: BasicPlaybackState.connecting);
        break;
      case AudioPlaybackState.none:
        break;
      default:
        _setState(state: stateToStateMap[event.state]);
    }
  }

  void _setMediaItem({Duration length}) {
    AudioServiceBackground.setMediaItem(MediaItem(
        id: mediaSource,
        title: "Class",
        album: "Inside Chassidus",
        duration: length?.inMilliseconds));
  }

  bool canPlay() {
    final state = _audioPlayer.playerState.state;
    return state == AudioPlaybackState.paused ||
        state == AudioPlaybackState.stopped;
  }

  static final Map<AudioPlaybackState, BasicPlaybackState> stateToStateMap =
      Map.fromEntries([
    MapEntry(AudioPlaybackState.buffering, BasicPlaybackState.buffering),
    MapEntry(AudioPlaybackState.connecting, BasicPlaybackState.connecting),
    MapEntry(AudioPlaybackState.none, BasicPlaybackState.none),
    MapEntry(AudioPlaybackState.paused, BasicPlaybackState.paused),
    MapEntry(AudioPlaybackState.playing, BasicPlaybackState.playing),
    MapEntry(AudioPlaybackState.stopped, BasicPlaybackState.stopped)
  ]);
}
