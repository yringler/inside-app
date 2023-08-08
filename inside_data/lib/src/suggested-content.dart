import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:inside_data/inside_data.dart';
import 'package:inside_data/src/logger.dart';
import 'package:inside_data/src/wordpress-base.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path/path.dart' as p;

part 'suggested-content.g.dart';

typedef FutureCallback<T> = Future<T?> Function();

class SuggestedContentLoader {
  final SiteDataLayer dataLayer;
  final String cachePath;
  final ILogger logger;

  /// Future that resolves when there is internet connection.
  final Future<void> isConnected;
  late final Dio dio;
  late final ValueStream<SuggestedContent> suggestedContent;

  SuggestedContentLoader(
      {required this.dataLayer,
      required this.cachePath,
      required this.isConnected,
      required this.logger}) {
    dio = Dio()..interceptors;
    suggestedContent = _contentStream().shareValue();
  }

  Stream<SuggestedContent> _contentStream() async* {
    final cacheFile = File(p.join(cachePath, 'suggested.json'));

    // Try to load from cache.
    // If the cache is old, we'll also load from APIs, after.
    if (await cacheFile.exists()) {
      try {
        final suggestedJson = jsonDecode(await cacheFile.readAsString());
        yield SuggestedContent.fromJson(suggestedJson);
      } catch (ex) {
        assert(ex == null, ex.toString());
        print(ex);
      }

      // Only request new data from API if the cache is more than 3 hours old.
      final staleDate =
          (await cacheFile.lastModified()).add(Duration(hours: 3));
      if (staleDate.isAfter(DateTime.now())) {
        return;
      }
    }

    await isConnected;

    final content = await _httpLoad();

    yield content;

    cacheFile.writeAsString(jsonEncode(content));
  }

  /// Get suggested content.
  /// Doesn't request new data more than once every few hours.
  Future<SuggestedContent> _httpLoad() async {
    final suggestedContent = SuggestedContent(
        timelyContent: await _nullIfException(_timelyContent),
        popular: await _nullIfException(_popular),
        featured: await _nullIfException(_featured));

    return suggestedContent;
  }

  Future<T?> _nullIfException<T>(FutureCallback<T> dataCall) async {
    try {
      return await dataCall();
    } on Error catch (e, s) {
      logger.logError(Exception(e.toString()), e.stackTrace ?? s);
    } on Exception catch (e, s) {
      logger.logError(e, s);
    }

    return null;
  }

  Future<TimelyContent?> _timelyContent() async {
    final responses = await Future.wait([
      dio.get(
          'https://insidechassidus.org/wp-json/ics_recurring_api/v1/category'),
      dio.get('https://insidechassidus.org/wp-json/ics_recurring_api/v1/daily')
    ]);

    final timelyResponse = responses[0];
    final dailyResponse = responses[1];

    final timelyContent = _TimelyContentResponse.fromJson(timelyResponse.data);
    final dailyContent = _DailyClasses.fromJson(dailyResponse.data);

    return TimelyContent(
        parsha: await _content(timelyContent.parsha),
        monthly: await _content(timelyContent.monthly),
        tanya: await _content(dailyContent.tanyaId),
        hayomYom: await _content(dailyContent.hayomYomId));
  }

  Future<List<ContentReference>> _popular() async {
    final popularResponse = await dio.get<List<dynamic>>(
        'https://insidechassidus.org/wp-json/wordpress-popular-posts/v1/popular-posts');

    if (popularResponse.data == null) {
      return [];
    }

    final popularData = (await Future.wait(popularResponse.data!
            .cast<Map<String, dynamic>>()
            .map(_PopularPost.fromJson)
            .map((e) async => e.type == ContentType.section
                ? ContentReference.fromDataOrNull(
                    data: await dataLayer.section(e.id.toString()))
                : await _content(e.id))
            .toList()))
        .where((element) => element?.hasValue ?? false)
        .cast<ContentReference>()
        .toList();

    return popularData;
  }

  Future<List<FeaturedSectionVerified>> _featured() async {
    final featuredResponse = await dio.get<List<dynamic>>(
        'https://insidechassidus.org/wp-json/ics_slider_api/v1/featured');

    if (featuredResponse.data == null) {
      return [];
    }

    final featuredData = (await Future.wait(featuredResponse.data!
            .cast<Map<String, dynamic>>()
            .map(_Featured.fromJson)
            .map((e) async => FeaturedSection(
                title: e.title,
                section: await dataLayer.section(e.category.toString()),
                imageUrl: e.imageUrl,
                buttonText: e.buttonText))
            .toList()))
        .where((element) => element.section != null)
        .map((e) => FeaturedSectionVerified(
            title: e.title,
            section: e.section!,
            imageUrl: e.imageUrl,
            buttonText: e.buttonText))
        .toList();

    return featuredData;
  }

  Future<ContentReference?> _content(int? id) async => id == null
      ? null
      : ContentReference.fromDataOrNull(
          data: await dataLayer.mediaOrSection(id.toString()));
}

@JsonSerializable()
class SuggestedContent {
  final TimelyContent? timelyContent;
  final List<ContentReference>? popular;
  final List<FeaturedSectionVerified>? featured;

  SuggestedContent(
      {TimelyContent? timelyContent,
      List<ContentReference>? popular,
      List<FeaturedSectionVerified>? featured})
      : timelyContent = timelyContent?.hasData ?? false ? timelyContent : null,
        popular = popular?.isNotEmpty ?? false ? popular : null,
        featured = featured?.isNotEmpty ?? false ? featured : null;

  factory SuggestedContent.fromJson(Map<String, dynamic> json) =>
      _$SuggestedContentFromJson(json);
  Map<String, dynamic> toJson() => _$SuggestedContentToJson(this);
}

@JsonSerializable()
class TimelyContent {
  final ContentReference? parsha;
  final ContentReference? tanya;
  final ContentReference? hayomYom;
  final ContentReference? monthly;

  bool get hasData =>
      parsha != null || tanya != null || hayomYom != null || monthly != null;

  TimelyContent(
      {required this.parsha,
      required this.tanya,
      required this.hayomYom,
      required this.monthly});

  factory TimelyContent.fromJson(Map<String, dynamic> json) =>
      _$TimelyContentFromJson(json);
  Map<String, dynamic> toJson() => _$TimelyContentToJson(this);
}

@JsonSerializable()
class FeaturedSection {
  final String title;
  final String imageUrl;
  final String buttonText;
  final Section? section;

  FeaturedSection(
      {required this.title,
      this.section,
      required this.imageUrl,
      required this.buttonText});

  factory FeaturedSection.fromJson(Map<String, dynamic> json) =>
      _$FeaturedSectionFromJson(json);
  Map<String, dynamic> toJson() => _$FeaturedSectionToJson(this);
}

@JsonSerializable()
class FeaturedSectionVerified {
  final String title;
  final String imageUrl;
  final String buttonText;
  final Section section;

  FeaturedSectionVerified(
      {required this.title,
      required this.section,
      required this.imageUrl,
      required this.buttonText});

  factory FeaturedSectionVerified.fromJson(Map<String, dynamic> json) =>
      _$FeaturedSectionVerifiedFromJson(json);
  Map<String, dynamic> toJson() => _$FeaturedSectionVerifiedToJson(this);
}

@JsonSerializable()
class _TimelyContentResponse {
  final int? parsha;
  final int? monthly;

  _TimelyContentResponse(this.parsha, this.monthly);

  factory _TimelyContentResponse.fromJson(Map<String, dynamic> json) =>
      _$TimelyContentResponseFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _DailyClasses {
  final int? tanyaId;
  final int? hayomYomId;

  _DailyClasses(this.tanyaId, this.hayomYomId);

  factory _DailyClasses.fromJson(Map<String, dynamic> json) =>
      _$DailyClassesFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _Featured {
  final String title;
  final int? category;
  final String imageUrl;
  final String buttonText;

  _Featured(this.title, this.category, this.imageUrl, this.buttonText);

  factory _Featured.fromJson(Map<String, dynamic> json) =>
      _$FeaturedFromJson(json);
}

@JsonSerializable()
class _PopularPost extends WordpressContent with DerivedResultType {
  final int id;
  final _PopularPostContent content;

  _PopularPost(this.id, this.content);

  @override
  String get postContentContent => content.rendered;

  @override
  String get postType => 'post';

  factory _PopularPost.fromJson(Map<String, dynamic> json) =>
      _$PopularPostFromJson(json);
}

@JsonSerializable()
class _PopularPostContent {
  final String rendered;

  _PopularPostContent(this.rendered);

  factory _PopularPostContent.fromJson(Map<String, dynamic> json) =>
      _$PopularPostContentFromJson(json);
}
