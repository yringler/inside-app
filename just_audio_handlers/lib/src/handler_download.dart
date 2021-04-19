import 'dart:async';

import 'package:audio_service/audio_service.dart';

class AudioHandlerDownloader extends CompositeAudioHandler {
  final AudioDownloader downloader;

  AudioHandlerDownloader(AudioHandler inner, {required this.downloader})
      : super(inner);

  /// Listen to command to download an audio file.
  @override
  Future<dynamic> customAction(String name, Map<String, dynamic>? extras);

  @override
  Future<void> prepareFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]);

  @override
  Future<void> prepareFromUri(Uri uri, [Map<String, dynamic>? extras]);

  @override
  Future<void> play();

  @override
  Future<void> playFromMediaId(String mediaId, [Map<String, dynamic>? extras]);

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]);
}

/// A progressing download.
class CreatedDownload {
  /// Notify when download is complete.
  final Completer<void> complete;

  /// The download destination.
  final Uri downloadedFile;

  CreatedDownload({required this.complete, required this.downloadedFile});
}

/// Common interface around downloading an audio file and checking state.
abstract class AudioDownloader {
  /// Returns the path to use as the audio source.
  /// If the file has been downloaded, returns the file path; otherwise, a noop.
  Future<Uri> getPlaybackUriFromId(String id);
  Future<Uri> getPlaybackUriFromUri(Uri uri);

  /// Get progress stream; .5 is 50% complete, 1 when done.
  Future<Stream<double>> getProgressFromId(String id);
  Future<Stream<double>> getProgressFromUri(Uri uri);

  Future<CreatedDownload> downloadFromId(String id);
  Future<CreatedDownload> downloadFromUri(Uri uri);
}
