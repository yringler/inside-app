import 'package:dotenv/dotenv.dart';
import 'package:inside_api/inside_api.dart';
import 'package:inside_data/inside_data.dart';

/// Simply tell api to tell app to trigger a refresh.
void main() async {
  await notifyApiOfLatest(DateTime.now(), JsonLoader.dataVersion.toString());
}
