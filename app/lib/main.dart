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
import 'package:inside_chassidus/util/connected.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_chassidus/util/preferences.dart';
import 'package:inside_data/inside_data.dart';
import 'package:just_audio_handlers/just_audio_handlers.dart';
import 'package:inside_chassidus/widgets/media/audio-button-bar-aware-body.dart';
import 'package:inside_chassidus/widgets/media/current-media-button-bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// When we want to force users to use latest asset on load, use this.
const assetVersion = 2;

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
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(kReleaseMode);

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  WidgetsFlutterBinding.ensureInitialized();

  final loader = JsonLoader();
  final siteBoxes = (await getBoxes(loader)) as DriftInsideData;

  final chosenService = await ChosenClassService.create(siteBoxes);
  final downloadManager = FlutterDownloaderAudioDownloader();
  final libraryPositionService = LibraryPositionService(siteBoxes: siteBoxes);
  final suggestedContent = SuggestedContentLoader(
      isConnected: waitForConnected(),
      dataLayer: siteBoxes,
      cachePath: p.join((await getApplicationSupportDirectory()).path, ''));
  final PositionSaver positionSaver = HivePositionSaver();
  final searchService = WordpressSearch(
      wordpressDomain: activeSourceDomain, siteBoxes: siteBoxes);
  final insidePreferences = await InsidePreferences.newAsync();

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
              inner: DbAccessAudioTask(
                  layer: siteBoxes,
                  preferences: insidePreferences,
                  player: AudioPlayer())),
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
    Dependency((i) => audioHandler),
    Dependency((i) => suggestedContent),
    Dependency((i) => insidePreferences)
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
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

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
  TabType _currentTab = TabType.libraryHome;

  /// Keep track of previous tab. If user goes to library from other tab, back button
  /// should return to that tab.
  TabType? _previousTab;

  final positionService = BlocProvider.getDependency<LibraryPositionService>();
  final StreamController<bool> checkCanPop = StreamController();

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

    if (_currentTab != TabType.libraryHome) {
      _previousTab = _currentTab;
      setState(() {
        _currentTab = TabType.libraryHome;
      });
    }
  }

  @override
  void dispose() {
    positionService.removeListener(onLibraryPositionChange);
    checkCanPop.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: SizedBox(
                height: .6 * kToolbarHeight,
                child: Image.asset(
                  'assets/logo.png',
                  errorBuilder: (context, error, stackTrace) =>
                      Text('Inside Chassidus'),
                )),
            leading: StreamBuilder<Object>(
                stream: checkCanPop.stream,
                builder: (context, snapshot) {
                  return _getCanPop()
                      ? BackButton(
                          onPressed: () async {
                            // Try to pop current root.
                            final currentPopped = await _getCurrentRouterKey()
                                .currentState!
                                .maybePop();

                            if (currentPopped) {
                              return;
                            }

                            // If the current route has no where to go, check if we have another tab to
                            // back up to.
                            tryChangeTab();
                          },
                        )
                      : Container();
                })),
        body: AudioButtonbarAwareBody(
            body: Material(
          child: WillPopScope(
            child: _getCurrentTab(),
            onWillPop: () async => !tryChangeTab(),
          ),
        )),
        bottomSheet: CurrentMediaButtonBar(),
        bottomNavigationBar: bottomNavigationBar(),
      );

  /// Try to change to a relevant previous tab.
  /// Returns true if successfully changes tab.
  bool tryChangeTab() {
    // Before we close the app, check if current tab was navigated to
    // from another tab.
    // If it was, back up back to that tab.

    final hasSomewhereToGo = _previousTab != null;

    if (hasSomewhereToGo) {
      setState(() {
        _currentTab = _previousTab!;
        _previousTab = null;
      });
    }

    return hasSomewhereToGo;
  }

  BottomNavigationBar bottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentTab.index,
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
    checkCanPop.add(true);
  }

  void _onBottomNavigationTap(intValue) {
    // We keep track of where user was, so that back button can go across tabs.
    // This is only cleared when user resets position by pressing on bottom navigation himself.
    _previousTab = null;

    final value = TabType.values[intValue];

    // If the home button is pressed when already on home section, we stay on the
    // lesson tab, but go back to root.
    if (value == TabType.libraryHome &&
        _currentTab == TabType.libraryHome &&
        positionService.hasContent) {
      positionService.clear();
    }

    if (value == _currentTab) {
      return;
    }

    BlocProvider.getBloc<IsPlayerButtonsShowingBloc>()
        .canGlobalButtonsShow(value == TabType.libraryHome);

    setState(() {
      _currentTab = value;
    });
  }

  Widget _getCurrentTab() {
    switch (_currentTab) {
      case TabType.libraryHome:
        return LessonTab(
          navigatorKey: widget.lessonNavigatorKey,
        );
      case TabType.recent:
        return RecentsTab(
          navigatorKey: widget.recentsKey,
          routeState: widget.recentState,
        );
      case TabType.favorites:
        return FavoritesTab(
          navigatorKey: widget.favoritesKey,
          routeState: widget.favoritesState,
        );
      case TabType.search:
        return SearchResultsTab(
            navigatorKey: widget.searchKey, routeState: widget.searchState);
      case TabType.nowPlaying:
        return NowPlayingTab();
      default:
        throw ArgumentError('Invalid tab index');
    }
  }

  bool _getCanPop() {
    switch (_currentTab) {
      case TabType.libraryHome:
        return positionService.hasContent;
      case TabType.recent:
        return widget.recentState.hasMedia();
      case TabType.favorites:
        return widget.favoritesState.hasMedia();
      case TabType.search:
        return widget.searchState.hasMedia();
      case TabType.nowPlaying:
        return false;
      default:
        throw ArgumentError('Called with invalid index');
    }
  }

  GlobalKey<NavigatorState> _getCurrentRouterKey() {
    switch (_currentTab) {
      case TabType.libraryHome:
        return widget.lessonNavigatorKey;
      case TabType.recent:
        return widget.recentsKey;
      case TabType.favorites:
        return widget.favoritesKey;
      case TabType.search:
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

  final resourceExists = await resourceFile.exists();

  // Create resource file which can be used from background isolate.
  if (!resourceExists) {
    final blob = await rootBundle.load('assets/site.$assetVersion.sqlite.gz');
    await File(_getResourceFilePath(resourceFileFolder)).writeAsBytes(
        gzip.decode(
            blob.buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes)),
        flush: true);
  }

  // The second argument is if we should force reload DB from resource.
  // If the requested resource doesn't exist, that means the app version changed, and
  // we want to use the resource version.
  await compute(_ensureDataLoaded, [resourceFileFolder, !resourceExists]);

  final siteData = await DriftInsideData.fromIsolate(
      folder: resourceFileFolder,
      loader: loader,
      topIds: topImagesInside.keys.map((e) => e.toString()).toList());

  await siteData.init();

  /* Note we don't await this - we want app to be usable as data is updated in background. */
  siteData.prepareUpdate();

  return siteData;
}

String _getResourceFilePath(String folder) =>
    p.join(folder, 'resource.$assetVersion.sqlite');

/// NOTE: This is expected to be run in another isolate.
/// Do not connect to DB on main isolate before this returns.
/// Make sure that there is data loaded.
Future<void> _ensureDataLoaded(List<dynamic> args) async {
  final dbFolder = args[0] as String;
  final forceRefreshFromResource = args[1] as bool;

  final siteData = DriftInsideData.fromFolder(
      folder: dbFolder,
      loader: JsonLoader(),
      topIds: topImagesInside.keys.map((e) => e.toString()).toList());

  await siteData.init(
      preloadedDatabase: File(_getResourceFilePath(dbFolder)),
      forceRefresh: forceRefreshFromResource);

  await siteData.close();
}

class AnalyticsLogger extends AudioLogger {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Future<void> onComplete(MediaItem item) async {
    analytics.logEvent(
        name: "completed_class",
        parameters: {"class_source": item.id.limitFromEnd(100) ?? ""});
  }
}

class DbAccessAudioTask extends AudioHandlerJustAudio {
  final SiteDataLayer layer;
  final InsidePreferences preferences;

  DbAccessAudioTask(
      {required this.layer,
      required this.preferences,
      required AudioPlayer player})
      : super(player: player) {
    player.setSpeed(preferences.currentSpeed);
  }

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
                start: Duration.zero, originalUri: Uri.parse(media.mediaSource))
            .toExtra());
  }

  @override
  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    // Add the playing media id to recent classes.

    final media = await layer.media(mediaId);

    if (media != null) {
      BlocProvider.getDependency<ChosenClassService>()
          .set(media: media, isRecent: true);
    }

    return super.playFromMediaId(mediaId, extras);
  }

  @override
  Future<void> setSpeed(double speed) async {
    preferences.setSpeed(speed);
    await super.setSpeed(speed);
  }
}

enum TabType { libraryHome, recent, favorites, search, nowPlaying }
