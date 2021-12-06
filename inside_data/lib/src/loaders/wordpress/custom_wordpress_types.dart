import 'package:inside_data/inside_data.dart';
import 'package:inside_data/src/loaders/wordpress/parsing_tools.dart';
import 'package:json_annotation/json_annotation.dart';

part 'custom_wordpress_types.g.dart';

/// Used for the core category / series data.
@JsonSerializable(
    fieldRename: FieldRename.snake, explicitToJson: true, createFactory: false)
abstract class CustomEndpointGroup {
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
  List<CustomEndpointPost> posts;

  /// A URL to site where this content can be seen.
  final String link;

  CustomEndpointGroup(
      {required this.id,
      required this.name,
      required this.title,
      required this.description,
      required this.link,
      required this.parents,
      this.posts = const []});

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

    final sectionContent = posts
        .map((e) => e.toSiteDataBase())
        .where((element) => element != null)
        .cast<SiteDataBase>()
        .map((e) => ContentReference.fromData(data: e))
        .toList();

    // This is one place where we set audio count to 0, because at this point we don't have the whole site yet...
    return Section.fromBase(base, content: sectionContent, audioCount: 0);
  }
}

/// A series is a custom post type which can be a parent to other posts.
/// Sqlite-wise, it will end up being stored as a post, not a section.
/// This class could probably be deleted at this point (now that the parents property
/// was moved up to parent).
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CustomEndpointSeries extends CustomEndpointGroup {
  CustomEndpointSeries(
      {List<CustomEndpointPost> posts = const [],
      required Set<int> parents,
      required int id,
      required String name,
      required String title,
      required String description,
      required String link})
      : super(
            id: id,
            name: name,
            title: title,
            parents: parents,
            description: description,
            link: link,
            posts: posts);

  factory CustomEndpointSeries.fromJson(Map<String, dynamic> json) =>
      _$CustomEndpointSeriesFromJson(json);
  Map<String, dynamic> toJson() => _$CustomEndpointSeriesToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CustomEndpointCategory extends CustomEndpointGroup {
  List<CustomEndpointSeries> series;

  CustomEndpointCategory(
      {this.series = const [],
      List<CustomEndpointPost> posts = const [],
      required int id,
      required Set<int> parents,
      required String name,
      required String title,
      required String description,
      required String link})
      : super(
            id: id,
            name: name,
            title: title,
            parents: parents,
            description: description,
            link: link,
            posts: posts);

  CustomEndpointCategory.withBase(CustomEndpointGroup group,
      {required this.series})
      : super.copy(group);

  factory CustomEndpointCategory.fromJson(Map<String, dynamic> json) =>
      _$CustomEndpointCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CustomEndpointCategoryToJson(this);

  Section toSection() {
    // This takes care of basic properties
    final base = super.toSection();
    base.content.addAll(series
        .map((e) => e.toSection())
        .map((e) => ContentReference.fromData(data: e))
        .toList());

    return base;
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
