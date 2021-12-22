import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:inside_chassidus/blocs/is-player-buttons-showing.dart';
import 'package:inside_chassidus/tabs/favorites-tab.dart';
import 'package:inside_chassidus/tabs/lesson-tab/lesson-tab.dart';
import 'package:inside_chassidus/tabs/now-playing-tab.dart';
import 'package:inside_chassidus/tabs/recent-tab.dart';
import 'package:inside_chassidus/tabs/search-tab.dart';
import 'package:inside_chassidus/tabs/widgets/simple-media-list-widgets.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_data/inside_data.dart';
import 'package:just_audio_handlers/just_audio_handlers.dart';
import 'package:inside_chassidus/widgets/media/audio-button-bar-aware-body.dart';
import 'package:inside_chassidus/widgets/media/current-media-button-bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() async {
  runApp(MaterialApp(
      home: Scaffold(
    body: Center(child: CircularProgressIndicator()),
  )));

  await Firebase.initializeApp();
  FlutterDownloaderAudioDownloader.init();
  await HivePositionSaver.init();

  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  WidgetsFlutterBinding.ensureInitialized();

  final loader = JsonLoader();
  final siteBoxes = (await getBoxes(loader)) as DriftInsideData;

  final chosenService = await ChosenClassService.create(siteBoxes);
  final downloadManager = FlutterDownloaderAudioDownloader();
  final libraryPositionService = LibraryPositionService(siteBoxes: siteBoxes);
  final PositionSaver positionSaver = HivePositionSaver();
  final searchService = WordpressSearch(
      wordpressDomain: activeSourceDomain, siteBoxes: siteBoxes);

  final session = await AudioSession.instance;
  await session.configure(AudioSessionConfiguration.speech());

  await limitDownloads(downloadManager);

  final AudioHandler audioHandler = await AudioService.init(
    builder: () => AudioHandlerDownloader(
        downloader: downloadManager,
        inner: AudioHandlerPersistPosition(
          positionRepository: positionSaver,
          inner: LoggingJustAudioHandler(
              logger: AnalyticsLogger(),
              inner:
                  DbAccessAudioTask(layer: siteBoxes, player: AudioPlayer())),
        )),
    config: AudioServiceConfig(
        androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        fastForwardInterval: const Duration(seconds: 15),
        rewindInterval: const Duration(seconds: 15),
        androidStopForegroundOnPause: true,
        androidNotificationOngoing: true),
  );

  runApp(BlocProvider(dependencies: [
    Dependency((i) => positionSaver),
    Dependency((i) => siteBoxes),
    Dependency((i) => chosenService),
    Dependency((i) => downloadManager),
    Dependency((i) => libraryPositionService),
    Dependency((i) => searchService),
    Dependency((i) => audioHandler)
  ], blocs: [
    Bloc((i) => IsPlayerButtonsShowingBloc())
  ], child: AppRouterWidget()));

  MyApp.analytics.logAppOpen();
}

/// Wraps the app in a root router.
class AppRouterWidget extends StatelessWidget {
  final routerKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appTitle,
        theme: ThemeData(primarySwatch: Colors.grey),
        home: Router(
          routerDelegate: AppRouterDelegate(navigatorKey: routerKey),
          backButtonDispatcher: RootBackButtonDispatcher(),
        ),
      );
}

/// A simple router delegate which just creates the root of the app - the entire app.
class AppRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  AppRouterDelegate({this.navigatorKey});

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        pages: [MaterialPage(key: ValueKey("apphomepage"), child: MyApp())],
        onPopPage: (route, data) => route.didPop(data),
      );

  @override
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  Future<void> setNewRoutePath(configuration) async {}
}

/// The app.
class MyApp extends StatefulWidget {
  static final FirebaseAnalytics analytics = FirebaseAnalytics();

  final GlobalKey<NavigatorState> lessonNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'library');
  final GlobalKey<NavigatorState> favoritesKey =
      GlobalKey<NavigatorState>(debugLabel: 'favorites');
  final GlobalKey<NavigatorState> recentsKey =
      GlobalKey<NavigatorState>(debugLabel: 'recents');
  final GlobalKey<NavigatorState> searchKey =
      GlobalKey<NavigatorState>(debugLabel: 'search');

  final recentState = MediaListTabRoute();
  final favoritesState = MediaListTabRoute();
  final searchState = MediaListTabRoute();

  @override
  State<StatefulWidget> createState() => MyAppState();
}

const String appTitle = 'Inside Chassidus';

/// The app state.
class MyAppState extends State<MyApp> {
  int _currentTabIndex = 0;

  final positionService = BlocProvider.getDependency<LibraryPositionService>();

  @override
  void initState() {
    super.initState();

    positionService.addListener(onLibraryPositionChange);
    positionService.addListener(rebuildForCanPop);
    widget.recentState.addListener(rebuildForCanPop);
    widget.favoritesState.addListener(rebuildForCanPop);
    widget.searchState.addListener(rebuildForCanPop);
  }

  /// Hide the global media controls if on media player route.
  /// If the position is changed and we're not on the player route, return to library
  /// in order to see the position.
  void onLibraryPositionChange() {
    final last = positionService.sections.lastOrNull;
    final isOnPlayer = last?.data != null && last!.data is Media;

    BlocProvider.getBloc<IsPlayerButtonsShowingBloc>()
        .isOtherButtonsShowing(isShowing: isOnPlayer);

    if (!(_currentTabIndex == 0 || isOnPlayer)) {
      setState(() {
        _currentTabIndex = 0;
      });
    }
  }

  @override
  void dispose() {
    positionService.removeListener(onLibraryPositionChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(appTitle),
            leading: _getCanPop()
                ? BackButton(
                    onPressed: () =>
                        _getCurrentRouterKey().currentState!.maybePop(),
                  )
                : null),
        body: AudioButtonbarAwareBody(
            body: Material(
          child: _getCurrentTab(),
        )),
        bottomSheet: CurrentMediaButtonBar(),
        bottomNavigationBar: bottomNavigationBar(),
      );

  BottomNavigationBar bottomNavigationBar() {
    return BottomNavigationBar(
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
              Icons.search,
              color: Colors.blue,
            ),
            icon: Icon(Icons.search),
            label: 'Search'),
        BottomNavigationBarItem(
            activeIcon: Icon(
              Icons.play_circle_filled,
              color: Colors.black,
            ),
            icon: Icon(Icons.play_circle_outline),
            label: 'Now Playing')
      ],
    );
  }

  void rebuildForCanPop() {
    setState(() {});
  }

  void _onBottomNavigationTap(value) {
    // If the home button is pressed when already on home section, we show the
    // lesson tab, but go back to root.
    if (value == 0 &&
        _currentTabIndex == 0 &&
        positionService.sections.isNotEmpty) {
      positionService.clear();
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
        return LessonTab(
          navigatorKey: widget.lessonNavigatorKey,
        );
      case 1:
        return RecentsTab(
          navigatorKey: widget.recentsKey,
          routeState: widget.recentState,
        );
      case 2:
        return FavoritesTab(
          navigatorKey: widget.favoritesKey,
          routeState: widget.favoritesState,
        );
      case 3:
        return SearchResultsTab(
            navigatorKey: widget.searchKey, routeState: widget.searchState);
      case 4:
        return NowPlayingTab();
      default:
        throw ArgumentError('Invalid tab index');
    }
  }

  bool _getCanPop() {
    switch (_currentTabIndex) {
      case 0:
        return positionService.sections.isNotEmpty;
      case 1:
        return widget.recentState.hasMedia();
      case 2:
        return widget.favoritesState.hasMedia();
      case 3:
        return widget.searchState.hasMedia();
      case 4:
        return false;
      default:
        throw ArgumentError('Called with invalid index');
    }
  }

  GlobalKey<NavigatorState> _getCurrentRouterKey() {
    switch (_currentTabIndex) {
      case 0:
        return widget.lessonNavigatorKey;
      case 1:
        return widget.recentsKey;
      case 2:
        return widget.favoritesKey;
      case 3:
        return widget.searchKey;
      default:
        throw ArgumentError('Called with invalid index');
    }
  }
}

/// Ensure that any source JSON is parsed and loaded in to hive, return
/// open boxes.
Future<SiteDataLayer> getBoxes(SiteDataLoader loader) async {
  final resourceFileFolder = (await getApplicationSupportDirectory()).path;
  final resourceFile = File(_getResourceFilePath(resourceFileFolder));

  // Create resource file which can be used from background isolate.
  if (!await resourceFile.exists()) {
    final blob = await rootBundle.load('assets/site.sqllite.gz');
    await File(_getResourceFilePath(resourceFileFolder)).writeAsBytes(
        gzip.decode(
            blob.buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes)),
        flush: true);
  }

  await compute(_ensureDataLoaded, [resourceFileFolder]);

  final siteData = DriftInsideData.fromFolder(
      folder: resourceFileFolder,
      loader: loader,
      topIds: topImagesInside.keys.map((e) => e.toString()).toList());

  await siteData.init();

  /* Note we don't await this - we want app to be usable as data is updated in background. */
  siteData.prepareUpdate();

  return siteData;
}

String _getResourceFilePath(String folder) => p.join(folder, 'resource.sqlite');

/// NOTE: This is expected to be run in another isolate.
/// Do not connect to DB on main isolate before this returns.
/// Make sure that there is data loaded.
Future<void> _ensureDataLoaded(List<dynamic> args) async {
  final dbFolder = args[0] as String;

  final siteData = DriftInsideData.fromFolder(
      folder: dbFolder,
      loader: JsonLoader(),
      topIds: topImagesInside.keys.map((e) => e.toString()).toList());

  await siteData.init(preloadedDatabase: File(_getResourceFilePath(dbFolder)));

  await siteData.close();
}

class AnalyticsLogger extends AudioLogger {
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Future<void> onComplete(MediaItem item) async {
    analytics.logEvent(
        name: "completed_class",
        parameters: {"class_source": item.id.limitFromEnd(100) ?? ""});
  }
}

class DbAccessAudioTask extends AudioHandlerJustAudio {
  final SiteDataLayer layer;

  DbAccessAudioTask({required this.layer, required AudioPlayer player})
      : super(player: player);

  @override
  Future<MediaItem?> getMediaItem(String mediaId) async {
    final media = await layer.media(mediaId);
    if (media == null) {
      return null;
    }

    final parent = await layer.section(media.parents.first);

    var album = parent?.title ?? '';

    if (album.isEmpty) {
      album = 'Inside Chassidus';
    }

    return MediaItem(
        id: media.id,
        title: media.title,
        artist: 'Rabbi Paltiel',
        album: album,
        duration: media.length,
        displayDescription: media.description,
        extras: ExtraSettings(
                start: Duration.zero, originalUri: Uri.parse(media.source))
            .toExtra());
  }
}
