import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:inside_api/models.dart';
import 'package:inside_api/site-service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:inside_chassidus/blocs/is-player-buttons-showing.dart';
import 'package:inside_chassidus/routes/primary-section-route.dart';
import 'package:inside_chassidus/tabs/lesson-tab/lesson-tab.dart';
import 'package:just_audio_service/position-manager/position-data-manager.dart';
import 'package:just_audio_service/position-manager/position-manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:inside_chassidus/widgets/media/audio-button-bar-aware-body.dart';
import 'package:inside_chassidus/widgets/media/current-media-button-bar.dart';

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
    blocs: [Bloc((i) => IsPlayerButtonsShowingBloc())],
    child: MyApp(),
  ));

  await siteBoxes.tryPrepareUpdate();

  MyApp.analytics.logAppOpen();
}

class MyApp extends StatefulWidget {
  static final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  State<StatefulWidget> createState() => MyAppState();
}

const String appTitle = 'Inside Chassidus';

class MyAppState extends State<MyApp> {
  GlobalKey<NavigatorState> lessonNavigatorKey = GlobalKey();

  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) => AudioServiceWidget(
          child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appTitle,
        theme: ThemeData(primarySwatch: Colors.grey),
        home: WillPopScope(
          onWillPop: () async =>
              !await lessonNavigatorKey.currentState.maybePop(),
          child: Scaffold(
            appBar: AppBar(title: Text('Inside Chassidus')),
            body: AudioButtonbarAwareBody(
                body: Stack(
              children: [
                Offstage(
                  offstage: _currentTabIndex != 0,
                  child: LessonTab(
                    navigatorKey: lessonNavigatorKey,
                    onRouteChange: _onLessonRouteChange,
                  ),
                ),
                if (_currentTabIndex > 0) _getCurrentTab()
              ],
            )),
            bottomSheet: CurrentMediaButtonBar(),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentTabIndex,
              onTap: _onBottomNavigationTap,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), title: Text('Home')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.queue_music), title: Text('Recent')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite), title: Text('Bookmarked'))
              ],
            ),
          ),
        ),
      ));

  void _onBottomNavigationTap(value) {
    // If the home button is pressed when already on home section, we show the
    // lesson tab, but go back to root.
    if (value == 0 && _currentTabIndex == 0) {
      lessonNavigatorKey.currentState.pushNamedAndRemoveUntil(
          PrimarySectionsRoute.routeName, (_) => false);
    }

    // It's only possible for a tab to be showing buttons if it's a tab which
    // might be showing buttons.
    BlocProvider.getBloc<IsPlayerButtonsShowingBloc>()
        .isPossiblePlayerButtonsShowing(isPossible: value == 0);

    setState(() {
      _currentTabIndex = value;
    });
  }

  /// Send firebase analytics page view event.
  void _onLessonRouteChange(RouteSettings routeData) {
    String screenName = routeData.name;
    SiteDataItem data =
        routeData.arguments == null ? null : routeData.arguments;

    if (data != null) {
      screenName += "/" + data.title;

      if (data is Media) {
        final Media media = data;
        screenName += "/" + media.title ?? media.source;
      }
    }

    MyApp.analytics
        .setCurrentScreen(screenName: screenName.limitFromStart(100));
  }

  Widget _getCurrentTab() {
    switch (_currentTabIndex) {
      case 0:
        throw ArgumentError('Can not render primary tab');
      case 1:
        return Text('Recent');
      case 2:
        return Text('Favorites');
      default:
        throw ArgumentError('Invalid tab index');
    }
  }
}

/// Ensure that any source JSON is parsed and loaded in to hive, return
/// open boxes.
Future<SiteBoxes> getBoxes() async {
  final boxPath = await getApplicationDocumentsDirectory();
  final servicePath = '${boxPath.path}/siteservice_hive';
  Hive.init('${boxPath.path}/insideapp');

  var hasData = await compute(_ensureDataLoaded, [servicePath]);

  // Only load the huge json file if we don't already have the data.
  if (!hasData) {
    final rawData = await rootBundle.loadString('assets/site.json');
    await compute(_ensureDataLoaded, [servicePath, rawData]);
  }

  return await getSiteBoxesWithData(hivePath: servicePath);
}

/// Make sure that there is data loaded in to hive. Return true if there is data.
Future<bool> _ensureDataLoaded(List<dynamic> args) async {
  final path = args[0] as String;
  final boxes = await getSiteBoxesWithData(
      hivePath: path, rawData: args.length == 2 ? args.last as String : null);

  if (boxes == null) {
    return false;
  }

  await boxes.hive.close();
  return true;
}
