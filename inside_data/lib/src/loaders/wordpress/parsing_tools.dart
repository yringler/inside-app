import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:html_unescape/html_unescape_small.dart';

import 'package:inside_data/inside_data.dart';
import 'package:quiver/iterables.dart';

final htmlUnescape = HtmlUnescape();

void parseDataXml(SiteDataBase dataItem) {
  dataItem.title = _parseXml(dataItem.title);
  dataItem.description = _parseXml(dataItem.description);
}

String _parseXml(String xmlString) {
  final xml = html.parse(xmlString.replaceAll('<br>', '\n'));
  final returnValue = xml.children.map((e) => e.text).join(' ').trim();

  return returnValue.isEmpty ? '' : htmlUnescape.convert(returnValue);
}

/// Turns a post... possibly into a section, if it contains multiple media items.
SiteDataBase? parsePost(SiteDataBase post, {bool requireAudio = true}) {
  post.title = _parseXml(post.title);
  final xml = post.description.isNotEmpty ? html.parse(post.description) : null;

  final audios = xml?.querySelectorAll('.wp-block-audio');
  final videos = xml?.querySelectorAll('.wp-block-video');

  final allMediaElements =
      _MediaElements.fromElements(audio: audios ?? [], video: videos ?? []);

  for (final media in allMediaElements) {
    media.audio?.remove();
    media.video?.remove();
  }

  var description = xml != null ? _parseXml(xml.outerHtml) : '';

  // If it doesn't have a good description, forget about it.
  // In particular, sometimes the description will be "MP3"
  if (description.length < 4) {
    description = '';
  }

  // For example, if we're parsing the basic data for a category, the category description
  // will not have any audios in it.
  if (allMediaElements.isEmpty) {
    return requireAudio
        ? null
        : SiteDataBase(
            created: post.created,
            parents: post.parents,
            id: post.id,
            title: post.title,
            description: description,
            sort: post.sort,
            link: post.link);
  }

  if (allMediaElements.length == 1) {
    final media = _toMedia(allMediaElements.first,
        description: description,
        title: post.title,
        order: post.sort,
        link: post.link,
        id: post.id,
        created: post.created,
        parents: post.parents);

    return media;
  }

  int sort = 0;
  final medias = allMediaElements
      .map((e) => _toMedia(e,
          created: post.created,
          description: '',
          title: '',
          // Oooh sneaky. I haven't done a sneaky post fix increment like that
          // ... ever, I think.
          order: sort++,
          link: post.link,
          parents: {post.id}))
      .where((element) => element != null)
      .cast<Media>()
      .toList();

  // Give any media without a good title the title of the post with a counter.
  for (var i = 0; i < medias.length; ++i) {
    if ((medias[i].title.length) <= 3) {
      String title = '';

      if (post.title.length > 3) {
        title += '${post.title}: ';
      }

      medias[i].title = title + 'Class ${i + 1}';
    }
  }

  if (medias.isEmpty) {
    return null;
  }

  return Section(
      audioCount: medias.length,
      id: post.id,
      link: post.link,
      title: post.title,
      description: description,
      content: medias.map((e) => ContentReference.fromData(data: e)).toList(),
      sort: post.sort,
      parents: post.parents);
}

Media? _toMedia(_MediaElements element,
    {required String description,
    required String title,
    required int order,
    required String link,
    required Set<String> parents,
    required DateTime? created,
    String? id}) {
  final audioSource =
      element.audio?.querySelector('audio')?.attributes['src'] ?? '';
  final videoSource =
      element.video?.querySelector('video')?.attributes['src'] ?? '';

  if (audioSource.isEmpty && videoSource.isEmpty) {
    return null;
  }

  final captions = ([element.audio, element.video]
      .whereType<Element>()
      .map((e) => e.querySelector('figcaption')?.text.trim() ?? '')
      .where((element) => element.isNotEmpty)
      .toList()
    ..sort(((a, b) => b.length.compareTo(a.length))));

  final caption = captions.isNotEmpty ? captions.first : '';
  final mediaTitle = title.isNotEmpty ? title : _parseXml(caption);

  return Media(
      id: id ?? (audioSource.isNotEmpty ? audioSource : videoSource),
      created: created,
      parents: parents,
      // We don't know the length yet.
      length: null,
      link: link,
      source: audioSource,
      videoSource: videoSource,
      title: mediaTitle,
      description: description,
      sort: order);
}

/// Video and audio which are (we're pretty sure) the same content.
class _MediaElements {
  Element? audio;
  Element? video;

  _MediaElements({this.audio, this.video});

  static List<_MediaElements> fromElements(
      {required List<Element> audio, required List<Element> video}) {
    // This is an edge case. I don't think this ever happens, so I'm not going to spend much time on it.
    // If it does happen, this code is suboptimal - it loses sort order.
    if (audio.length != video.length) {
      return [
        ...audio.map((e) => _MediaElements(audio: e)),
        ...video.map((e) => _MediaElements(video: e))
      ];
    }

    return zip([audio, video])
        .map((e) => _MediaElements(audio: e[0], video: e[1]))
        .toList();
  }
}
