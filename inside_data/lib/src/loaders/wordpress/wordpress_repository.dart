import 'dart:convert';

import 'package:inside_data/inside_data.dart';
import 'package:inside_data/src/loaders/wordpress/parsing_tools.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_wordpress/flutter_wordpress.dart' as wp;
import 'package:http/http.dart' as http;
import 'package:rxdart/subjects.dart';

part 'wordpress_repository.g.dart';

class WordpressRepository {
  static const standardApiPath = 'wp-json/wp/v2';
  static const customApiPathCategory = 'wp-json/shiurim/v1';
  static const customApiPathSeries = 'wp-json/shiur-series/v1';
  final String wordpressDomain;
  final wp.WordPress wordPress;
  final Map<int, CustomEndpointGroup> _loadedGroups = {};
  final Map<int, CustomEndpointPost> _loadedPosts = {};

  /// How direct children of a section should be sorted.
  final Map<int, List<int>> contentSort = {};

  Map<int, CustomEndpointGroup> get groups => _loadedGroups;
  Map<int, CustomEndpointPost> get posts => _loadedPosts;

  /// The number of HTTP downloads in progress.
  final BehaviorSubject<int> _connections = BehaviorSubject.seeded(0);

  WordpressRepository({required String wordpressDomain})
      : this.wordpressDomain = _ensureHttps(wordpressDomain),
        wordPress = wp.WordPress(
            baseUrl: _ensureHttps(wordpressDomain),
            authenticator: wp.WordPressAuthenticator.JWT);

  static String _ensureHttps(String url) =>
      url.contains('http') ? url : 'https://$url';

  /// Load a category, with all children, recursively.
  Future<void> category(int id) async {
    if (_loadedGroups.containsKey(id)) {
      return;
    }

    final url = '$wordpressDomain/$standardApiPath/categories/$id';
    final coreResponse =
        await _withConnectionCount(() => http.get(Uri.parse(url)), url);

    if (coreResponse == null) {
      return;
    }

    final category = wp.Category.fromJson(jsonDecode(coreResponse.body));

    _loadedGroups[id] = await _childCategories(category);
    return;
  }

  /// Load all content of a series-type post.
  Future<CustomEndpointGroup> _series(CustomEndpointPost base) async {
    assert(base.isSeries);
    final id = base.id;

    if (_loadedGroups.containsKey(id)) {
      return _loadedGroups[id]!;
    }

    final url = '$wordpressDomain/$customApiPathSeries/$id';
    final postsResponse =
        await _withConnectionCount(() => http.get(Uri.parse(url)), url);

    Map<String, dynamic>? jsonResponse;

    if (postsResponse != null) {
      try {
        jsonResponse = (jsonDecode(postsResponse.body) as Map<String, dynamic>);
      } catch (err) {
        print('Url: $url\nError: $err');
        //exit(1);
      }
    }

    if (jsonResponse == null) {
      return new CustomEndpointGroup(
          parents: base.parents,
          id: id,
          name: base.postName,
          title: base.postTitle,
          description: base.postContent.isNotEmpty
              ? base.postContent
              : base.postContentFiltered,
          link: '');
    }

    final group = CustomEndpointGroup(
        parents: base.parents,
        id: base.id,
        name: base.postName,
        title: base.postTitle,
        description: base.postContentFiltered,
        link: '$wordpressDomain/series/${base.postName}');

    group.sort = base.menuOrder;

    _loadedGroups[id] = group;

    await _usePosts(jsonResponse, id);
    return group;
  }

  Future<List<CustomEndpointPost>> _usePosts(
      Map<String, dynamic> jsonResponse, int id) async {
    final allPostTypes =
        jsonResponse.values.map((e) => CustomEndpointPost.fromJson(e)).toList();

    final posts = allPostTypes.where((element) => element.isPost).map((e) {
      // To have all parents accounted for, make sure to use saved if found.
      _loadedPosts[e.id] ??= e;
      if (e.menuOrder > 0) {
        _loadedPosts[e.id]!.menuOrder = e.menuOrder;
      }
      _loadedPosts[e.id]!.parents.add(id);
      return _loadedPosts[e.id]!;
    }).toList();

    final series = await Future.wait(allPostTypes
        .where((element) => element.isSeries)
        .map((e) => _series(e))
        .toList());

    for (var s in series) {
      s.parents.add(id);
    }

    contentSort[id] ??= [];
    contentSort[id]!.addAll(posts.map((e) => e.id));
    contentSort[id]!.addAll(series.map((e) => e.id));

    CustomEndpointGroup.setSort(series);

    for (int i = 0; i < allPostTypes.length; i++) {
      var raw = allPostTypes[i];
      if (raw.isPost && raw.menuOrder == 0) {
        posts.firstWhere((element) => element.id == raw.id).menuOrder = i;
      } else if (raw.isSeries && raw.menuOrder == 0) {
        series.firstWhere((element) => element.id == raw.id).sort = i;
      }
    }
    return posts;
  }

  /// Load all child categories' content of category given, recursively. Loads any
  /// series in the category.
  Future<CustomEndpointGroup> _childCategories(wp.Category category) async {
    if (_loadedGroups.containsKey(category.id)) {
      return _loadedGroups[category.id]!;
    }

    final url =
        '$wordpressDomain/$customApiPathCategory/category/${category.id!}';
    final postsResponse =
        await _withConnectionCount(() => http.get(Uri.parse(url)), url);

    if (postsResponse != null && postsResponse.body.trim().isNotEmpty) {
      await _usePosts(jsonDecode(postsResponse.body), category.id!);
    }

    // query for children of category causes error if there aren't any children.
    try {
      final categories = await _withConnectionCount(
          () => wordPress.fetchCategories(
              params: wp.ParamsCategoryList(parent: category.id),
              fetchAll: true),
          'Fetch categories with parent: ${category.id}');

      if (categories != null) {
        // Get child categories. Note that we don't save child category to parent category; that
        // is handled by the child categories parents property.
        // This prevents us from having a data structure with unknown depth.
        final customCategories = (await Future.wait(
                categories.map((e) => _childCategories(e)).toList()))
            .toList();

        contentSort[category.id]!.insertAll(0, categories.map((e) => e.id!));

        CustomEndpointGroup.setSort(customCategories);
      }
    } catch (_) {}

    final returnValue = CustomEndpointGroup(
        id: category.id ?? 0,
        parents: category.parent != null ? {category.parent!} : {},
        name: category.slug ?? '',
        title: category.name ?? '',
        description: category.description ?? '',
        link: category.link ?? '');

    _loadedGroups[category.id!] = returnValue;

    return returnValue;
  }

  static const int maxConnections = 8;
  Future<T?> _withConnectionCount<T>(
      Future<T> get(), String description) async {
    try {
      while (_connections.value > maxConnections) {
        await _connections.firstWhere((element) => element <= maxConnections);
      }
      _connections.add(_connections.value + 1);

      return await get();
    } catch (err) {
      print('error: $err\nat: $description\n');
    } finally {
      _connections.add(_connections.value - 1);
    }
  }
}

/// Used for the core category / series data.
@JsonSerializable(
    fieldRename: FieldRename.snake, explicitToJson: true, createFactory: false)
class CustomEndpointGroup {
  final int id;

  /// This is parents, but not from json.
  @JsonKey(defaultValue: {})
  final Set<int> parents;

  /// Should be called slug - this might be because of JSON requirments, but even
  /// then we can always rename it.
  final String name;

  /// Human readable title.
  final String title;
  final String description;
  int sort = 0;

  /// A URL to site where this content can be seen.
  final String link;

  CustomEndpointGroup(
      {required this.id,
      required this.name,
      required this.title,
      required this.description,
      required this.link,
      required this.parents});

  CustomEndpointGroup.copy(CustomEndpointGroup other)
      : this(
            id: other.id,
            name: other.name,
            title: other.title,
            description: other.description,
            link: other.link,
            parents: other.parents);

  Map<String, dynamic> toJson() => _$CustomEndpointGroupToJson(this);

  static void setSort(List<CustomEndpointGroup> groups) {
    for (int i = 0; i < groups.length; ++i) {
      groups[i].sort = i + 1;
    }
  }

  Section toSection() {
    // A section doesn't have any audio in its body, so set require audio to false.
    final base = parsePost(
        SiteDataBase(
            parents: parents.map((e) => e.toString()).toSet(),
            id: id.toString(),
            title: title,
            description: description,
            sort: sort,
            link: link),
        requireAudio: false);

    if (base == null) {
      throw "to section parse post: returned null";
    }

    // This is one place where we set audio count to 0, because at this point we don't have the whole site yet...
    return Section.fromBase(base, content: [], audioCount: 0);
  }
}

/// A post which is returned from the custom categories and series endpoint.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CustomEndpointPost {
  @JsonKey(name: 'ID')
  final int id;
  @JsonKey(defaultValue: {})
  final Set<int> parents;
  // Will be one of 'post' or 'series'
  final String postType;
  final String postTitle;
  final String guid;

  /// Used to create URL
  final String postName;
  final String postContent;
  final String postContentFiltered;
  final String postDate;
  final String postModified;

  /// Yeah, bad name. There are 2 contents returned by wordpress, takes better.
  String get postContentContent =>
      postContent.trim().isNotEmpty ? postContent : postContentFiltered;

  /// Where to position this post in list. Only set in category endpoint, not in series endpoint.
  @JsonKey(defaultValue: 0)
  int menuOrder;

  bool get isPost => postType == 'post';
  bool get isSeries => postType == 'series';
  DateTime get date => DateTime.parse(postDate);
  DateTime get modified => DateTime.parse(postModified);

  CustomEndpointPost(
      {required this.parents,
      required this.id,
      required this.postTitle,
      required this.postName,
      required this.postContentFiltered,
      required this.postDate,
      required this.postModified,
      required this.menuOrder,
      required this.postContent,
      required this.postType,
      required this.guid});

  factory CustomEndpointPost.fromJson(Map<String, dynamic> json) =>
      _$CustomEndpointPostFromJson(json);
  Map<String, dynamic> toJson() => _$CustomEndpointPostToJson(this);

  SiteDataBase? toSiteDataBase() {
    final domain = Uri.parse(guid).host;
    final pathPrefix = this.isSeries ? 'series/' : '';
    final url = 'https://$domain/$pathPrefix$postName';
    final base = parsePost(
        SiteDataBase(
            parents: parents.map((e) => e.toString()).toSet(),
            id: id.toString(),
            title: postTitle,
            description:
                postContent.isNotEmpty ? postContent : postContentFiltered,
            sort: menuOrder,
            link: url),
        requireAudio: isPost);

    return base;
  }
}
