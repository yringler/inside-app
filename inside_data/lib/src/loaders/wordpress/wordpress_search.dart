import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:inside_data/inside_data.dart';
import 'package:http/http.dart' as http;
import 'package:inside_data/src/loaders/wordpress/parsing_tools.dart';
import 'package:inside_data/src/loaders/wordpress/wordpress.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'wordpress_search.g.dart';

class WordpressSearch extends Wordpress {
  final SiteDataLayer siteBoxes;
  final Map<String, CompleterState<List<ContentReference>>> _resultCache = {};
  final BehaviorSubject<String> _recentTerm = BehaviorSubject.seeded('');

  /// As new search values are coming in, how long [activeResults] should wait
  /// before triggering another search.
  /// Note that calling [search] directly is not debounced.
  ///
  /// TODO: calling search should cause search results to immidieately be added to [activeResults] steram.
  /// This could be done with some combine latest or something, but isn't so important because debounce shouldn't
  /// be that long anyway.
  final Duration constantSearchDebounceTime;

  static const searchApiPath =
      'wp-content/plugins/elasticpress-custom/proxy/proxy.php';

  Stream<String> get activeTerm =>
      _recentTerm.stream.where((event) => event.isNotEmpty).distinct();

  /// Stream of results.
  Stream<List<ContentReference>> get activeResults =>
      activeTerm.debounceTime(Duration(milliseconds: 20)).asyncMap(search);

  WordpressSearch(
      {required String wordpressDomain,
      required this.siteBoxes,
      this.constantSearchDebounceTime = const Duration(milliseconds: 20)})
      : super(wordpressDomain: wordpressDomain);

  Future<List<ContentReference>> search(String term) async {
    _recentTerm.add(term);

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

  Future<List<ContentReference>> _fetchSearchResults(String term) async {
    final url = '$wordpressDomain/$searchApiPath?term=$term';
    final coreResponse = await http.get(Uri.parse(url));

    if (coreResponse.statusCode == HttpStatus.ok) {
      final referenceFutures =
          SearchResponseRoot.fromJson(jsonDecode(coreResponse.body))
              .responses
              .map((e) => e.hits.hits.map((e) => e.source))
              .expand((element) => element)
              .where((element) => element.type != null)
              .map(_mapSearchResultToContentReference)
              .toList();

      return (await Future.wait(referenceFutures))
          .where((e) => e != null)
          .map((e) => e!)
          .toList();
    } else {
      return Future.error(coreResponse);
    }
  }

  Future<ContentReference?> _mapSearchResultToContentReference(
      SearchResultItem result) async {
    SiteDataBase? data;
    if (result.type == ContentType.section) {
      data = await siteBoxes.section(result.id);
    } else if (result.type == ContentType.media) {
      data = await siteBoxes.media(result.id);
    }
    if (data != null) {
      return ContentReference.fromData(data: data);
    } else {
      return null;
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
