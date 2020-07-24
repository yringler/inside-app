import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:inside_api/models.dart';
import 'package:inside_api/site-service.dart';
import 'package:inside_chassidus/routes/lesson-route/index.dart';
import 'package:inside_chassidus/routes/player-route/player-route.dart';
import 'package:inside_chassidus/routes/primary-section-route.dart';
import 'package:inside_chassidus/routes/secondary-section-route/index.dart';
import 'package:inside_chassidus/routes/ternary-section-route.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:just_audio_service/position-manager/position-data-manager.dart';
import 'package:just_audio_service/position-manager/position-manager.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = false;

  // Pass all uncaught errors from the framework to Crashlytics.

  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(MaterialApp(
      home: Scaffold(
    body: Center(child: CircularProgressIndicator()),
  )));

  WidgetsFlutterBinding.ensureInitialized();

  final siteBoxes = await getBoxes();

  runApp(BlocProvider(
    dependencies: [
      Dependency(
          (i) => PositionManager(positionDataManager: PositionDataManager())),
      Dependency((i) => siteBoxes),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    MyApp.analytics.logAppOpen();

    return AudioServiceWidget(
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Inside Chassidus',
          theme: ThemeData(primarySwatch: Colors.grey),
          onGenerateRoute: (settings) {
            WidgetBuilder builder;

            _setViewedPage(settings);

            switch (settings.name) {
              case SecondarySectionRoute.routeName:
                final Section routeSection = settings.arguments;
                builder =
                    (context) => SecondarySectionRoute(section: routeSection);
                break;
              case LessonRoute.routeName:
                final MediaSection lesson = settings.arguments;
                builder = (context) => LessonRoute(lesson: lesson);
                break;
              case TernarySectionRoute.routeName:
                final Section routeSection = settings.arguments;
                builder =
                    (context) => TernarySectionRoute(section: routeSection);
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
          home: PrimarySectionsRoute()),
    );
  }

  /// Send firebase analytics page view event.
  void _setViewedPage(RouteSettings settings) {
    String screenName = settings.name;

    if (settings.arguments is SiteDataItem) {
      final SiteDataItem data = settings.arguments;
      screenName += "/" + data.title;
    }
    if (settings.arguments is Media) {
      final Media media = settings.arguments;
      screenName += "/" + media.title ?? media.source;
    }

    analytics.setCurrentScreen(screenName: screenName.limitFromStart(100));
  }
}

/// The data version which is shipped with the app. This ensures that if a new
/// version is released with new data, that new data will be used.
final lowestDataVersion = DateTime.fromMillisecondsSinceEpoch(1595551840653);

Future<SiteBoxes> getBoxes() async {
  final boxPath = await getApplicationDocumentsDirectory();
  Hive.init('${boxPath.path}/insideapp');

  var siteBoxes = await getSiteBoxesWithData(
      currentVersion: lowestDataVersion,
      hivePath: '${boxPath.path}/siteservice_hive');

  // Only load the huge json file if we don't already have the data.
  if (siteBoxes == null) {
    siteBoxes = await getSiteBoxesWithData(
        currentVersion: lowestDataVersion,
        hivePath: '${boxPath.path}/siteservice_hive',
        rawData: await rootBundle.loadString('assets/site.json'));
  }

  return siteBoxes;
}
