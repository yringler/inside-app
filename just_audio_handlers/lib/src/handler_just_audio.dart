import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

void setStartTime(Map<String, dynamic> extras, Duration start) {
  extras['playback-start'] = start;
}

Duration getStartTime(Map<String, dynamic> extras) =>
    extras['playback-start'] ?? Duration.zero;

Map<String, dynamic> setOverrideUri(Map<String, dynamic> extras, Uri uri) {
  extras['override-uri'] = uri;
  return extras;
}

Uri? getOverrideUri(Map<String, dynamic> extras) => extras['override-uri'];

class ExtraSettings {
  final Duration start;
  final Uri finalUri;

  ExtraSettings({required this.start, required this.finalUri});

  ExtraSettings.fromExtras(Map<String, dynamic>? extras,
      {required Uri defaultUri})
      : this(
            start: getStartTime(extras ?? {}),
            finalUri: getOverrideUri(extras ?? {}) ?? defaultUri);
}

/// Uses just_audio to handle playback.
/// Inherit to override getMediaItem, if you want to get metadata from a media id.
class AudioHandlerJustAudio extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player;

  AudioHandlerJustAudio({required player}) : _player = player {
    _player.playbackEventStream.listen(_broadcastState);
  }

  @override
  Future<void> prepareFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    if (uri.toString() == mediaItem.valueWrapper?.value?.id) {
      return;
    }

    final parsedExtras = ExtraSettings.fromExtras(extras, defaultUri: uri);
    await this.pause();
    mediaItem
        .add(MediaItem(id: uri.toString(), album: 'Classes', title: 'Class'));
    await _player.setAudioSource(AudioSource.uri(uri),
        initialPosition: parsedExtras.start);
  }

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    await prepareFromUri(uri, extras);
    await _player.play();
  }

  @override
  Future<void> prepareFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    if (mediaId == mediaItem.valueWrapper?.value?.id) {
      return;
    }

    final parsedExtras =
        ExtraSettings.fromExtras(extras, defaultUri: Uri.parse(mediaId));

    await this.pause();

    final item = await getMediaItem(mediaId);

    if (item == null) {
      await prepareFromUri(Uri.parse(mediaId), extras);
      return;
    }

    mediaItem.add(item);
    await _player.setAudioSource(AudioSource.uri(parsedExtras.finalUri),
        initialPosition: parsedExtras.start);
  }

  @override
  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    await prepareFromMediaId(mediaId);
    await _player.play();
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> seek(newPosition) async {}

  @override
  Future<void> setSpeed(double speed) async {}

  /// Broadcasts the current state to all clients.
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.valueWrapper!.value.copyWith(
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
