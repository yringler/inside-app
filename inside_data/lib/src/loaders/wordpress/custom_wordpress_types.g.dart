// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_wordpress_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CustomEndpointGroupToJson(
        CustomEndpointGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parents': instance.parents.toList(),
      'name': instance.name,
      'title': instance.title,
      'description': instance.description,
      'sort': instance.sort,
      'link': instance.link,
    };

CustomEndpointPost _$CustomEndpointPostFromJson(Map<String, dynamic> json) =>
    CustomEndpointPost(
      parents:
          (json['parents'] as List<dynamic>?)?.map((e) => e as int).toSet() ??
              {},
      id: json['ID'] as int,
      postTitle: json['post_title'] as String,
      postName: json['post_name'] as String,
      postContentFiltered: json['post_content_filtered'] as String,
      postDate: json['post_date'] as String,
      postModified: json['post_modified'] as String,
      menuOrder: json['menu_order'] as int? ?? 0,
      postContent: json['post_content'] as String,
      postType: json['post_type'] as String,
      guid: json['guid'] as String,
    );

Map<String, dynamic> _$CustomEndpointPostToJson(CustomEndpointPost instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'parents': instance.parents.toList(),
      'post_type': instance.postType,
      'post_title': instance.postTitle,
      'guid': instance.guid,
      'post_name': instance.postName,
      'post_content': instance.postContent,
      'post_content_filtered': instance.postContentFiltered,
      'post_date': instance.postDate,
      'post_modified': instance.postModified,
      'menu_order': instance.menuOrder,
    };
