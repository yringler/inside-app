import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio_handlers/just_audio_handlers.dart';
import 'package:rxdart/rxdart.dart';

class PositionState {
  get id => mediaItem.id;
  get position => state.position;
  final MediaItem mediaItem;
  final PlaybackState state;

  PositionState({required this.state, required this.mediaItem});
}

Stream<PositionState> getMediaItemState(AudioHandler audioHandler) =>
    Rx.combineLatest2<MediaItem, PlaybackState, PositionState>(
        audioHandler.mediaItem
            .where((event) => event != null)
            .map((event) => event!),
        audioHandler.playbackState,
        (a, b) => PositionState(state: b, mediaItem: a));

Stream<PositionState> getPositionState(AudioHandler audioHandler) =>
    Rx.combineLatest2<PositionState, Duration, PositionState>(
        getMediaItemState(audioHandler),
        AudioService.position,
        (a, b) => PositionState(
            mediaItem: a.mediaItem,
            state: a.state.copyWith(updatePosition: b)));

Stream<PositionState> getPositionStateFiltered(
        AudioHandler audioHandler, String mediaId) =>
    getPositionState(audioHandler).where((event) => event.id == mediaId);

Stream<Duration> getPositionStateWithPersisted(
        AudioHandler handler, PositionSaver saver,
        {required String mediaId}) =>
    Rx.merge<Duration>([
      getPositionStateFiltered(handler, mediaId)
          .map((event) => event.state.position),
      saver.getStream(mediaId)
    ]).shareReplay();

typedef Widget ButtonBuilder(IconData icon, VoidCallback onPressed);

class DownloadButton extends StatelessWidget {
  final AudioDownloader downloader;
  final String audioSource;
  final ButtonBuilder buttonBuilder;

  DownloadButton(
      {required this.downloader,
      required this.audioSource,
      required this.buttonBuilder});

  @override
  Widget build(BuildContext context) => StreamBuilder<DownloadTask>(
        stream: downloader.getDownloadStateStream(Uri.parse(audioSource)),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          final download = snapshot.data;

          if (download == null) {
            return ErrorWidget("Could not load download state");
          }

          if (download.status == DownloadTaskStatus.enqueued) {
            return CircularProgressIndicator();
          }

          if (download.status == DownloadTaskStatus.running) {
            // Ensure that there's always a visible loader.
            if (download.progress < 5) {
              return CircularProgressIndicator();
            }

            return CircularProgressIndicator(
              value: download.progress / 100.0,
            );
          }

          if (download.status == DownloadTaskStatus.complete) {
            return buttonBuilder(Icons.delete,
                () async => await limitDownloads(downloader, limit: 1));
          }

          return buttonBuilder(Icons.download, () {
            final uri = Uri.parse(audioSource);
            downloader.downloadFromUri(uri);
          });
        },
      );
}
