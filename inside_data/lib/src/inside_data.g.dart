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
      parent:
          (json['parent'] as List<dynamic>?)?.map((e) => e as String).toSet(),
    );

Map<String, dynamic> _$MediaToJson(Media instance) => <String, dynamic>{
      'parent': instance.parent.toList(),
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
      id: json['id'] as String,
      contentType: _$enumDecode(_$ContentTypeEnumMap, json['contentType']),
    );

Map<String, dynamic> _$ContentReferenceToJson(ContentReference instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contentType': _$ContentTypeEnumMap[instance.contentType],
      'media': instance.media,
      'section': instance.section,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$ContentTypeEnumMap = {
  ContentType.media: 'media',
  ContentType.section: 'section',
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
      ..parent =
          (json['parent'] as List<dynamic>).map((e) => e as String).toSet()
      ..audioCount = json['audioCount'] as int;

Map<String, dynamic> _$SectionToJson(Section instance) => <String, dynamic>{
      'parent': instance.parent.toList(),
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'sort': instance.sort,
      'link': instance.link,
      'audioCount': instance.audioCount,
      'content': instance.content,
    };

SiteData _$SiteDataFromJson(Map<String, dynamic> json) => SiteData(
      sections: (json['sections'] as List<dynamic>)
          .map((e) => Section.fromJson(e as Map<String, dynamic>))
          .toList(),
      topSectionIds: (json['topSectionIds'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );

Map<String, dynamic> _$SiteDataToJson(SiteData instance) => <String, dynamic>{
      'sections': instance.sections,
      'topSectionIds': instance.topSectionIds,
    };
