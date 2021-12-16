import 'dart:async';

import 'package:just_audio_handlers/just_audio_handlers.dart';

/// Uses just_audio to handle playback.
/// Inherit to override getMediaItem, if you want to get metadata from a media id.
class AudioHandlerJustAudio extends BaseAudioHandler
    with SeekHandler, GetOriginalUri {
  final AudioPlayer _player;
  final String defaultAlbum;
  final String defaultClass;

  AudioHandlerJustAudio(
      {required player, String? defaultAlbum, String? defaultClass})
      : _player = player,
        this.defaultAlbum = defaultAlbum ?? '',
        this.defaultClass = defaultClass ?? '' {
    // This beautiful construct is copied from the audio_service example.
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> prepareFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    await _prepareMediaItem(
        extras ?? {},
        uri,
        MediaItem(
            id: uri.toString(),
            album: defaultAlbum,
            title: defaultClass,
            extras: extras));
  }

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    await prepareFromUri(uri, extras);
    await _player.play();
  }

  @override
  Future<void> prepareFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    if (_isPlaying(mediaId, extras)) return;

    // If the media ID is already being played, don't query it.
    // We may still want to update the player source, for example if
    // we are switching to play from an offline file.
    final item = mediaId == mediaItem.valueOrNull?.id
        ? mediaItem.value
        : await getMediaItem(mediaId);

    final startUri = await originalUri(mediaId: mediaId);

    // If we can't get media meta data, just play it like a regular Uri.
    if (item != null && startUri != null) {
      await _prepareMediaItem(extras ?? {}, startUri, item);
    } else {
      // IDK - should I throw?
      print('Error: could not get URI from media ID');
      await prepareFromUri(Uri.parse(mediaId), extras);
    }
  }

  @override
  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    await prepareFromMediaId(mediaId, extras);
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

  Future<void> _prepareMediaItem(
      Map<String, dynamic> extras, Uri defaultUri, MediaItem item) async {
    if (_isPlaying(defaultUri.toString(), extras)) return;

    final parsedExtras =
        ExtraSettings.fromExtras(extras, defaultUri: defaultUri);

    item = item.copyWith(extras: extras);

    mediaItem.add(item);

    final duration = await _player.setAudioSource(
        AudioSource.uri(parsedExtras.finalUri),
        initialPosition: parsedExtras.start);

    if (duration != null && duration != item.duration) {
      mediaItem.add(item.copyWith(duration: duration));
    }

    return;
  }

  bool _isPlaying(String id, Map<String, dynamic>? extras) {
    if (mediaItem.valueOrNull?.id == null) {
      return false;
    }

    final currentExtras = ExtraSettings.fromExtras(
        mediaItem.valueOrNull?.extras,
        defaultUri: Uri.parse(mediaItem.value!.id));
    final newExtras =
        ExtraSettings.fromExtras(extras, defaultUri: Uri.parse(id));

    return currentExtras.finalUri == newExtras.finalUri;
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
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
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
