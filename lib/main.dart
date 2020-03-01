import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';
import 'package:inside_chassidus/data/media-manager.dart';
import 'package:inside_chassidus/data/repositories/app-data.dart';
import 'package:inside_chassidus/data/repositories/recently-played-repository.dart';
import 'package:inside_chassidus/routes/lesson-route/index.dart';
import 'package:inside_chassidus/routes/player-route/player-route.dart';
import 'package:inside_chassidus/routes/primary-section-route.dart';
import 'package:inside_chassidus/routes/secondary-section-route/index.dart';
import 'package:inside_chassidus/routes/ternary-section-route.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = false;

  // Pass all uncaught errors from the framework to Crashlytics.

  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(BlocProvider(
    blocs: [
      Bloc((i) => MediaManager(
          recentlyPlayedRepository:
              i.getDependency<RecentlyPlayedRepository>()))
    ],
    dependencies: [
      Dependency((i) => AppData()),
      Dependency((i) => RecentlyPlayedRepository())
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  _MyAppState createState() {
    MyApp.analytics.logAppOpen();
    return _MyAppState(analytics: analytics);
  }
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final FirebaseAnalytics analytics;

  _MyAppState({this.analytics});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inside Chassidus',
      theme: ThemeData(primarySwatch: Colors.grey),
      onGenerateRoute: (settings) {
        WidgetBuilder builder;

        _setViewedPage(settings);

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
        future: initData(context),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    connect();
  }

  @override
  void dispose() {
    disconnect();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        connect();
        break;
      case AppLifecycleState.paused:
        disconnect();
        break;
      default:
        break;
    }
  }

  void connect() async {
    await AudioService.connect();
  }

  void disconnect() {
    AudioService.disconnect();
  }

  /// Initilize and load from hive data.
  initData(BuildContext context) async {
    await AppData.init(context);

    final isAudioRunning = await AudioService.running;

    final positionRepository =
        BlocProvider.getDependency<RecentlyPlayedRepository>();
    await positionRepository.init(loadBackgroundPositions: !isAudioRunning);
    await BlocProvider.getBloc<MediaManager>().init();
  }

  /// Send firebase analytics page view event.
  void _setViewedPage(RouteSettings settings) {
        String screenName = settings.name;
        
        if (settings.arguments is InsideDataBase) {
          final InsideDataBase data = settings.arguments;
          screenName += "/" + data.title;
        }
        if (settings.arguments is Media) {
          final Media media = settings.arguments;
          screenName += "/" + media.title ?? media.source;
        }


        analytics.setCurrentScreen(screenName: screenName.limitFromStart(100));
      }
}
