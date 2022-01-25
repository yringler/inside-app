import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:inside_data/inside_data.dart';

/// Loads site from local (or custom API/dropbox) JSON file.
/// Note that [init] MUST be called before usage.
class JsonLoader extends SiteDataLoader {
  static const dataVersion = 10;

  /// If a JSON file was already downloaded and saved, loads it and returns, and deletes the file.
  /// Otherwise, checks for updates and downloads for next time in background.
  @override
  Future<SiteData?> load(DateTime lastLoadTime) async {
    final request = Request(
        'GET',
        Uri.parse(
            'https://inside-api-go-2.herokuapp.com/check?date=${lastLoadTime.millisecondsSinceEpoch}&v=$dataVersion'));

    try {
      final response = await request.send();

      if (response.statusCode == HttpStatus.ok) {
        return SiteData.fromJson(jsonDecode(
            utf8.decode(GZipCodec().decode(await response.stream.toBytes()))));
      }
    } catch (ex) {
      print(ex);
    }

    return null;
  }
}
