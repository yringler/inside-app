import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:inside_data/inside_data.dart';
import 'package:http/http.dart' as http;
import 'package:inside_data/src/loaders/wordpress/parsing_tools.dart';
import 'package:inside_data/src/loaders/wordpress/wordpress.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wordpress_search.g.dart';

class WordpressSearch extends Wordpress {
  final Map<String, CompleterState<List<SearchResultItem>>> _resultCache = {};

  static const searchApiPath =
      'wp-content/plugins/elasticpress-custom/proxy/proxy.php';

  WordpressSearch({required String wordpressDomain})
      : super(wordpressDomain: wordpressDomain);

  Future<List<SearchResultItem>> search(String term) async {
    if (_resultCache.containsKey(term) && _resultCache[term]!.wasLoadCalled) {
      return _resultCache[term]!.completer.future;
    }

    _resultCache[term] ??= CompleterState();
    _resultCache[term]!.wasLoadCalled = true;

    try {
      _resultCache[term]!.completer.complete(await _fetchSearchResults(term));
    } catch (err) {
      _resultCache[term]!.completer.completeError(err);
    }

    return _resultCache[term]!.completer.future;
  }

  Stream<bool> isCompleted(String term) async* {
    _resultCache[term] ??= CompleterState();

    yield _resultCache[term]!.completer.isCompleted;

    await _resultCache[term]!.completer.future;

    yield true;
  }

  Future<List<SearchResultItem>> _fetchSearchResults(String term) async {
    final url = '$wordpressDomain/$searchApiPath?term=$term';
    final coreResponse = await http.get(Uri.parse(url));

    if (coreResponse.statusCode == HttpStatus.ok) {
      return SearchResponseRoot.fromJson(jsonDecode(coreResponse.body))
          .responses
          .map((e) => e.hits.hits.map((e) => e.source))
          .expand((element) => element)
          .toList();
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

class CompleterState<T> {
  final Completer<T> completer = Completer();

  /// Set to true if there's a method waiting for a result to complete this with.
  /// Ideally, this should be encapsulated.
  bool wasLoadCalled;

  CompleterState({this.wasLoadCalled = false});
}

class SearchState<T> {
  final bool isLoading;
  final FutureOr<T> data;

  SearchState({required this.isLoading, required this.data});

  bool get isComplete => !isLoading;
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
