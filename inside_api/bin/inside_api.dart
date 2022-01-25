import 'dart:convert';
import 'dart:io';
import 'package:inside_api/inside_api.dart';
import 'package:inside_data/inside_data.dart';
import 'package:process_run/process_run.dart' as process;
import 'package:dotenv/dotenv.dart' as dartenv;
import 'package:dotenv/dotenv.dart' show env;

final encoder = JsonEncoder.withIndent('\t');
late final File currentRawSiteFile;

const numInvalidMedia = 0;
const isDebug = false;
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
  sourceUrl = env['sourceUrl']!;

  final repository = WordpressLoader(
      topCategoryIds: topImagesInside.keys.toList(), wordpressUrl: sourceUrl);

  final site = await repository.initialLoad();

  final classListFile = File(env['classListFile']!);
  final classList = site.medias.values.toList();
  await classListFile.writeAsString(
      encoder.convert(classList.map((e) => e.source).toSet().toList()));

  print('running check_duration');
  final scriptPath = env['getDurationScriptPath']!;
  final execResult = await process.runExecutableArguments(
      'node', ['get_duration.js'],
      workingDirectory: scriptPath);
  try {
    print(execResult.stdout);
  } catch (err) {
    print(err);
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
  if (rawContents != newJson || isDebug || true) {
    print('update latest');

    // Save site as being current.
    await currentRawSiteFile.writeAsString(newJson, flush: true);

    await _setCurrentVersionDate(site.createdDate);

    if (!isDebug) {
      print('uploading...');
      await uploadToDropbox(site, JsonLoader.dataVersion.toString());
      print('notifying...');
      await notifyApiOfLatest(
          site.createdDate, JsonLoader.dataVersion.toString());
    } else {
      print('in debug mode');
    }
    print('done');
  }
}

void _setSiteDuration(SiteData site) {
  final durationJson = File(env['durationFileJson']!);
  final dynamicDuration =
      json.decode(durationJson.readAsStringSync()) as Map<String, dynamic>;
  final duration = Map.castFrom<String, dynamic, String, int>(dynamicDuration);
  for (var media in site.medias.values) {
    if (duration.containsKey(media.mediaSource) &&
        duration[media.mediaSource]! > 0) {
      media.length = Duration(milliseconds: duration[media.mediaSource]!);
    }
  }
}
