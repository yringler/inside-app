import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Loads and stuff without error.', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
    });
  });
}
