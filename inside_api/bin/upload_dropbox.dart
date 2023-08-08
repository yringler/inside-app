import 'dart:convert';
import 'dart:io';
import 'package:inside_api/inside_api.dart';
import 'package:inside_data/inside_data.dart';

void main() async {
  final existingSiteText = File('dropbox.json').readAsStringSync();
  final existingSiteJson = json.decode(existingSiteText);
  final existingSite = SiteData.fromJson(existingSiteJson);
  existingSite.createdDate = DateTime.now();
  await uploadToDropbox(existingSite, JsonLoader.dataVersion.toString());
  exit(0);
}
