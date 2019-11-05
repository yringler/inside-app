import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/data/media-manager.dart';
import 'package:inside_chassidus/routes/lesson-route/index.dart';
import 'package:inside_chassidus/routes/primary-section-route.dart';
import 'package:inside_chassidus/routes/secondary-section-route/index.dart';
import 'package:inside_chassidus/routes/ternary-section-route.dart';

void main() => runApp(BlocProvider(
      blocs: [Bloc((i) => MediaManager())],
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
          case SecondarySectionRoute.routeName:
            final SiteSection routeSection = settings.arguments;
            builder = (context) => SecondarySectionRoute(section: routeSection);
            break;
          case LessonRoute.routeName:
            final Lesson lesson = settings.arguments;
            builder = (context) => LessonRoute(lesson: lesson);
            break;
          case TernarySectionRoute.routeName:
            final SiteSection routeSection = settings.arguments;
            builder = (context) => TernarySectionRoute(section: routeSection);
            break;
          default:
            throw ArgumentError("Unknown route: ${settings.name}");
        }

        return MaterialPageRoute(builder: builder);
      },
      home: PrimarySectionsRoute(),
    );
  }
}
