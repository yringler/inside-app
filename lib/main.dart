import 'package:flutter/material.dart';
import 'package:inside_chassidus/screens/top-lessons.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inside Chassidus',
      theme: ThemeData(
        primarySwatch: Colors.grey
      ),
      routes: <String, WidgetBuilder> {
        '/classes': (BuildContext context) => null
      },
      home: TopLessons(),
    );
  }
}
