import 'dart:convert';
import 'dart:io';
import 'package:inside_data/inside_data.dart';
import 'package:http/http.dart' as http;
import 'package:inside_data/src/loaders/wordpress/parsing_tools.dart';
import 'package:inside_data/src/loaders/wordpress/wordpress.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wordpress_search.g.dart';

class WordpressSearch extends Wordpress {
  static const searchApiPath =
      'wp-content/plugins/elasticpress-custom/proxy/proxy.php';

  WordpressSearch({required String wordpressDomain})
      : super(wordpressDomain: wordpressDomain);

  Future<List<SearchResultItem>> search(String term) async {
    SearchResponseRoot resultResponse;

    try {
      resultResponse = await _fetchSearchResults(term);
    } catch (err) {
      print(err);
      // Fail in debug mode, but not in production.
      assert(false);
      return [];
    }

    final response = resultResponse.responses
        .map((e) => e.hits.hits.map((e) => e.source))
        .expand((element) => element)
        .toList();

    return response;
  }

  Future<SearchResponseRoot> _fetchSearchResults(String term) async {
    final url = '$wordpressDomain/$searchApiPath?term=$term';
    final coreResponse = await http.get(Uri.parse(url));

    if (coreResponse.statusCode == HttpStatus.ok) {
      return SearchResponseRoot.fromJson(jsonDecode(coreResponse.body));
    } else {
      return Future.error(coreResponse);
    }
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SearchResultItem {
  final String id;

  final String postType;

  final String postContent;

  final String postContentFiltered;

  /// Yeah, bad name. There are 2 contents returned by wordpress, takes better.
  String get postContentContent =>
      postContent.trim().isNotEmpty ? postContent : postContentFiltered;

  SearchResultItem(
      {required this.postType,
      required this.postContent,
      required this.postContentFiltered,
      required this.id});

  factory SearchResultItem.fromJson(Map<String, dynamic> json) =>
      _$SearchResultItemFromJson(json);

  ContentType? get type {
    if (postType != 'post') {
      return ContentType.section;
    }

    // If it's a post, it might still be a section, if the post contains more than one media.

    final content = parsePost(
        SiteDataBase(
            id: id,
            title: '',
            description: postContentContent,
            sort: 0,
            link: '',
            parents: {}),
        requireAudio: false);

    if (content == null) {
      return null;
    }

    if (content is Media) {
      return ContentType.media;
    }

    return ContentType.section;
  }
}

@JsonSerializable()
class SearchResponseResult {
  @JsonKey(name: '_source')
  final SearchResultItem source;

  SearchResponseResult({required this.source});

  factory SearchResponseResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseResultFromJson(json);
}

@JsonSerializable()
class SearchResponseItem {
  final List<SearchResponseResult> hits;

  SearchResponseItem(this.hits);

  factory SearchResponseItem.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseItemFromJson(json);
}

@JsonSerializable()
class SearchResponseItemParent {
  final SearchResponseItem hits;

  SearchResponseItemParent({required this.hits});

  factory SearchResponseItemParent.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseItemParentFromJson(json);
}

@JsonSerializable()
class SearchResponseRoot {
  final List<SearchResponseItemParent> responses;

  SearchResponseRoot({required this.responses});

  factory SearchResponseRoot.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseRootFromJson(json);
}
