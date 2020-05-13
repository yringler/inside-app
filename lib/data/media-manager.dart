import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:hive/hive.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:inside_chassidus/data/repositories/recently-played-repository.dart';
import 'package:inside_chassidus/main.dart';
import 'package:inside_chassidus/util/audio-service/audio-task.dart';
import 'package:just_audio_service/position-manager.dart';
import 'package:rxdart/rxdart.dart';

class MediaManager extends BlocBase {
  /// Keep track of what's going on with the current media.
  Stream<MediaState> get mediaState => _mediaSubject;

  /// Save the current location in media
  final RecentlyPlayedRepository recentlyPlayedRepository;

  /// Keep track of what's going on with the current media.
  BehaviorSubject<MediaState> _mediaSubject = BehaviorSubject();

  /// Keep track of where we're currently holding in the media.
  BehaviorSubject<WithMediaState<Duration>> _positionSubject =
      BehaviorSubject();

  // Provides access to "UI" position - notably, provides smoother seeking for slider.
  final PositionManager _positionManager = PositionManager();

  Future<void> init() async {
    // Try to restore media state from already running audio_service.
    final newCurrent = await _getCurrentFromService();

    if (newCurrent != null) {
      _mediaSubject.value = MediaState(
          media: newCurrent, state: AudioService.playbackState.basicState);
    }

    // Listen for updates of audio state.
    AudioService.playbackStateStream.listen((state) {
      if (state != null && current != null) {
        // E.g. when user stops from lock screen, we miss the stop state and skip to none.
        // In this case, though, we treat it as stopped. Failing to do so means that the UI
        // thinks that the media is not yet loaded and needs to be, so it just waits forever.

        /* Disabled. TODO: test, see if this is still neccesary, and if there's a better way of handling. */

        // final newState = state.basicState == BasicPlaybackState.none
        //     ? BasicPlaybackState.stopped
        //     : state.basicState;

        if (state.basicState == BasicPlaybackState.stopped) {
          recentlyPlayedRepository.updatePosition(current.media, Duration.zero);
        }

        _mediaSubject.value =
            current.copyWith(state: state.basicState, speed: state.speed);
      }
    });
  }

  MediaManager({this.recentlyPlayedRepository});

  /// The media which is currently playing.
  MediaState get current => _mediaSubject.value;

  /// Stream of current position in media.
  Stream<WithMediaState<Duration>> get mediaPositionStream {
    return Rx.combineLatest2<Duration, MediaState, WithMediaState<Duration>>(
        _positionManager.positionStream,
        _mediaSubject,
        (position, state) =>
            WithMediaState<Duration>(state: state, data: position));
  }

  pause() => AudioService.pause();

  play(Media media) async {
    final serviceIsRunning = AudioService.running;

    // Resume playback if paused.
    if (serviceIsRunning && media == _mediaSubject.value?.media) {
      AudioService.play();
      return;
    }

    // Start playing a new media.

    MyApp.analytics.logEvent(name: "start_audio", parameters: {
      'class_source': media.source.limitFromEnd(100),
      'class_parent': media.lessonId.limitFromEnd(100)
    });

    if (!serviceIsRunning) {
      await AudioService.start(
          backgroundTaskEntrypoint: backgroundTaskEntrypoint,
          androidNotificationChannelName: "Inside Chassidus Class",
          androidStopForegroundOnPause: true);
    }

    // While getting a file to play, we want to manually handle the state streams.
    // Disabled. TODO: See if this is still needed.
    //_audioPlayerStateSubscription.pause();

    _mediaSubject.value =
        MediaState(media: media, state: BasicPlaybackState.connecting);

    await AudioService.playFromMediaId(media.source);

    var durationState = await AudioService.currentMediaItemStream
        .where((item) =>
            item != null &&
            item.duration != null &&
            item.id == media?.source &&
            item.duration > 0)
        .first;

    if (media.duration == null) {
      media.duration = Duration(milliseconds: durationState.duration);

      final lesson = await Hive.lazyBox<Lesson>('lessons').get(media.lessonId);
      lesson.audio
          .where((source) => source.source == media.source)
          .forEach((source) => source.duration = media.duration);
      await lesson.save();
    }

    _mediaSubject.value = current.copyWith(
        state: AudioService.playbackState.basicState, media: media);

    //_audioPlayerStateSubscription.resume();
  }

  /// Updates the current location in given media.
  seek(Media media, Duration location) {
    if (media.source != _mediaSubject.value?.media?.source) {
      print('hmmm');
      return;
    }

    _positionManager.seek(location);
  }

  skip(Media media, Duration duration) async =>
      seek(media, _positionManager.currentPosition + duration);

  setSpeed(int speed) => AudioService.customAction('setspeed', speed);

  @override
  void dispose() {
    _mediaSubject.close();
    _positionSubject.close();
    super.dispose();
  }

  /// Figure out what is currently playing (after app start) from audio_service
  Future<Media> _getCurrentFromService() async {
    final currentMediaId = AudioService.currentMediaItem?.id;

    if (currentMediaId?.isNotEmpty ?? false) {
      final currentPlaying =
          recentlyPlayedRepository.getRecentlyPlayed(currentMediaId);

      assert(currentPlaying != null,
          "There must be a record of currently playing lesson");

      // Find the media which is being played.
      // To do that, we figure out the lesson, and take it from there.
      final Lesson lesson = (await Hive.lazyBox<Lesson>('lessons')
              .get(currentPlaying.parentId)) ??
          await (await Hive.lazyBox<SiteSection>('sections')
                  .get(currentPlaying.parentId))
              .resolve();

      return lesson?.audio
          ?.firstWhere((audio) => audio.source == currentMediaId, orElse: null);
    }

    return null;
  }

  stop() => AudioService.stop();
}

backgroundTaskEntrypoint() async =>
    await AudioServiceBackground.run(() => LoggingAudioTask());

class MediaState {
  final Media media;
  final BasicPlaybackState state;
  final double speed;
  final bool isLoaded;

  MediaState({this.media, this.state, this.speed})
      : isLoaded = state != BasicPlaybackState.connecting &&
            state != BasicPlaybackState.error &&
            state != BasicPlaybackState.none;

  MediaState copyWith({Media media, BasicPlaybackState state, double speed}) =>
      MediaState(
          media: media ?? this.media,
          state: state ?? this.state,
          speed: speed ?? this.speed);
}

/// Allows strongly typed binding of media state with any other value.
/// For example, to associate a stram of audio postions with current file.
class WithMediaState<T> {
  final MediaState state;
  final T data;

  WithMediaState({this.state, this.data});

  WithMediaState<T> copyWith({MediaState state, T data}) =>
      WithMediaState(state: state ?? this.state, data: data ?? this.data);
}
