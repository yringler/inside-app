import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:inside_chassidus/data/models/user-settings/class-position.dart';
import 'package:inside_chassidus/data/repositories/app-data.dart';
import 'package:inside_chassidus/util/audio-service/util.dart';
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

  Box<ClassPosition> _positionBox;

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
    // Don't close player when switching to other media.
    if (mediaId != mediaSource && _playerCompletedSubscription != null) {
      _updatePosition();

      await _cancelStopSubscription();
    }

    nextMediaSource = mediaId;

    final length = await _audioPlayer.setUrl(mediaId);

    nextMediaSource = null;
    mediaSource = mediaId;

    _setMediaItem(length: length);
    await _onPlay();
  }

  @override
  Future<void> onStart() async {
    final playbackStateSubscription =
        _audioPlayer.playbackEventStream.listen(_onPlaybackEvent);

    final hiveFolder = await AppData.initHiveFolder();
    Hive.init(hiveFolder.path);
    Hive.registerAdapter(ClassPositionAdapter());
    _positionBox = await Hive.openBox<ClassPosition>('positions');

    await _completer.future;

    playbackStateSubscription.cancel();
    await _positionBox.close();
    await _audioPlayer.dispose();
  }

  @override
  void onPlay() => _onPlay();

  Future<void> _onPlay() async {
    if (await canPlay()) {
      if (_playerCompletedSubscription == null) {
        _playerCompletedSubscription = _audioPlayer.playbackStateStream
            /*
             * Goodness, this is embarrassing.
             * Problem: setUrl triggers a stopped event, which should *not*
             * playback to stop. I tried using a flag to keep track of whether
             * the stop is for *real* for real or not, but ended up going in a circle.
             * Now, I only listen for the stop event after playback starts. This in theory could cause
             * an issue if the user wants to stop before the file is loaded, but I don't think
             * that'll happen much...
             */
            .skip(1)
            .where((state) => state == AudioPlaybackState.stopped)
            .listen((_) => onStop());
      }

      // Make sure that we continue from where we left off.
      // If we're resuming a pause, we can just continue, but if we're coming from a stop we
      // have to check the cache.
      final startPosition =
          _audioPlayer.playbackState != AudioPlaybackState.paused
              ? _positionBox.get(mediaSource)?.position
              : null;

      _audioPlayer.play();

      if (startPosition != null) {
        _audioPlayer.seek(startPosition);
      }
    }
  }

  @override
  void onPause() {
    final state = _audioPlayer.playbackEvent.state;

    if (state == AudioPlaybackState.buffering ||
        state == AudioPlaybackState.playing) _audioPlayer.pause();
  }

  @override
  void onSeekTo(int position) => _seekTo(position);

  void _seekTo(int position) async {
    final interimState =
        position < _audioPlayer.playbackEvent.position.inMilliseconds
            ? BasicPlaybackState.rewinding
            : BasicPlaybackState.fastForwarding;

    AudioServiceBackground.setState(
      basicState: interimState,
      controls: _getControls(interimState),
      position: position,
      updateTime: DateTime.now().millisecondsSinceEpoch
    );

    await _audioPlayer.seek(Duration(milliseconds: position));

    if (AudioServiceBackground.state.basicState !=
        stateToStateMap[_audioPlayer.playbackEvent.state]) {
      _setState(state: stateToStateMap[_audioPlayer.playbackEvent.state]);
    }
  }

  @override
  void onClick(MediaButton button) => _onClick();

  void _onClick() async {
    // TODO: it would be great if general click on notification would open the app...
    if (await canPlay()) {
      onPlay();
    } else {
      onPause();
    }
  }

  @override
  void onStop() => _stop();

  void _stop() async {
    // Cancel the subscription to prevent this method being run a second time because of
    // the stop state from the audio player.
    await _cancelStopSubscription();
    await _updatePosition();

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
        position: _audioPlayer.playbackEvent?.updatePosition?.inMilliseconds ??
            Duration.zero,
        updateTime: _audioPlayer.playbackEvent?.updateTime?.inMilliseconds ??
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

  /// Don't end service because of stop state from player.
  Future _cancelStopSubscription() async {
    await _playerCompletedSubscription.cancel();
    _playerCompletedSubscription = null;
  }

  void _onPlaybackEvent(AudioPlaybackEvent event) {
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
        final state = AudioServiceBackground.state.basicState;

        // During seek don't send updates. This helps prevent UI jerkiness as it goes between
        // desired position and current postion.
        if (isSeeking(state)) {
          break;
        }

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

  Future<bool> canPlay() async {
    final state = await _audioPlayer.playbackStateStream
        .firstWhere((state) => state != AudioPlaybackState.connecting);

    return state == AudioPlaybackState.paused ||
        state == AudioPlaybackState.stopped;
  }

  /// Save the current position of currently playing class.
  Future<void> _updatePosition() async {
    final position = _audioPlayer.playbackEvent.position;

    if (_positionBox.containsKey(mediaSource)) {
      final classPosition = _positionBox.get(mediaSource);
      classPosition.position = position;
      await classPosition.save();
    } else {
      await _positionBox.put(
          mediaSource, ClassPosition(mediaId: mediaSource, position: position));
    }
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
