import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/src/hive_impl.dart';
import 'package:hive/hive.dart';
import 'package:just_audio_handlers/src/extra_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'handler_persist_position.g.dart';

/// Saves current position in media, and restores to that position when playback
/// starts.
class AudioHandlerPersistPosition extends CompositeAudioHandler {
  final PositionSaver positionRepository;

  AudioHandlerPersistPosition(
      {required this.positionRepository, required AudioHandler inner})
      : super(inner);

  @override
  Future<void> prepareFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    _save();
    await super.prepareFromMediaId(mediaId, await _getExtras(mediaId, extras));
  }

  @override
  Future<void> prepareFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    _save();
    await super.prepareFromUri(uri, await _getExtras(uri.toString(), extras));
  }

  @override
  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    _save();
    await super.playFromMediaId(mediaId, await _getExtras(mediaId, extras));
  }

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    _save();
    await super.playFromUri(uri, await _getExtras(uri.toString(), extras));
  }

  @override
  Future<void> seek(Duration position) async {
    await super.seek(position);
    // Save after the seek, in case the position isn't a valid position.
    await _save();
  }

  @override
  Future<void> pause() async {
    await super.pause();
    await _save();
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

  /// Adds saved start time, if set, to extra settings.
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

@HiveType(typeId: 0)
class PersistedPosition extends HiveObject {
  @HiveField(0)
  DateTime modifiedDate;

  @HiveField(1)
  int milliseconds;

  PersistedPosition({required this.modifiedDate, required this.milliseconds});
}

/// Make sure that the string is a valid HiveDb ID.
String extractID(String source) {
  final bigEnough = source.padLeft(220);
  return bigEnough.substring(bigEnough.length - 220);
}

extension HiveDbString on String {
  String toHiveId() {
    return extractID(this);
  }
}

class HivePositionSaver extends PositionSaver {
  static HiveImpl _hive = HiveImpl();
  static late Box<PersistedPosition> _positionBox;
  static const maxPositions = 200;

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    final path = (await getApplicationSupportDirectory()).path;
    _hive.init(p.join(path, 'hive_position'));
    _hive.registerAdapter(PersistedPositionAdapter());
    _positionBox = await _hive.openBox<PersistedPosition>('positions');

    if (_positionBox.length > maxPositions * 2) {
      final items = _positionBox.values.toList()
        ..sort((a, b) => a.modifiedDate.compareTo(b.modifiedDate));

      items.skip(maxPositions).forEach((e) => e.delete());
    }
  }

  @override
  Future<Duration> get(String mediaId) async {
    final positionMilliseconds =
        _positionBox.get(mediaId.toHiveId())?.milliseconds ?? 0;
    return Duration(milliseconds: positionMilliseconds);
  }

  @override
  Future<void> set(String mediaId, Duration position) async {
    await _positionBox.put(
        mediaId.toHiveId(),
        PersistedPosition(
            milliseconds: position.inMilliseconds,
            modifiedDate: DateTime.now()));
  }
}
