import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_handlers/src/extra_settings.dart';

/// Uses just_audio to handle playback.
/// Inherit to override getMediaItem, if you want to get metadata from a media id.
class AudioHandlerJustAudio extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player;
  final Map<String, String> _fileUriToOriginalId = {};

  AudioHandlerJustAudio({required player}) : _player = player {
    _player.playbackEventStream.listen(_broadcastState);
  }

  @override
  Future<void> prepareFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    if (mediaItem.hasValue && uri.toString() == mediaItem.value?.id) {
      return;
    }

    await _prepareMediaItem(extras ?? {}, uri,
        MediaItem(id: uri.toString(), album: 'Classes', title: 'Class'));
  }

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    await prepareFromUri(uri, extras);
    await _player.play();
  }

  @override
  Future<void> prepareFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    if (mediaItem.hasValue && mediaId == mediaItem.value?.id) {
      return;
    }

    final item = await getMediaItem(mediaId);

    // If we can't get media meta data, just play it like a regular Uri.
    if (item == null) {
      await prepareFromUri(Uri.parse(mediaId), extras);
      return;
    }

    final duration =
        await _prepareMediaItem(extras ?? {}, Uri.parse(mediaId), item);

    if (duration != item.duration) {
      mediaItem.add(item.copyWith(duration: duration));
    }
  }

  @override
  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    await prepareFromMediaId(mediaId);
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  Future<void> seek(newPosition) async {
    await _player.seek(newPosition);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  Future _prepareMediaItem(
      Map<String, dynamic> extras, Uri defaultUri, MediaItem item) async {
    final parsedExtras =
        ExtraSettings.fromExtras(extras, defaultUri: defaultUri);

    await this.pause();

    _fileUriToOriginalId[parsedExtras.finalUri.toString()] = item.id;

    mediaItem.add(item);
    await _player.setAudioSource(AudioSource.uri(parsedExtras.finalUri),
        initialPosition: parsedExtras.start);
  }

  /// Broadcasts the current state to all clients.
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    ));
  }
}
