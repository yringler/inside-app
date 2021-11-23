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
      home: TestDriftLoader(),
    );
  }
}

class TestJsonLoader extends StatelessWidget {
  const TestJsonLoader({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: _future(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return Text('Returned ${snapshot.data!}');
      });

  Future<String> _future() async {
    await JsonLoader.init(
        resourceName: 'assets/site.json', assetBundle: rootBundle);
    final loader = JsonLoader();
    await loader.initialLoad();
    await loader.load(DateTime.fromMillisecondsSinceEpoch(0));
    await loader.prepareUpdate(DateTime.fromMillisecondsSinceEpoch(0));

    final secondSite =
        await loader.load(DateTime.fromMillisecondsSinceEpoch(0));
    assert(secondSite != null);
    assert(secondSite?.sections != null);
    assert((secondSite?.sections.length ?? 0) > 10);

    return secondSite!.sections.values.first.title;
  }
}

class TestDriftLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: _future(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return Text('Returned ${snapshot.data!}');
      });

  Future<String> _future() async {
    await JsonLoader.init(
        resourceName: 'assets/site.json', assetBundle: rootBundle);

    final loader = JsonLoader();

    var drift = DriftInsideData(
        loader: loader,
        topIds: topImagesInside.keys.map((e) => e.toString()).toList());

    await drift.init();

    var basic = (await drift.section('773'))!;
    assert(basic.link.isNotEmpty && basic.content.length > 4);
    await loader.prepareUpdate(DateTime.fromMillisecondsSinceEpoch(0));

    // This is a clumsy API - to get latest data, call init? Again? After loading data in
    // another API?
    await drift.init();

    var full = await (drift.topLevel());
    assert(full.length ==
        full.where((element) => element.content.length > 2).length);

    return full.first.description;
  }
}
