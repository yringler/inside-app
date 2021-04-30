import 'package:audio_service/audio_service.dart';

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
