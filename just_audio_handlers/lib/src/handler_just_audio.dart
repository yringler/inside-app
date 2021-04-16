import 'package:audio_service/audio_service.dart';

/// Uses just_audio to handle playback.
class AudioHandlerJustAudio extends BaseAudioHandler with SeekHandler {
  @override
  Future<void> prepareFromUri(Uri uri, [Map<String, dynamic>? extras]) async {}

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> seek(newPosition) async {}

  @override
  Future<void> setSpeed(double speed) async {}
}
