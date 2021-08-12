import 'dart:convert';

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
  final Map<int, CustomEndpointCategory> _loadedCategories = {};
  final Map<int, CustomEndpointGroup> _loadedGroups = {};
  final Map<int, CustomEndpointPost> _loadedPosts = {};
  final BehaviorSubject<int> _connections = BehaviorSubject.seeded(0);

  WordpressRepository({required this.wordpressDomain})
      : wordPress = wp.WordPress(
            baseUrl: wordpressDomain.contains('http')
                ? wordpressDomain
                : 'https://$wordpressDomain',
            authenticator: wp.WordPressAuthenticator.JWT);

  Future<CustomEndpointCategory> category(int id) async {
    if (_loadedCategories.containsKey(id)) {
      return _loadedCategories[id]!;
    }

    final coreResponse = await _withConnectionCount(() => http.get(
        Uri.parse('https://$wordpressDomain/$standardApiPath/categories/$id')));
    final category = wp.Category.fromJson(jsonDecode(coreResponse.body));

    _loadedCategories[id] = await _childCategories(category);
    return _loadedCategories[id]!;
  }

  Future<CustomEndpointSeries> _series(CustomEndpointPost base) async {
    assert(base.isSeries);
    final id = base.id;

    if (_loadedGroups.containsKey(id)) {
      return _loadedGroups[id]! as CustomEndpointSeries;
    }

    final postsResponse = await _withConnectionCount(() => http
        .get(Uri.parse('https://$wordpressDomain/$customApiPathSeries/$id')));
    final posts = (jsonDecode(postsResponse.body) as Map<String, dynamic>)
        .values
        .map((e) => CustomEndpointPost.fromJson(e))
        .map((e) {
      // To have all parents accounted for, make sure to use saved if found.
      _loadedPosts[e.id] ??= e;
      if (e.menuOrder > 0) {
        _loadedPosts[e.id]!.menuOrder = e.menuOrder;
      }
      _loadedPosts[e.id]!.parents.add(id);
      return _loadedPosts[e.id]!;
    }).toList();

    for (int i = 0; i < posts.length; i++) {
      if (posts[i].menuOrder == 0) {
        posts[i].menuOrder = i;
      }
    }

    final group = CustomEndpointSeries(
        parents: {},
        id: base.id,
        name: base.postName,
        description: base.postContentFiltered,
        link: 'https://insidechassidus.org/series/${base.postName}',
        posts: posts);

    group.sort = base.menuOrder;

    group.parents.addAll(base.parents);

    _loadedGroups[id] = group;
    return group;
  }

  Future<CustomEndpointCategory> _childCategories(wp.Category category) async {
    if (_loadedCategories.containsKey(category.id)) {
      return _loadedCategories[category.id]!;
    }

    final postsResponse = await _withConnectionCount(() => http.get(Uri.parse(
        'https://$wordpressDomain/$customApiPathCategory/category/${category.id!}')));

    List<CustomEndpointPost>? posts;

    if (postsResponse.body.trim().isNotEmpty) {
      posts = (jsonDecode(postsResponse.body) as Map<String, dynamic>)
          .values
          .map((e) => CustomEndpointPost.fromJson(e))
          .map((e) {
        // To have all parents accounted for, make sure to use saved if found.
        _loadedPosts[e.id] ??= e;
        if (e.menuOrder > 0) {
          _loadedPosts[e.id]!.menuOrder = e.menuOrder;
        }
        if (category.id != null) {
          _loadedPosts[e.id]!.parents.add(category.id!);
        }
        return _loadedPosts[e.id]!;
      }).toList();
    }

    final categories = await _withConnectionCount(() =>
        wordPress.fetchCategories(
            params: wp.ParamsCategoryList(parent: category.id),
            fetchAll: true));

    final customCategories =
        (await Future.wait(categories.map((e) => _childCategories(e)).toList()))
            .toList();

    CustomEndpointGroup.setSort(customCategories);

    List<CustomEndpointSeries> series = posts != null
        ? (await Future.wait(
                posts.where((e) => e.isSeries).map((e) => _series(e)).toList()))
            .toList()
        : [];

    if (category.id != null) {
      series.forEach((element) => element.parents.add(category.id!));
    }

    CustomEndpointGroup.setSort(series);

    final returnValue = CustomEndpointCategory(
        id: category.id ?? 0,
        parent: category.parent ?? 0,
        name: category.name ?? '',
        description: category.description ?? '',
        link: category.link ?? '',
        posts: posts?.where((element) => element.isPost).toList() ?? [],
        series: series,
        categories: customCategories);

    _loadedCategories[category.id!] = returnValue;

    return returnValue;
  }

  Future<T> _withConnectionCount<T>(Future<T> get()) async {
    try {
      await _connections.firstWhere((element) => element < 2);
      _connections.add(_connections.value + 1);
      return await get();
    } catch (err) {
      print('error: $err');
      throw err;
    } finally {
      _connections.add(_connections.value - 1);
    }
  }
}

/// Recursively flattens children, does not return self.
/// Returning self would mean that each item would be returned twice - once as a
/// parent, and once as a child.
List<CustomEndpointGroup> flattenCategoryChildren(
        CustomEndpointCategory group) =>
    [
      ...group.series,
      ...[
        for (var group
            in group.categories.map((e) => flattenCategoryChildren(e)))
          ...group
      ]
    ];

/// Used for the core category / series data.
@JsonSerializable(
    fieldRename: FieldRename.snake, explicitToJson: true, createFactory: false)
abstract class CustomEndpointGroup {
  final int id;
  final String name;
  final String description;
  int sort = 0;
  List<CustomEndpointPost> posts;

  /// A URL to site where this content can be seen.
  final String link;

  CustomEndpointGroup(
      {required this.id,
      required this.name,
      required this.description,
      required this.link,
      this.posts = const []});

  Map<String, dynamic> toJson() => _$CustomEndpointGroupToJson(this);

  static void setSort(List<CustomEndpointGroup> groups) {
    for (int i = 0; i < groups.length; ++i) {
      groups[i].sort = i + 1;
    }
  }
}

/// A series is a custom post type which can be a parent to other posts.
/// Sqlite-wise, it will end up being stored as a post, not a section.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CustomEndpointSeries extends CustomEndpointGroup {
  @JsonKey(defaultValue: {})
  final Set<int> parents;
  CustomEndpointSeries(
      {List<CustomEndpointPost> posts = const [],
      required this.parents,
      required int id,
      required String name,
      required String description,
      required String link})
      : super(
            id: id,
            name: name,
            description: description,
            link: link,
            posts: posts);

  factory CustomEndpointSeries.fromJson(Map<String, dynamic> json) =>
      _$CustomEndpointSeriesFromJson(json);
  Map<String, dynamic> toJson() => _$CustomEndpointSeriesToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CustomEndpointCategory extends CustomEndpointGroup {
  final int parent;
  List<CustomEndpointSeries> series;
  List<CustomEndpointCategory> categories;

  CustomEndpointCategory(
      {required this.parent,
      this.series = const [],
      this.categories = const [],
      List<CustomEndpointPost> posts = const [],
      required int id,
      required String name,
      required String description,
      required String link})
      : super(
            id: id,
            name: name,
            description: description,
            link: link,
            posts: posts);

  factory CustomEndpointCategory.fromJson(Map<String, dynamic> json) =>
      _$CustomEndpointCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CustomEndpointCategoryToJson(this);
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

  /// Used to create URL
  final String postName;
  final String postContent;
  final String postContentFiltered;
  final String postDate;
  final String postModified;

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
      required this.postType});

  factory CustomEndpointPost.fromJson(Map<String, dynamic> json) =>
      _$CustomEndpointPostFromJson(json);
  Map<String, dynamic> toJson() => _$CustomEndpointPostToJson(this);
}
