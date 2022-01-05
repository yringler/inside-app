import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_db_store/dio_cache_interceptor_db_store.dart';
import 'package:inside_data/inside_data.dart';
import 'package:inside_data/src/wordpress-base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suggested-content.g.dart';

class SuggestedContentLoader {
  final SiteDataLayer dataLayer;
  final String cachePath;
  late final Dio dio;

  CacheOptions get cacheOptions => CacheOptions(
      policy: CachePolicy.forceCache,
      maxStale: Duration(hours: 12),
      store: DbCacheStore(databasePath: cachePath, logStatements: false));

  SuggestedContentLoader({required this.dataLayer, required this.cachePath}) {
    dio = Dio()..interceptors.add(DioCacheInterceptor(options: cacheOptions));
  }

  /// Get suggested content.
  /// Doesn't request new data more than once every few hours.
  Future<SuggestedContent> load() async {
    final content =
        await Future.wait([_timelyContent(), _popular(), _featured()]);

    final suggestedContent = SuggestedContent(
        timelyContent: content[0] as TimelyContent,
        popular: content[1] as List<ContentReference>,
        featured: content[2] as List<FeaturedSectionVerified>);

    return suggestedContent;
  }

  Future<TimelyContent?> _timelyContent() async {
    try {
      final responses = await Future.wait([
        dio.get(
            'https://insidechassidus.org/wp-json/ics_recurring_api/v1/category',
            options: _options(Duration(days: 1))),
        dio.get(
            'https://insidechassidus.org/wp-json/ics_recurring_api/v1/daily',
            options: _options(Duration(hours: 3)))
      ]);

      final timelyResponse = responses[0];
      final dailyResponse = responses[1];

      final timelyContent =
          _TimelyContentResponse.fromJson(timelyResponse.data);
      final dailyContent = _DailyClasses.fromJson(dailyResponse.data);

      return TimelyContent(
          parsha: await _content(timelyContent.parsha),
          tanya: await _content(dailyContent.tanyaId),
          hayomYom: await _content(dailyContent.hayomYomId));
    } catch (err) {
      // Only throw in debug.
      // ignore: unnecessary_null_comparison
      assert(err == null);
      print(err);
      return null;
    }
  }

  Future<List<ContentReference>> _popular() async {
    try {
      final popularResponse = await dio.get<List<dynamic>>(
          'https://insidechassidus.org/wp-json/wordpress-popular-posts/v1/popular-posts',
          options: _options(Duration(days: 1)));

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
          .where((element) => element != null)
          .cast<ContentReference>()
          .toList();

      return popularData;
    } catch (err) {
      // Only throw in debug.
      // ignore: unnecessary_null_comparison
      assert(err == null);
      print(err);
      return [];
    }
  }

  Options _options(Duration stale) =>
      cacheOptions.copyWith(maxStale: stale).toOptions();

  Future<List<FeaturedSectionVerified>> _featured() async {
    try {
      final featuredResponse = await dio.get<List<dynamic>>(
          'https://insidechassidus.org/wp-json/ics_slider_api/v1/featured',
          options: _options(Duration(days: 1)));

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
    } catch (err) {
      // Only throw in debug.
      // ignore: unnecessary_null_comparison
      assert(err == null);
      print(err);
      return [];
    }
  }

  Future<ContentReference?> _content(int id) async =>
      ContentReference.fromDataOrNull(
          data: await dataLayer.mediaOrSection(id.toString()));
}

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
}

class TimelyContent {
  final ContentReference? parsha;
  final ContentReference? tanya;
  final ContentReference? hayomYom;

  bool get hasData => parsha != null || tanya != null || hayomYom != null;

  TimelyContent(
      {required this.parsha, required this.tanya, required this.hayomYom});
}

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
}

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
}

@JsonSerializable()
class _TimelyContentResponse {
  final int parsha;

  _TimelyContentResponse(this.parsha);

  factory _TimelyContentResponse.fromJson(Map<String, dynamic> json) =>
      _$TimelyContentResponseFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _DailyClasses {
  final int tanyaId;
  final int hayomYomId;

  _DailyClasses(this.tanyaId, this.hayomYomId);

  factory _DailyClasses.fromJson(Map<String, dynamic> json) =>
      _$DailyClassesFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _Featured {
  final String title;
  final int category;
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
