import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:hive/hive.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:inside_chassidus/data/repositories/class-position-repository.dart';
import 'package:inside_chassidus/util/audio-service/audio-task.dart';
import 'package:rxdart/rxdart.dart';

class MediaManager extends BlocBase {
  Stream<MediaState> get mediaState => _mediaSubject;
  Stream<WithMediaState<Duration>> get mediaPosition => _positionSubject;

  final ClassPositionRepository positionRepository;

  StreamSubscription<PlaybackState> _audioPlayerStateSubscription;

  BehaviorSubject<MediaState> _mediaSubject = BehaviorSubject();
  BehaviorSubject<WithMediaState<Duration>> _positionSubject =
      BehaviorSubject();

  // Ensure that seeks don't happen to frequently.
  final BehaviorSubject<Duration> _seekingValues = BehaviorSubject.seeded(null);

  MediaManager({this.positionRepository}) {
    _audioPlayerStateSubscription =
        AudioService.playbackStateStream.listen((state) {
      if (state != null && state.basicState != BasicPlaybackState.none) {
        _mediaSubject.value = current.copyWith(state: state.basicState);
      }
    });

    Rx.combineLatest4<PlaybackState, dynamic, Duration, MediaState,
                WithMediaState<Duration>>(
            AudioService.playbackStateStream
                .where((state) => state?.basicState != BasicPlaybackState.none),
            Stream.periodic(Duration(milliseconds: 20)),
            _seekingValues,
            _mediaSubject,
            (state, _, displaySeek, mediaState) =>
                _onPositionUpdate(state, displaySeek, mediaState))
        .listen((state) => _positionSubject.value = state);

    // Save the current position of media, in case user listens to another class and then comes back.
    mediaPosition.throttleTime(Duration(milliseconds: 200)).listen((state) =>
        positionRepository.updatePosition(current.media, state.data));

    _seekingValues
        .debounceTime(Duration(milliseconds: 50))
        .where((position) => position != null)
        .listen((position) => AudioService.seekTo(
            position.inMilliseconds < 0 ? 0 : position.inMilliseconds));
  }

  /// The media which is currently playing.
  MediaState get current => _mediaSubject.value;

  pause() => AudioService.pause();

  play(Media media) async {
    final serviceIsRunning = await AudioService.running;
    if (serviceIsRunning && media == _mediaSubject.value?.media) {
      AudioService.play();
      return;
    }

    if (!serviceIsRunning) {
      await AudioService.start(
          backgroundTaskEntrypoint: backgroundTaskEntrypoint,
          androidNotificationChannelName: "Inside Chassidus Class");
    }

    // While getting a file to play, we want to manually handle the state streams.
    _audioPlayerStateSubscription.pause();

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

    _audioPlayerStateSubscription.resume();

    // Continue a class from where it was left off.
    if (positionRepository.getPosition(media) != Duration.zero) {
      seek(media, positionRepository.getPosition(media));
    }
  }

  /// Updates the current location in given media.
  seek(Media media, Duration location) {
    if (media.source != _mediaSubject.value?.media?.source) {
      print('hmmm');
      return;
    }

    _seekingValues.add(location);
  }

  skip(Media media, Duration duration) async {
    final currentLocation = _positionSubject.value.data.inMilliseconds;
    seek(media, Duration(milliseconds: currentLocation) + duration);
  }

  WithMediaState<Duration> _onPositionUpdate(
      PlaybackState state, Duration displaySeek, MediaState mediaState) {
    if (state == null) {
      return WithMediaState(
          state: mediaState,
          data: Duration(
              milliseconds: AudioService.playbackState?.position ?? 0));
    }

    int position;

    if ((state.basicState == BasicPlaybackState.fastForwarding ||
            state.basicState == BasicPlaybackState.rewinding) &&
        displaySeek != null) {
      position = displaySeek.inMilliseconds;
    } else if (state.basicState != BasicPlaybackState.playing) {
      // If playback is paused, then we're in the same place as last update.
      position = state.position;
    } else {
      final timeSinceUpdate = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(state.updateTime));
      position = state.position + timeSinceUpdate.inMilliseconds;
    }

    return WithMediaState(
        state: mediaState, data: Duration(milliseconds: position));
  }

  @override
  void dispose() {
    _mediaSubject.close();
    _positionSubject.close();
    _seekingValues.close();
    super.dispose();
  }
}

backgroundTaskEntrypoint() async =>
    await AudioServiceBackground.run(() => AudioTask());

class MediaState {
  final Media media;
  final BasicPlaybackState state;
  final bool isLoaded;

  MediaState({this.media, this.state})
      : isLoaded = state != BasicPlaybackState.connecting &&
            state != BasicPlaybackState.error &&
            state != BasicPlaybackState.none;

  MediaState copyWith({Media media, BasicPlaybackState state}) =>
      MediaState(media: media ?? this.media, state: state ?? this.state);
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
