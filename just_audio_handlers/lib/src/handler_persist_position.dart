import 'package:audio_service/audio_service.dart';

class AudioHandlerPersistPosition extends CompositeAudioHandler {
  final PositionSaver positionRepository;

  AudioHandlerPersistPosition(AudioHandler inner,
      {required this.positionRepository})
      : super(inner);
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
