import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:rxdart/subjects.dart';

class AudioHandlerDownloader extends CompositeAudioHandler {
  final AudioDownloader downloader;

  AudioHandlerDownloader(AudioHandler inner, {required this.downloader})
      : super(inner);

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

  final BehaviorSubject<double> progress;

  CreatedDownload(
      {required this.complete,
      required this.downloadedFile,
      required this.progress});
}

/// Common interface around downloading an audio file and checking state.
abstract class AudioDownloader {
  /// Returns the path to use as the audio source.
  /// If the file has been downloaded, returns the file path; otherwise, a noop.
  Future<Uri> getPlaybackUriFromUri(Uri uri);

  /// Get progress stream; .5 is 50% complete, 1 when done.
  Future<BehaviorSubject<double>> getProgressFromUri(Uri uri);

  Future<CreatedDownload> downloadFromUri(Uri uri);
}

/// Loads all download data on load from flutter_downloader DB.
/// Keeps all downloaded data in memory, updating as further downloads are made.
class FlutterDownloaderAudioDownloader extends AudioDownloader {
  @override
  Future<CreatedDownload> downloadFromUri(Uri uri) {
    // TODO: implement downloadFromUri
    throw UnimplementedError();
  }

  @override
  Future<Uri> getPlaybackUriFromId(String id) {
    // TODO: implement getPlaybackUriFromId
    throw UnimplementedError();
  }

  @override
  Future<Uri> getPlaybackUriFromUri(Uri uri) {
    // TODO: implement getPlaybackUriFromUri
    throw UnimplementedError();
  }

  @override
  Future<BehaviorSubject<double>> getProgressFromUri(Uri uri) {
    // TODO: implement getProgressFromUri
    throw UnimplementedError();
  }
}
