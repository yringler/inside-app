import 'package:audio_service/audio_service.dart';
import 'package:just_audio_handlers/just_audio_handlers.dart';

class LoggingJustAudioHandler extends CompositeAudioHandler {
  final AudioLogger logger;

  LoggingJustAudioHandler({required this.logger, required AudioHandler inner})
      : super(inner) {
    getMediaItemState(this)
        .where((event) =>
            event.state.processingState == AudioProcessingState.completed)
        .distinct((a, b) => a.mediaItem.id == b.mediaItem.id)
        .listen((event) => logger.onComplete(event.mediaItem));
  }
}

/// Callbacks which can be used for logging.
abstract class AudioLogger {
  /// Called when the given [MediaItem] is finished.
  Future<void> onComplete(MediaItem id) async {}
}
