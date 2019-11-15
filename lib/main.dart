import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:inside_chassidus/data/models/app-data.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:inside_chassidus/data/media-manager.dart';
import 'package:inside_chassidus/routes/lesson-route/index.dart';
import 'package:inside_chassidus/routes/player-route/player-route.dart';
import 'package:inside_chassidus/routes/primary-section-route.dart';
import 'package:inside_chassidus/routes/secondary-section-route/index.dart';
import 'package:inside_chassidus/routes/ternary-section-route.dart';

void main() => runApp(BlocProvider(
      blocs: [Bloc((i) => MediaManager())],
      dependencies: [Dependency((i) => AppData())],
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
          case PlayerRoute.routeName:
            final Media media = settings.arguments;
            builder = (context) => PlayerRoute(media: media);
            break;
          default:
            throw ArgumentError("Unknown route: ${settings.name}");
        }

        return MaterialPageRoute(builder: builder);
      },
      home: FutureBuilder(
        future: AppData.init(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.error != null) {
              print(snapshot.error);
              return Scaffold(
                body: Center(
                  child: Text('Something went wrong.'),
                ),
              );
            } else {
              return PrimarySectionsRoute();
            }
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
