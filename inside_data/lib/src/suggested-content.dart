import 'dart:convert';

import 'package:inside_data/inside_data.dart';
import 'package:inside_data/src/wordpress-base.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;

part 'suggested-content.g.dart';

class SuggestedContentLoader {
  final SiteDataLayer dataLayer;

  SuggestedContentLoader({required this.dataLayer});

  /// Get suggested content.
  /// Doesn't request new data more than once every few hours.
  Future<SuggestedContent> load() async {
    final content =
        await Future.wait([_timelyContent(), _popular(), _featured()]);

    final suggestedContent = SuggestedContent(
        timelyContent: content[0] as TimelyContent,
        popular: content[1] as List<ContentReference>,
        featured: content[2] as List<FeaturedSection>);

    return suggestedContent;
  }

  Future<TimelyContent?> _timelyContent() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse(
            'https://insidechassidus.org/wp-json/ics_recurring_api/v1/category')),
        http.get(Uri.parse(
            'https://insidechassidus.org/wp-json/ics_recurring_api/v1/daily'))
      ]);

      final timelyResponse = responses[0];
      final dailyResponse = responses[1];

      final timelyContent =
          _TimelyContentResponse.fromJson(json.decode(timelyResponse.body));
      final dailyContent =
          _DailyClasses.fromJson(json.decode(dailyResponse.body));

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
      final popularResponse = await http.get(Uri.parse(
          'https://insidechassidus.org/wp-json/wordpress-popular-posts/v1/popular-posts'));

      final popularData = (await Future.wait(
              (json.decode(popularResponse.body) as List<dynamic>)
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

  Future<List<FeaturedSectionVerified>> _featured() async {
    try {
      final featuredResponse = await http.get(Uri.parse(
          'https://insidechassidus.org/wp-json/ics_slider_api/v1/featured'));
      final featuredData = (await Future.wait(
              ((json.decode(featuredResponse.body) as List<dynamic>)
                  .cast<Map<String, dynamic>>()
                  .map(_Featured.fromJson)
                  .map((e) async => FeaturedSection(
                      title: e.title,
                      section: await dataLayer.section(e.category.toString()),
                      imageUrl: e.imageUrl,
                      buttonText: e.buttonText))
                  .toList())))
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
  final TimelyContent timelyContent;
  final List<ContentReference> popular;
  final List<FeaturedSection> featured;

  SuggestedContent(
      {required this.timelyContent,
      required this.popular,
      required this.featured});
}

class TimelyContent {
  final ContentReference? parsha;
  final ContentReference? tanya;
  final ContentReference? hayomYom;

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

@JsonSerializable()
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
