/*
 * This file is pretty much copied vertebim from the https://github.com/ryanheise/audio_service example
 * Just using our just_audio_handler instead of theirs.
 */

// ignore_for_file: public_member_api_docs

// FOR MORE EXAMPLES, VISIT THE GITHUB REPOSITORY AT:
//
//  https://github.com/ryanheise/audio_service
//
// This example implements a minimal audio handler that renders the current
// media item and playback state to the system notification and responds to 4
// media actions:
//
// - play
// - pause
// - seek
// - stop
//
// To run this example, use:
//
// flutter run

import 'dart:async';

import 'package:example/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_handlers/just_audio_handlers.dart';

// You might want to provide this using dependency injection rather than a
// global variable.
late AudioHandler _audioHandler;
late FlutterDownloaderAudioDownloader _downloader;
late HivePositionSaver _positionSaver;

const _audioSource1 =
    'https://legacy.insidechassidus.org/wp-content/uploads/48-Which-One-Should-I-Learn-By-Heart.mp4';
const _audioSource2 =
    'https://legacy.insidechassidus.org/wp-content/uploads/Classes/Life%20Lessons/faith/A_good_world.mp3';

Future<void> main() async {
  await HivePositionSaver.init();
  await FlutterDownloaderAudioDownloader.init();

  _downloader = FlutterDownloaderAudioDownloader();
  _positionSaver = HivePositionSaver();

  _audioHandler = await AudioService.init(
    builder: () => AudioHandlerDownloader(
        downloader: _downloader,
        inner: AudioHandlerPersistPosition(
          positionRepository: _positionSaver,
          inner: AudioHandlerJustAudio(player: AudioPlayer()),
        )),
    config: AudioServiceConfig(
        androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Service Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Service Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show media item title
            StreamBuilder<MediaItem?>(
              stream: _audioHandler.mediaItem,
              builder: (context, snapshot) {
                final mediaItem = snapshot.data;
                return Text(mediaItem?.title ?? '');
              },
            ),
            // Play/pause/stop buttons.
            StreamBuilder<bool>(
              stream: _audioHandler.playbackState
                  .map((state) => state.playing)
                  .distinct(),
              builder: (context, snapshot) {
                final playing = snapshot.data ?? false;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _button(Icons.fast_rewind, _audioHandler.rewind),
                    StreamBuilder<String>(
                      stream: _audioHandler.mediaItem
                          .map((event) => event?.id ?? _audioSource1),
                      builder: (context, snap) => _button(
                          Icons.next_plan_outlined,
                          () => _audioHandler.playFromUri(Uri.parse(
                              snap.data == _audioSource1
                                  ? _audioSource2
                                  : _audioSource1))),
                    ),
                    if (playing)
                      _button(Icons.pause, _audioHandler.pause)
                    else
                      StreamBuilder<String>(
                        stream: _audioHandler.mediaItem
                            .map((event) => event?.id ?? _audioSource1),
                        builder: (context, snap) => _button(
                            Icons.play_arrow,
                            () => _audioHandler
                                .playFromUri(Uri.parse(snap.data!))),
                      ),
                    _button(Icons.stop, _audioHandler.stop),
                    _button(Icons.fast_forward, _audioHandler.fastForward),
                    StreamBuilder<String>(
                      stream: _audioHandler.mediaItem
                          .map((event) => event?.id ?? _audioSource1),
                      builder: (context, snap) => DownloadButton(
                          audioSource: snap.data ?? '',
                          buttonBuilder: _button,
                          downloader: _downloader),
                    )
                  ],
                );
              },
            ),
            // A seek bar.
            StreamBuilder<PositionState>(
              stream: getPositionState(_audioHandler),
              builder: (context, snapshot) {
                final mediaState = snapshot.data;
                return SeekBar(
                  duration: mediaState?.mediaItem.duration ?? Duration.zero,
                  position: mediaState?.state.position ?? Duration.zero,
                  onChangeEnd: (newPosition) {
                    _audioHandler.seek(newPosition);
                  },
                );
              },
            ),
            // Display the processing state.
            StreamBuilder<AudioProcessingState>(
              stream: _audioHandler.playbackState
                  .map((state) => state.processingState)
                  .distinct(),
              builder: (context, snapshot) {
                final processingState =
                    snapshot.data ?? AudioProcessingState.idle;
                return Text(
                    "Processing state: ${describeEnum(processingState)}");
              },
            ),
            StreamBuilder<String>(
              stream: _audioHandler.mediaItem
                  .map((event) => event?.id ?? _audioSource1),
              builder: (context, snap) => Text(snap.data ?? ''),
            )
          ],
        ),
      ),
    );
  }

  Widget _button(IconData iconData, VoidCallback onPressed) => IconButton(
        icon: Icon(iconData),
        iconSize: 40.0,
        onPressed: onPressed,
      );
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}
