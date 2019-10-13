import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/data/media-manager.dart';
import 'package:inside_chassidus/routes/lesson-route/index.dart';
import 'package:inside_chassidus/routes/top-lessons.dart';
import 'package:provider/provider.dart';
import 'routes/section-route/index.dart';

void main() => runApp(Provider<MediaManager>.value(
      value: MediaManager(),
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
          case SectionRoute.routeName:
            final SiteSection routeSection = settings.arguments;
            builder = (context) => SectionRoute(section: routeSection);
            break;
          case LessonRoute.routeName:
            final Lesson lesson = settings.arguments;
            builder = (context) => LessonRoute(lesson: lesson);
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
