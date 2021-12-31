import 'package:inside_data/inside_data.dart';
import 'package:inside_data/src/wordpress-base.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;

class SuggestedContentLoader {
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

  Future<TimelyContent> _timelyContent() async {
    final responses = await Future.wait([
      http.get(Uri.parse(
          'https://insidechassidus.org/wp-json/ics_recurring_api/v1/category')),
      http.get(Uri.parse(
          'https://insidechassidus.org/wp-json/ics_recurring_api/v1/daily'))
    ]);

    final parshaResponse = responses[0];
    final dailyResponse = responses[1];
  }

  Future<List<ContentReference>> _popular() async {
    final popularResponse = await http.get(Uri.parse(
        'https://insidechassidus.org/wp-json/wordpress-popular-posts/v1/popular-posts'));
  }

  Future<List<FeaturedSection>> _featured() async {
    final featuredResponse = await http.get(Uri.parse(
        'https://insidechassidus.org/wp-json/ics_slider_api/v1/featured'));
  }
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
  final String parshaId;
  final String tanyaId;
  final String hayomYomId;

  TimelyContent(
      {required this.parshaId,
      required this.tanyaId,
      required this.hayomYomId});
}

class FeaturedSection {
  final String title;
  final String sectionId;
  final String imageUrl;
  final String buttonText;

  FeaturedSection(
      {required this.title,
      required this.sectionId,
      required this.imageUrl,
      required this.buttonText});
}

@JsonSerializable()
class _CategoryResponse {
  final int parsha;

  _CategoryResponse(this.parsha);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _DailyClasses {
  final int tanyaId;
  final int hayomYomId;

  _DailyClasses(this.tanyaId, this.hayomYomId);
}

class _Featured {
  final String title;
  final int category;
  final String imageUrl;
  final String buttonText;

  _Featured(this.title, this.category, this.imageUrl, this.buttonText);
}

class _PopularPost extends WordpressContent with DerivedResultType {
  final int id;
  final _PopularPostContent content;

  _PopularPost(this.id, this.content);

  @override
  String get postContentContent => content.rendered;

  @override
  String get postType => 'post';
}

class _PopularPostContent {
  final String rendered;

  _PopularPostContent(this.rendered);
}
