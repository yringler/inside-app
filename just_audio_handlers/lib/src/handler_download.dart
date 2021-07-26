import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio_handlers/src/extra_settings.dart';
import 'package:quiver/async.dart';
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
      if (!mediaItem.hasValue ||
          mediaItem.value == null ||
          mediaItem.value!.id != uri.toString()) {
        return;
      }

      Map<String, dynamic> extras = {};
      final start = playbackState.valueOrNull?.position ?? Duration.zero;

      ExtraSettings.setStartTime(extras, start);
      ExtraSettings.setOverrideUri(extras, await _getFilePath(uri));

      await playFromMediaId(mediaItem.value!.id, extras);
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

/// Common interface around downloading an audio file and checking state.
abstract class AudioDownloader {
  /// Returns the path to use as the audio source.
  /// If the file has been downloaded, returns the file path; otherwise, a noop.
  Future<Uri> getPlaybackUriFromUri(Uri uri);

  Stream<DownloadTask> getDownloadStateStream(Uri uri);

  Future<DownloadTask> downloadFromUri(Uri uri);

  /// Called when the given (web) uri has completed downloading.
  Stream<Uri> get completedStream;

  Future<void> remove(String id);

  Future<List<DownloadTask>> getAllDownloaded();

  void destory();
}

/// Downloader implementation which uses flutter_downloader.
class FlutterDownloaderAudioDownloader extends AudioDownloader {
  /// Port to recieve all the progress updates from flutter_downloader.
  final ReceivePort _progressPort = ReceivePort();
  final ReceivePort _completedPort = ReceivePort();
  final StreamController<Uri> _downloadCompletedController =
      StreamController.broadcast();

  Map<String, BehaviorSubject<DownloadTask>> _progressMap = {};
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
  Future<DownloadTask> downloadFromUri(Uri uri) async {
    final downloadTask = (await _getCachedTask(uri)).value;
    final status = downloadTask.status;

    String? id;

    if (status == DownloadTaskStatus.canceled) {
      id = await FlutterDownloader.retry(taskId: downloadTask.taskId);
    } else if (status == DownloadTaskStatus.failed ||
        status == DownloadTaskStatus.undefined) {
      id = await FlutterDownloader.enqueue(
          url: uri.toString(),
          savedDir: await _getDownloadFolder(),
          fileName: getFileName(uri: uri),
          openFileFromNotification: false);
    } else if (status == DownloadTaskStatus.paused) {
      id = await FlutterDownloader.resume(taskId: downloadTask.taskId);
    }

    id ??= downloadTask.taskId;

    assert(id.isNotEmpty);

    if (id.isNotEmpty) {
      _idToUrlMap[id.toString()] = uri.toString();
      return await _getTaskById(id);
    }

    return downloadTask;
  }

  @override
  Future<Uri> getPlaybackUriFromUri(Uri uri) async =>
      (await _getCachedTask(uri)).value.status == DownloadTaskStatus.complete
          ? await _getFilePath(uri)
          : uri;

  @override
  Stream<DownloadTask> getDownloadStateStream(Uri uri) =>
      FutureStream(_getCachedTask(uri));

  @override
  Future<void> remove(String id) async {
    final url = _idToUrlMap[id];

    if (url != null) {
      // Flutter downloader doesn't save the final URI (which can change
      // between updates on iOS), so we delete the file based on a seperate data set
      // that we keep track of, not from the flutter_downloader DB.

      final file = File.fromUri(await _getFilePath(Uri.parse(url)));

      if (await file.exists()) {
        await file.delete();
      }
    }

    // The try is in case the task was already removed...
    // The finally is to make sure that the client knows that (now that it's been
    // deleted) no progress has been made on the download.

    try {
      await FlutterDownloader.remove(taskId: id);
    } finally {
      if (!url.isEmptyOrNull) {
        _progressMap[url]?.add(await _getTask(Uri.parse(url!)));
      }
    }
  }

  /// UI thread, called when the UI reciever port gets a message from the background
  /// download isolate.
  void _onDownloadStatus(data) async {
    final String id = data[0];
    final DownloadTaskStatus status = data[1];
    final int progress = data[2];

    if (!_idToUrlMap.containsKey(id) ||
        !_progressMap.containsKey(_idToUrlMap[id])) {
      final task = await _getTaskById(id);

      _progressMap[task.url] ??= BehaviorSubject.seeded(task);
      _idToUrlMap[id] = task.url;
    }

    // ignore: close_sinks
    final currentSubject = _progressMap[_idToUrlMap[id]]!;

    currentSubject.add(DownloadTask(
        taskId: id,
        status: status,
        progress: progress,
        url: _idToUrlMap[id]!,
        filename: currentSubject.value.filename,
        savedDir: currentSubject.value.savedDir,
        timeCreated: currentSubject.value.timeCreated));
  }

  Future<BehaviorSubject<DownloadTask>> _getCachedTask(Uri uri) async {
    final task = await _getTask(uri);

    if (!task.taskId.isEmptyOrNull) {
      _idToUrlMap[task.taskId] = task.url;
    }

    return _progressMap[uri.toString()] ??= BehaviorSubject.seeded(task);
  }

  @override
  Future<List<DownloadTask>> getAllDownloaded() async {
    return ((await FlutterDownloader.loadTasks()) ?? []);
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

Future<String> _getDownloadFolder() async => (Platform.isIOS
        ? await paths.getApplicationDocumentsDirectory()
        : await paths.getExternalStorageDirectory())!
    .path;

Future<Uri> _getFilePath(Uri uri) async =>
    Uri.file(p.join(await _getDownloadFolder(), getFileName(uri: uri)));

Future<DownloadTask> _getTask(Uri uri) async {
  // Any pause etc during download creates a new download task.
  // Make sure to get most recent.
  final tasks = await FlutterDownloader.loadTasksWithRawQuery(
      query:
          'SELECT * FROM task WHERE url like \'$uri\' ORDER BY time_created desc LIMIT 1');

  final emptyTask = DownloadTask(
      status: DownloadTaskStatus.undefined,
      progress: 0,
      filename: '',
      savedDir: '',
      taskId: '',
      timeCreated: 0,
      url: uri.toString());

  if (tasks?.isEmptyOrNull ?? true) {
    return emptyTask;
  }

  final task = tasks!.single;

  if (!await ensureValidExists(task)) {
    return emptyTask;
  }

  return task;
}

/// Returns true if the file is downloaded and exists, or if the file wasn't downloaded yet.
/// Returns false if the sytem thinks it was downloaded, but the file doesn't exist.
Future<bool> ensureValidExists(DownloadTask task) async {
  if (task.status == DownloadTaskStatus.complete) {
    final path = await _getFilePath(Uri.parse(task.url));
    final exists = await File(path.toString()).exists();

    if (!exists) {
      await FlutterDownloader.remove(taskId: task.taskId);
      return false;
    }

    return true;
  }

  return true;
}

Future<void> limitDownloads(AudioDownloader downloader,
    {int limit = 10}) async {
  final tasks = await downloader.getAllDownloaded();
  final validatedTasks = (await Future.wait(tasks
          .map((task) async => await ensureValidExists(task) ? task : null)))
      .where((element) => element != null)
      .map((e) => e!);
  final completedTasks = validatedTasks
      .where((element) => element.status == DownloadTaskStatus.complete)
      .toList();

  final numberToDelete = completedTasks.length - limit;

  if (numberToDelete < 0) {
    return;
  }

  completedTasks.sortBy((k) => k.timeCreated);
  await Future.wait(completedTasks
      .take(numberToDelete)
      .map((e) => downloader.remove(e.taskId)));
}

Future<DownloadTask> _getTaskById(String id) async =>
    (await FlutterDownloader.loadTasksWithRawQuery(
            query: 'SELECT * FROM task WHERE task_id = \'$id\''))!
        .single;
