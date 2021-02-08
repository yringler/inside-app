import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inside_api/models.dart';
import 'package:inside_api/site-service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:inside_chassidus/blocs/is-player-buttons-showing.dart';
import 'package:inside_chassidus/routes/primary-section-route.dart';
import 'package:inside_chassidus/tabs/favorites-tab.dart';
import 'package:inside_chassidus/tabs/lesson-tab/lesson-tab.dart';
import 'package:inside_chassidus/tabs/now-playing-tab.dart';
import 'package:inside_chassidus/tabs/recent-tab.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:just_audio_service/position-manager/position-data-manager.dart';
import 'package:just_audio_service/position-manager/position-manager.dart';
import 'package:just_audio_service/download-manager/download-manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:inside_chassidus/widgets/media/audio-button-bar-aware-body.dart';
import 'package:inside_chassidus/widgets/media/current-media-button-bar.dart';

void main() async {
  runApp(MaterialApp(
      home: Scaffold(
    body: Center(child: CircularProgressIndicator()),
  )));

  await Firebase.initializeApp();

  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  WidgetsFlutterBinding.ensureInitialized();

  final siteBoxes = await getBoxes();
  final chosenService = await ChosenClassService.create();
  final downloadManager = ForgroundDownloadManager(maxDownloads: 10);
  final libraryPositionService = LibraryPositionService(siteBoxes: siteBoxes);
  await downloadManager.init();

  runApp(BlocProvider(
    dependencies: [
      Dependency(
          (i) => PositionManager(positionDataManager: PositionDataManager())),
      Dependency((i) => siteBoxes),
      Dependency((i) => chosenService),
      Dependency((i) => downloadManager),
      Dependency((i) => libraryPositionService)
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

  bool _lessonRouteOnRoot = true;

  final positionService = BlocProvider.getDependency<LibraryPositionService>();

  MyAppState() {
    positionService.addListener(onLibraryPositionChange);
  }

  /// Hide the global media controls if on media player route.
  onLibraryPositionChange() {
    final last = positionService.sections.lastOrNull;
    final isMediaButtonsShowing = last != null && last is Media;

    BlocProvider.getBloc<IsPlayerButtonsShowingBloc>()
        .isOtherButtonsShowing(isShowing: isMediaButtonsShowing);
  }

  @override
  void dispose() {
    positionService.removeListener(onLibraryPositionChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appTitle,
        theme: ThemeData(primarySwatch: Colors.grey),
        home: AudioServiceWidget(
          child: WillPopScope(
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
                      isActive: _currentTabIndex == 0,
                    ),
                  ),
                  if (_currentTabIndex != 0) Material(child: _getCurrentTab())
                ],
              )),
              bottomSheet: CurrentMediaButtonBar(),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentTabIndex,
                onTap: _onBottomNavigationTap,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    activeIcon: Icon(
                      Icons.home,
                      color: Colors.brown,
                    ),
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    activeIcon: Icon(
                      Icons.queue_music,
                      color: Colors.blue,
                    ),
                    icon: Icon(Icons.queue_music),
                    label: 'Recent',
                  ),
                  BottomNavigationBarItem(
                      activeIcon: Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      icon: Icon(Icons.favorite),
                      label: 'Bookmarked'),
                  BottomNavigationBarItem(
                      activeIcon: Icon(
                        Icons.play_circle_filled,
                        color: Colors.black,
                      ),
                      icon: Icon(Icons.play_circle_outline),
                      label: 'Now Playing')
                ],
              ),
            ),
          ),
        ),
      );

  void _onBottomNavigationTap(value) {
    // If the home button is pressed when already on home section, we show the
    // lesson tab, but go back to root.
    if (value == 0 && _currentTabIndex == 0 && !_lessonRouteOnRoot) {
      lessonNavigatorKey.currentState.pushNamedAndRemoveUntil(
          PrimarySectionsRoute.routeName, (_) => false);
    }

    if (value == _currentTabIndex) {
      return;
    }

    BlocProvider.getBloc<IsPlayerButtonsShowingBloc>()
        .canGlobalButtonsShow(value == 0);

    setState(() {
      _currentTabIndex = value;
    });
  }

  Widget _getCurrentTab() {
    switch (_currentTabIndex) {
      case 0:
        throw ArgumentError('Can not render home');
      case 1:
        return RecentsTab();
      case 2:
        return FavoritesTab();
      case 3:
        return NowPlayingTab();
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

  final hasData = await compute(_ensureDataLoaded, [servicePath]);

  // Only load the huge json file if we don't already have the data.
  if (!hasData) {
    // Assume that the data bundled with the app is of the correct version.
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
