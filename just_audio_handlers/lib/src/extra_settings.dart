import 'package:audio_service/audio_service.dart';

class ExtraSettings {
  final Duration start;
  final Uri finalUri;
  final Uri originalUri;

  ExtraSettings(
      {required this.start, required this.originalUri, required this.finalUri});

  ExtraSettings.fromExtras(Map<String, dynamic>? extras,
      {required Uri defaultUri})
      : this(
            start: getStartTime(extras ?? {}),
            originalUri: getOriginalUri(extras ?? {}) ?? defaultUri,
            finalUri: getOverrideUri(extras ?? {}) ?? defaultUri);

  static Map<String, dynamic> setStartTime(
      Map<String, dynamic> extras, Duration start) {
    extras['playback-start'] = start.inMilliseconds;
    return extras;
  }

  static Duration getStartTime(Map<String, dynamic> extras) =>
      Duration(milliseconds: extras['playback-start'] ?? 0);

  static Map<String, dynamic> setOverrideUri(
      Map<String, dynamic> extras, Uri uri) {
    extras['override-uri'] = uri.toString();
    return extras;
  }

  static Uri? getOverrideUri(Map<String, dynamic> extras) =>
      extras['override-uri'] != null ? Uri.parse(extras['override-uri']) : null;

  static Uri? getOriginalUri(Map<String, dynamic> extras) =>
      extras['original-uri'] != null ? Uri.parse(extras['original-uri']) : null;

  static Uri getOriginalUriFromMediaItem(MediaItem item) =>
      getOriginalUri(item.extras ?? {}) ?? Uri.parse(item.id);

  static Map<String, dynamic> setOriginalUri(
      Map<String, dynamic> extras, Uri originalUri) {
    extras['original-uri'] = originalUri.toString();
    return extras;
  }
}
