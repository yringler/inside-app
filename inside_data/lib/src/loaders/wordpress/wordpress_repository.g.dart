// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wordpress_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
