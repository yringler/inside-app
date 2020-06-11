import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:just_audio/just_audio.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:just_audio_service/position-manager/positioned-audio-task.dart';

class LoggingAudioTask extends PositionedAudioTask {
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    // Log an analytics event when a lesson is finished.
    // Note that if someone listens to the same class 3 times in a row, it is only logged once.
    final logCompletedSubscription = context.mediaPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .map((state) => context.mediaItem.id)
        .distinct()
        .listen((id) => analytics.logEvent(
            name: "completed_class",
            parameters: {"class_source": id?.limitFromEnd(100) ?? ""}));

    await super.onStart(params);

    await logCompletedSubscription.cancel();
  }
}
