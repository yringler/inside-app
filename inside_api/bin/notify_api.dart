import 'package:dotenv/dotenv.dart';
import 'package:inside_api/inside_api.dart';

/// Simply tell api to tell app to trigger a refresh.
void main() async {
  load();
  await notifyApiOfLatest(DateTime.now(), env['dataVersion']!);
}
