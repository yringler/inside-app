import 'package:flutter/material.dart';
import 'package:inside_chassidus/screens/lessonNavigator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inside Chasidus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LessonNavigator(),
    );
  }
}