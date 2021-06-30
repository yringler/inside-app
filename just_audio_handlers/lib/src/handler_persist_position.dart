import 'dart:html';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio_handlers/src/extra_settings.dart';

/// Saves current position in media, and restores to that position when playback
/// starts.
class AudioHandlerPersistPosition extends CompositeAudioHandler {
  final PositionSaver positionRepository;

  AudioHandlerPersistPosition(AudioHandler inner,
      {required this.positionRepository})
      : super(inner);

  @override
  Future<void> prepareFromMediaId(String mediaId,
          [Map<String, dynamic>? extras]) async =>
      await super
          .prepareFromMediaId(mediaId, await _getExtras(mediaId, extras));

  @override
  Future<void> prepareFromUri(Uri uri, [Map<String, dynamic>? extras]) async =>
      await super.prepareFromUri(uri, await _getExtras(uri.toString(), extras));

  @override
  Future<void> playFromMediaId(String mediaId,
          [Map<String, dynamic>? extras]) async =>
      await super.playFromMediaId(mediaId, await _getExtras(mediaId, extras));

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async =>
      await super.playFromUri(uri, await _getExtras(uri.toString(), extras));

  @override
  Future<void> seek(Duration position) async {
    await super.seek(position);
    await positionRepository.set(mediaItem.value!.id, position);
  }

  @override
  Future<void> stop() async {
    await _save();
    await super.stop();
  }

  Future<void> _save() async {
    if (mediaItem.hasValue &&
        mediaItem.value != null &&
        playbackState.hasValue) {
      await positionRepository.set(
          mediaItem.value!.id, playbackState.value.position);
    }
  }

  Future<Map<String, dynamic>> _getExtras(
      String id, Map<String, dynamic>? extras) async {
    extras ??= {};
    ExtraSettings.setStartTime(extras, await positionRepository.get(id));
    return extras;
  }
}

abstract class PositionSaver {
  Future<void> set(String mediaId, Duration position);

  Future<Duration> get(String mediaId);
}

class MemoryPositionSaver extends PositionSaver {
  final Map<String, Duration> _positions = Map();

  @override
  Future<Duration> get(String mediaId) async =>
      _positions[mediaId] ?? Duration.zero;

  @override
  Future<void> set(String mediaId, Duration position) async =>
      _positions[mediaId] = position;
}

class HivePositionSaver extends PositionSaver {
  @override
  Future<Duration> get(String mediaId) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<void> set(String mediaId, Duration position) {
    // TODO: implement set
    throw UnimplementedError();
  }
}
