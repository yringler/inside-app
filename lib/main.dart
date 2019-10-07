import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/screens/lesson-screen/index.dart';
import 'package:inside_chassidus/screens/top-lessons.dart';
import 'package:provider/provider.dart';
import 'screens/site-section/index.dart';

void main() => runApp(Provider<AudioPlayer>.value(
      value: AudioPlayer(),
      child: MyApp(),
    ));

class MyApp extends StatelessWidget {
  // This widget is the root of your application. 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inside Chassidus',
      theme: ThemeData(primarySwatch: Colors.grey),
      onGenerateRoute: (settings) {
        WidgetBuilder builder;

        switch (settings.name) {
          case SiteSectionScreen.routeName:
            final SiteSection routeSection = settings.arguments;
            builder = (context) => SiteSectionScreen(section: routeSection);
            break;
          case LessonScreen.routeName:
            final Lesson lesson = settings.arguments;
            builder = (context) => LessonScreen(lesson: lesson);
            break;
          default:
            throw ArgumentError("Unknown route: ${settings.name}");
        }

        return MaterialPageRoute(builder: builder);
      },
      home: TopLessons(),
    );
  }
}
