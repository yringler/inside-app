// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inside_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Media _$MediaFromJson(Map<String, dynamic> json) => Media(
      source: json['source'] as String,
      length: json['length'] == null
          ? null
          : Duration(microseconds: json['length'] as int),
      id: json['id'] as String,
      sort: json['sort'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      link: json['link'] as String? ?? '',
    )..parent = json['parent'] as int;

Map<String, dynamic> _$MediaToJson(Media instance) => <String, dynamic>{
      'parent': instance.parent,
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'sort': instance.sort,
      'link': instance.link,
      'source': instance.source,
      'length': instance.length?.inMicroseconds,
    };

ContentReference _$ContentReferenceFromJson(Map<String, dynamic> json) =>
    ContentReference(
      media: json['media'] == null
          ? null
          : Media.fromJson(json['media'] as Map<String, dynamic>),
      section: json['section'] == null
          ? null
          : Section.fromJson(json['section'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ContentReferenceToJson(ContentReference instance) =>
    <String, dynamic>{
      'media': instance.media,
      'section': instance.section,
    };

Section _$SectionFromJson(Map<String, dynamic> json) => Section(
      content: (json['content'] as List<dynamic>)
          .map((e) => ContentReference.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: json['id'] as String,
      sort: json['sort'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      link: json['link'] as String? ?? '',
    )
      ..parent = json['parent'] as int
      ..audioCount = json['audioCount'] as int;

Map<String, dynamic> _$SectionToJson(Section instance) => <String, dynamic>{
      'parent': instance.parent,
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'sort': instance.sort,
      'link': instance.link,
      'audioCount': instance.audioCount,
      'content': instance.content,
    };
