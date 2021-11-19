import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inside_data_flutter/inside_data_flutter.dart';

void main() async {
  runApp(const MaterialApp(
      home: Scaffold(
    body: Center(child: CircularProgressIndicator()),
  )));

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: _future(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Text('hi');
      });

  Future<String> _future() async {
    await JsonLoader.init(
        resourceName: 'assets/site.json', assetBundle: rootBundle);
    final loader = JsonLoader();
    await loader.initialLoad();
    await loader.load(DateTime.fromMillisecondsSinceEpoch(0));
    final secondSite =
        await loader.load(DateTime.fromMillisecondsSinceEpoch(0));
    assert(secondSite != null);
    assert(secondSite?.sections != null);
    assert((secondSite?.sections.length ?? 0) > 10);

    return 'blah';
  }
}
