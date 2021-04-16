import 'package:audio_service/audio_service.dart';

class AudioHandlerDownloader extends CompositeAudioHandler {
  AudioHandlerDownloader(AudioHandler inner) : super(inner);

  /// Listen to command to download an audio file.
  /// Returns the flutter_download task ID
  @override
  Future<dynamic> customAction(String name, Map<String, dynamic>? extras);
}
