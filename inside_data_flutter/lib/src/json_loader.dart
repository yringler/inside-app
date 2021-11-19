import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:inside_data/inside_data.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Loads site from local (or custom API/dropbox) JSON file.
/// Note that [init] MUST be called before usage.
class JsonLoader extends SiteDataLoader {
  static const dataVersion = 5;

  /// Path to JSON that was downloaded, ready to be used at next app start up.
  static late final String _jsonPath;

  /// Path to JSON that was copied over from app resources, ready to be used for initial
  /// app load.
  static late final String _jsonResourcePath;

  static Future<void> init(
      {required String resourceName, required AssetBundle assetBundle}) async {
    WidgetsFlutterBinding.ensureInitialized();
    _jsonPath =
        p.join((await getApplicationSupportDirectory()).path, 'update.json');
    _jsonResourcePath =
        p.join((await getApplicationSupportDirectory()).path, 'resource.json');

    _copyResourceToFile(resourceName, assetBundle: assetBundle);
  }

  /// If a JSON file was already downloaded and saved, loads it and returns, and deletes the file.
  /// Otherwise, checks for updates and downloads for next time in background.
  @override
  Future<SiteData?> load(DateTime lastLoadTime,
      {final bool ensureLatest = false}) async {
    final jsonFile = File(_jsonPath);

    if (ensureLatest) {
      await _tryPrepareUpdate(lastLoadTime);
    }

    SiteData? site;

    if (await jsonFile.exists() && jsonFile.lengthSync() > 10) {
      site = _parseJson(await jsonFile.readAsString());

      // Now that we've used the JSON file, delete it. We don't need it anymore.
      if (jsonFile.existsSync()) {
        try {
          await jsonFile.delete();
        } catch (_) {}
      }
    }

    if (!ensureLatest) {
      _tryPrepareUpdate(lastLoadTime);
    }

    return site;
  }

  /// Loads data from resource, and triggers update for next time.
  @override
  Future<SiteData> initialLoad() async {
    load(DateTime.fromMillisecondsSinceEpoch(0));

    return _parseJson(await File(_jsonResourcePath).readAsString());
  }

  static SiteData _parseJson(String jsonText) {
    final json = jsonDecode(jsonText);
    final site = SiteData.fromJson(json);
    return site;
  }

  /// For initial load, to have fastest times, we use pre-loaded JSON resource.
  /// We want to do all major data updates in another isolate to prevent jank from the
  /// loading spinner, and we can't access resources in the isolate, so simplest thing is
  /// to copy the resource to a file.
  static Future<void> _copyResourceToFile(String resourceName,
      {required AssetBundle assetBundle}) async {
    // Only run copy once.
    final resource = File(_jsonResourcePath);
    if (resource.existsSync() && resource.lengthSync() > 100) {
      return;
    }

    final json = await assetBundle.loadString(resourceName, cache: false);
    await resource.writeAsString(json);
  }

  /// Download data update, for use next time data is loaded.
  static Future<void> _tryPrepareUpdate(DateTime lastUpdate) async {
    final request = Request(
        'GET',
        Uri.parse(
            'https://inside-api-go-2.herokuapp.com/check?date=${lastUpdate.millisecondsSinceEpoch}&v=$dataVersion'));

    try {
      final response = await request.send();

      if (response.statusCode == HttpStatus.ok) {
        await File(_jsonPath)
            .writeAsBytes(GZipCodec().decode(await response.stream.toBytes()));
      }
    } catch (ex) {
      print(ex);
    }
  }
}
