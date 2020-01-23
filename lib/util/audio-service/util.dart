import 'package:audio_service/audio_service.dart';

bool isSeeking(BasicPlaybackState state) {
  return state == BasicPlaybackState.fastForwarding ||
      state == BasicPlaybackState.rewinding;
}
