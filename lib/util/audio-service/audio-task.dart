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
    // Make sure the service doesn't end just because we're playing something else.
    _playerCompletedSubscription.pause();

    final length = await _audioPlayer.setFilePath(mediaId);
    _setMediaItem(length: length);

    _playerCompletedSubscription.resume();

    onPlay();
  }

  @override
  Future<void> onStart() async {
    assert(mediaSource?.isNotEmpty ?? false);

    _playerCompletedSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.stopped)
        .listen((state) => onStop());
    final playbackStateSubscription =
        _audioPlayer.playerStateStream.listen(_onPlaybackEvent);

    await _completer.future;

    _playerCompletedSubscription.cancel();
    playbackStateSubscription.cancel();
    await _audioPlayer.dispose();
  }

  @override
  void onPlay() {
    final state = _audioPlayer.playerState.state;
    if (state == AudioPlaybackState.paused ||
        state == AudioPlaybackState.stopped) {
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
  void onSeekTo(int position) =>
      _audioPlayer.seek(Duration(milliseconds: position));

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
  void onStop() {
    _audioPlayer.stop();
    _completer.complete();
  }

  void _setState({@required BasicPlaybackState state}) {
    // TODO: Confirm that connecting state (which is after stopped state) has
    // null position and updateTime.

    AudioServiceBackground.setState(
        controls: _getControls(state),
        basicState: state,
        position: _audioPlayer.playerState.updatePosition.inMilliseconds,
        updateTime: _audioPlayer.playerState.updateTime.inMilliseconds);
  }

  List<MediaControl> _getControls(BasicPlaybackState state) {
    switch (state) {
      case BasicPlaybackState.connecting:
      case BasicPlaybackState.playing:
        return [pauseControl, stopControl];
      case BasicPlaybackState.paused:
        return [playControl, stopControl];
      default:
        return [stopControl];
    }
  }

  void _onPlaybackEvent(AudioPlayerState event) {
    switch (event.state) {
      case AudioPlaybackState.connecting:
        // Tell background service of the new media.

        assert(nextMediaSource?.isNotEmpty ?? false,
            "Connecting must be with next");

        mediaSource = nextMediaSource;
        nextMediaSource = null;

        _setState(state: BasicPlaybackState.connecting);
        _setMediaItem();
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
        duration: length.inMilliseconds));
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
