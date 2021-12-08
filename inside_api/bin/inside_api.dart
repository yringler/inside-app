import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:http/http.dart';
import 'package:inside_api/inside_api.dart';
import 'package:inside_data/inside_data.dart';
import 'package:process_run/process_run.dart' as process;

import 'package:dotenv/dotenv.dart' as dartenv;
import 'package:dotenv/dotenv.dart' show env;

final encoder = JsonEncoder.withIndent('\t');
late final File currentRawSiteFile;

const numInvalidMedia = 0;
late final String dataVersion;
late final String dropBoxFile;
const isDebug = true;
late final String sourceUrl;

/// Reads (or queries) all lessons, creates lesson list and uses duration data.
/// Note that it doesn't compress the site. This allows incremental updates, because
/// we can be certain that all sections (categories) are present (and haven't been
/// compressed away).
/// It than creates a new site JSON, which can be compared with the first and
/// uploaded to dropbox if it's newer.
void main(List<String> arguments) async {
  dartenv.load();

  currentRawSiteFile = File('rawsite.current.json');
  sourceUrl = /*isDebug ? 'http://localhost/' :*/ env['sourceUrl']!;
  dataVersion = env['dataVersion']!;
  dropBoxFile = '/site.v$dataVersion.json.gz';

  final repository = WordpressLoader(
      topCategoryIds: topImagesInside.keys.toList(), //.take(1).toList(),
      wordpressUrl: sourceUrl);

  final site = await repository.initialLoad();

  final classListFile = File(env['classListFile']!);
  final classList = site.medias.values.toList();
  await classListFile.writeAsString(
      encoder.convert(classList.map((e) => e.source).toSet().toList()));

  // Update our duration list if we need to.
  if (classList.where((element) => element.length == Duration.zero).length >
      numInvalidMedia) {
    print('running check_duration');
    final scriptPath = env['getDurationScriptPath']!;
    await process.runExecutableArguments('node', ['get_duration.js'],
        workingDirectory: scriptPath);
  }
  print('set duration');
  _setSiteDuration(site);

  await _updateLatestLocalCloud(site);
  print('returning');
  exit(0);
}

Future<void> _setCurrentVersionDate(DateTime date) async {
  final file = File('.date.txt');
  await file.writeAsString(date.toIso8601String());
  await File('.dateepoch.txt')
      .writeAsString(date.millisecondsSinceEpoch.toString());
}

/// Handle - we got a new class!
Future<void> _updateLatestLocalCloud(SiteData site) async {
  final rawContents = currentRawSiteFile.existsSync()
      ? currentRawSiteFile.readAsStringSync()
      : null;
  var newJson = encoder.convert(site);

  // If newest is diffirent from current.
  if (rawContents != newJson || isDebug) {
    print('update latest');

    // Save site as being current.
    await currentRawSiteFile.writeAsString(newJson, flush: true);

    await _setCurrentVersionDate(site.createdDate);

    if (!isDebug) {
      print('uploading...');
      await _uploadToDropbox(site);
      print('notifying...');
      await notifyApiOfLatest(site.createdDate, dataVersion);
    } else {
      print('in debug mode');
    }
    print('done');
  }
}

/// Upload newest version of data to dropbox.
/// (Thank you, Raj @https://stackoverflow.com/a/56572616)
Future<void> _uploadToDropbox(SiteData site) async {
  await File('dropbox.json').writeAsString(json.encode(site));

  if (isDebug) {
    return;
  }

  final key = env['dropBoxToken']!;

  var request = Request(
      'POST', Uri.parse('https://content.dropboxapi.com/2/files/upload'))
    ..headers.addAll({
      'Content-Type': 'application/octet-stream',
      'Authorization': 'Bearer $key',
      'Dropbox-API-Arg':
          json.encode({'path': dropBoxFile, 'mode': 'overwrite', 'mute': true}),
    })
    ..bodyBytes = GZipCodec(level: 9).encode(utf8.encode(json.encode(site)));

  await request.send();
}

void _setSiteDuration(SiteData site) {
  final durationJson = File(env['durationFileJson']!);
  final dynamicDuration =
      json.decode(durationJson.readAsStringSync()) as Map<String, dynamic>;
  final duration = Map.castFrom<String, dynamic, String, int>(dynamicDuration);
  for (var media in site.medias.values) {
    if (duration.containsKey(media.source) && duration[media.source]! > 0) {
      media.length = Duration(milliseconds: duration[media.source]!);
    }
  }
}
