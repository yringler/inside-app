import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio_handlers/src/extra_settings.dart';
import 'package:rxdart/subjects.dart';
import 'package:slugify/slugify.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:path_provider/path_provider.dart' as paths;
import 'package:path/path.dart' as p;

class AudioHandlerDownloader extends CompositeAudioHandler {
  final AudioDownloader downloader;

  AudioHandlerDownloader(
      {required this.downloader, required AudioHandler inner})
      : super(inner) {
    // If we finish downloading something which is currently playing, start playing
    // from downloaded file.
    downloader.completedStream.listen((uri) async {
      if (!mediaItem.hasValue || mediaItem.value == null) {
        return;
      }

      if (mediaItem.value!.id == uri.toString()) {
        Map<String, dynamic> extras = {};
        final start = playbackState.hasValue
            ? playbackState.value.position
            : Duration.zero;

        ExtraSettings.setStartTime(extras, start);
        ExtraSettings.setOverrideUri(extras, await getFilePath(uri));

        await playFromMediaId(mediaItem.value!.id, extras);
      }
    });
  }

  @override
  Future<void> prepareFromMediaId(String mediaId,
          [Map<String, dynamic>? extras]) async =>
      await super.prepareFromMediaId(
          mediaId, await _getExtras(Uri.parse(mediaId), extras));

  @override
  Future<void> prepareFromUri(Uri uri, [Map<String, dynamic>? extras]) async =>
      await super.prepareFromUri(uri, await _getExtras(uri, extras));

  @override
  Future<void> playFromMediaId(String mediaId,
          [Map<String, dynamic>? extras]) async =>
      await super.playFromMediaId(
          mediaId, (await _getExtras(Uri.parse(mediaId), extras)));

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async =>
      super.playFromUri(uri, await _getExtras(uri, extras));

  /// Returns extras, adding a final playback URL
  Future<Map<String, dynamic>> _getExtras(
      Uri mediaId, Map<String, dynamic>? extras) async {
    final finalUri = await downloader.getPlaybackUriFromUri(mediaId);
    extras = ExtraSettings.setOverrideUri(extras ?? {}, finalUri);
    return extras;
  }
}

/// A progressing download.
class CreatedDownload {
  /// The download destination.
  final Uri downloadedFile;

  final BehaviorSubject<double> progress;

  Future<double> get complete => progress.firstWhere((event) => event == 1);

  CreatedDownload({required this.downloadedFile, required this.progress});

  CreatedDownload copyWith(
          {Uri? downloadedFile, BehaviorSubject<double>? progress}) =>
      CreatedDownload(
          downloadedFile: downloadedFile ?? this.downloadedFile,
          progress: progress ?? this.progress);
}

/// Common interface around downloading an audio file and checking state.
abstract class AudioDownloader {
  /// Returns the path to use as the audio source.
  /// If the file has been downloaded, returns the file path; otherwise, a noop.
  Future<Uri> getPlaybackUriFromUri(Uri uri);

  /// Get progress stream; .5 is 50% complete, 1 when done.
  Future<BehaviorSubject<double>> getProgressFromUri(Uri uri);

  Future<CreatedDownload> downloadFromUri(Uri uri);

  /// Called when the given (web) uri has completed downloading.
  Stream<Uri> get completedStream;

  void destory();
}

/// Downloader implementation which uses flutter_downloader.
class FlutterDownloaderAudioDownloader extends AudioDownloader {
  /// Port to recieve all the progress updates from flutter_downloader.
  final ReceivePort _progressPort = ReceivePort();
  final ReceivePort _completedPort = ReceivePort();
  final StreamController<Uri> _downloadCompletedController =
      StreamController.broadcast();

  Map<String, CreatedDownload> _progressMap = {};
  Map<String, String> _idToUrlMap = {};

  FlutterDownloaderAudioDownloader() {
    IsolateNameServer.removePortNameMapping(fullProgressPortName);
    IsolateNameServer.registerPortWithName(
        _progressPort.sendPort, fullProgressPortName);

    _progressPort.listen(_onDownloadStatus);

    IsolateNameServer.removePortNameMapping(completedDownloadPortName);
    IsolateNameServer.registerPortWithName(
        _completedPort.sendPort, completedDownloadPortName);

    // Notify client that a download was finished.
    _completedPort.listen((arg) {
      String id = arg;
      assert(_idToUrlMap.containsKey(id));
      _downloadCompletedController.add(Uri.parse(_idToUrlMap[id]!));
    });
  }

  @override
  destory() {
    _downloadCompletedController.close();
  }

  /// One time static init. Aso inits flutter_download.
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(debug: true);
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  Stream<Uri> get completedStream => _downloadCompletedController.stream;

  @override
  Future<CreatedDownload> downloadFromUri(Uri uri) async {
    final downloadTask = await _getStatus(uri);
    final status = downloadTask.status;

    String? id;

    if (status == DownloadTaskStatus.canceled ||
        status == DownloadTaskStatus.failed ||
        status == DownloadTaskStatus.undefined) {
      id = await FlutterDownloader.enqueue(
          url: uri.toString(),
          savedDir: await getDownloadFolder(),
          fileName: getFileName(uri: uri),
          openFileFromNotification: false);
    } else if (status == DownloadTaskStatus.paused) {
      id = await FlutterDownloader.resume(taskId: downloadTask.taskId) ??
          downloadTask.taskId;
    }

    if (id != null) {
      _idToUrlMap[id.toString()] = uri.toString();
    }

    return _getProgressOrDefault(downloadTask);
  }

  @override
  Future<Uri> getPlaybackUriFromUri(Uri uri) async {
    final status = (await _getStatus(uri));

    return status.status == DownloadTaskStatus.complete
        ? await getFilePath(uri)
        : uri;
  }

  @override
  Future<BehaviorSubject<double>> getProgressFromUri(Uri uri) async =>
      (await _getProgressOrDefault(await _getStatus(uri))).progress;

  /// Returns the download progress from the map, adding it if it isn't there.
  Future<CreatedDownload> _getProgressOrDefault(DownloadTask task) async =>
      _progressMap[task.taskId] ??= CreatedDownload(
          downloadedFile: await getFilePath(Uri.parse(task.url)),
          progress: BehaviorSubject.seeded(task.progress / 100.0));

  Future<DownloadTask> _getStatus(Uri uri) async {
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
        query: 'SELECT * FROM task WHERE url like \'$uri\'');

    if (tasks?.isEmptyOrNull ?? true) {
      return DownloadTask(
          status: DownloadTaskStatus.undefined,
          progress: 0,
          filename: '',
          savedDir: '',
          taskId: '',
          timeCreated: 0,
          url: '');
    }

    return tasks!.single;
  }

  /// UI thread, called when the UI reciever port gets a message from the background
  /// download isolate.
  void _onDownloadStatus(data) async {
    final String id = data[0];
    final int progress = data[2];

    if (!_progressMap.containsKey(id)) {
      final task = (await FlutterDownloader.loadTasksWithRawQuery(
              query: 'SELECT * FROM task WHERE task_id = \'$id\''))!
          .single;

      await _getProgressOrDefault(task);
    }

    _progressMap[id]!.progress.add(progress / 100.0);
  }
}

/// Name of port which provides access to the full download progress.
const fullProgressPortName = 'downloader_send_port';

/// Name of port which just reports when a download is completed.
const completedDownloadPortName = 'completed_send_port';

void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  IsolateNameServer.lookupPortByName(fullProgressPortName)
      ?.send([id, status, progress]);

  if (status == DownloadTaskStatus.complete) {
    IsolateNameServer.lookupPortByName(completedDownloadPortName)?.send(id);
  }
}

/// Convert URL into a valid file name for android and iOS
String getFileName({required Uri uri}) {
  // Android is around 150, iOS is closer to 200, but this should be unique and
  // not cause errors.
  const maxSize = 120;

  final fileName = uri.pathSegments.last;
  final nameParts = fileName.split('.');
  final suffix = nameParts.removeLast();
  final sluggifiedName = slugify(nameParts.join(), delimiter: '_');

  return sluggifiedName.limitFromStart(maxSize)! + '.$suffix';
}

Future<String> getDownloadFolder() async => (Platform.isIOS
        ? await paths.getApplicationDocumentsDirectory()
        : await paths.getExternalStorageDirectory())!
    .path;

Future<Uri> getFilePath(Uri uri) async =>
    Uri.file(p.join(await getDownloadFolder(), getFileName(uri: uri)));
