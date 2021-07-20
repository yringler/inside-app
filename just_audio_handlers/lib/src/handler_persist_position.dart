import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/src/hive_impl.dart';
import 'package:hive/hive.dart';
import 'package:just_audio_handlers/src/extra_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:quiver/async.dart';
import 'package:rxdart/rxdart.dart';

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
  final Map<String, BehaviorSubject<Duration>> _positionStreams = Map();

  @mustCallSuper
  Future<void> set(String? mediaId, Duration position,
      {AudioHandler? handler}) async {
    if (mediaId != null && _positionStreams.containsKey(mediaId)) {
      _positionStreams[mediaId]!.add(position);
    }
    if (handler != null) {
      if (mediaId == null) {
        handler.seek(position);
      } else if (handler.mediaItem.valueOrNull?.id == mediaId) {
        handler.seek(position);
      }
    }
  }

  Future<void> skip(String? mediaId, Duration skipAmount,
      {AudioHandler? handler}) async {
    Duration currentLocation;

    if (mediaId != null) {
      if (mediaId == handler?.mediaItem.valueOrNull?.id) {
        currentLocation =
            handler!.playbackState.valueOrNull?.position ?? Duration.zero;
      } else {
        currentLocation = await get(mediaId);
      }
    } else {
      currentLocation =
          handler!.playbackState.valueOrNull?.position ?? Duration.zero;
    }

    set(mediaId, currentLocation + skipAmount, handler: handler);
  }

  Future<Duration> get(String mediaId);

  @mustCallSuper
  Stream<Duration> getStream(String mediaId) =>
      FutureStream(getFutureStream(mediaId));

  Future<Stream<Duration>> getFutureStream(String mediaId) async {
    if (!_positionStreams.containsKey(mediaId)) {
      _positionStreams[mediaId] = BehaviorSubject.seeded(await get(mediaId));
    }

    return _positionStreams[mediaId]!;
  }
}

class MemoryPositionSaver extends PositionSaver {
  final Map<String, Duration> _positions = Map();

  @override
  Future<Duration> get(String mediaId) async =>
      _positions[mediaId] ?? Duration.zero;

  @override
  Future<void> set(String? mediaId, Duration position,
      {AudioHandler? handler}) async {
    mediaId ??= handler?.mediaItem.valueOrNull?.id;

    if (mediaId != null) {
      _positions[mediaId] = position;
    }

    await super.set(mediaId, position, handler: handler);
  }
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
  Future<void> set(String? mediaId, Duration position,
      {AudioHandler? handler}) async {
    mediaId ??= handler?.mediaItem.valueOrNull?.id;

    if (mediaId != null) {
      await _positionBox.put(
          mediaId.toHiveId(),
          PersistedPosition(
              milliseconds: position.inMilliseconds,
              modifiedDate: DateTime.now()));
    }

    await super.set(mediaId, position, handler: handler);
  }
}
