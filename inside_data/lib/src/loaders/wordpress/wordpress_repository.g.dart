// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wordpress_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomEndpointGroup _$CustomEndpointGroupFromJson(Map<String, dynamic> json) =>
    CustomEndpointGroup(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      link: json['link'] as String,
      posts: (json['posts'] as List<dynamic>?)
              ?.map(
                  (e) => CustomEndpointPost.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    )
      ..sort = json['sort'] as int
      ..parent = json['parent'] as int;

Map<String, dynamic> _$CustomEndpointGroupToJson(
        CustomEndpointGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'sort': instance.sort,
      'parent': instance.parent,
      'posts': instance.posts,
      'link': instance.link,
    };

CustomEndpointCategory _$CustomEndpointCategoryFromJson(
        Map<String, dynamic> json) =>
    CustomEndpointCategory(
      parent: json['parent'] as int,
      series: (json['series'] as List<dynamic>?)
              ?.map((e) =>
                  CustomEndpointGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) =>
                  CustomEndpointCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      posts: (json['posts'] as List<dynamic>?)
              ?.map(
                  (e) => CustomEndpointPost.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      link: json['link'] as String,
    )..sort = json['sort'] as int;

Map<String, dynamic> _$CustomEndpointCategoryToJson(
        CustomEndpointCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'sort': instance.sort,
      'posts': instance.posts,
      'link': instance.link,
      'parent': instance.parent,
      'series': instance.series,
      'categories': instance.categories,
    };

CustomEndpointPost _$CustomEndpointPostFromJson(Map<String, dynamic> json) =>
    CustomEndpointPost(
      id: json['id'] as int,
      postTitle: json['post_title'] as String,
      postName: json['post_name'] as String,
      postContentFiltered: json['post_content_filtered'] as String,
      postDate: json['post_date'] as String,
      postModified: json['post_modified'] as String,
      menuOrder: json['menu_order'] as int?,
      type: json['type'] as String,
    )..parent = json['parent'] as int?;

Map<String, dynamic> _$CustomEndpointPostToJson(CustomEndpointPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parent': instance.parent,
      'type': instance.type,
      'post_title': instance.postTitle,
      'post_name': instance.postName,
      'post_content_filtered': instance.postContentFiltered,
      'post_date': instance.postDate,
      'post_modified': instance.postModified,
      'menu_order': instance.menuOrder,
    };
