import 'dart:html';

import 'package:audio_service/audio_service.dart';

/// Saves current position in media, and restores to that position when playback
/// starts.
class AudioHandlerPersistPosition extends CompositeAudioHandler {
  final PositionSaver positionRepository;

  AudioHandlerPersistPosition(AudioHandler inner,
      {required this.positionRepository})
      : super(inner);

  @override
  Future<void> prepareFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {}

  @override
  Future<void> prepareFromUri(Uri uri, [Map<String, dynamic>? extras]) async {}

  @override
  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {}

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> stop() async {}
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
