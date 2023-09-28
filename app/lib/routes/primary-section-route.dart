import 'dart:async';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inside_chassidus/util/connected.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_chassidus/widgets/navigate-to-section.dart';
import 'package:inside_data/inside_data.dart';

class PrimarySectionsRoute extends StatelessWidget {
  static const String routeName = '/library';
  final SuggestedContentLoader suggestedContentLoader =
      BlocProvider.getDependency<SuggestedContentLoader>();
  final positionService = BlocProvider.getDependency<LibraryPositionService>();
  final SiteDataLayer dataLayer = BlocProvider.getDependency<SiteDataLayer>();

  @override
  Widget build(BuildContext context) {
    final layer = BlocProvider.getDependency<SiteDataLayer>();
    return FutureBuilder<List<Section>>(
        future: layer.topLevel(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return ListView(
            children: [
              ..._promotedContent(context),
              HomepageSection(
                  context: context,
                  title: 'Browse Categories',
                  child: _sections(context, snapshot.data!, layer))
            ],
            padding: EdgeInsets.all(15),
          );
        });
  }

  List<Widget> _promotedContent(BuildContext context) {
    return [
      PossibleContentBuilder<List<FeaturedSectionVerified>>(
          mapper: (p0) => p0.featured,
          onTap: (featuredSections) => positionService
              .setActiveItem(featuredSections.first.section, backToTop: true),
          builder: (context, data, onPressed) {
            return HomepageSection(
                isFirst: true,
                context: context,
                title: 'Featured Classes',
                child: _featuredClass(
                    data: data, context: context, onPressed: onPressed));
          }),
      _restOfPromotedContent(context),
    ];
  }

  Widget _featuredClass(
      {List<FeaturedSectionVerified>? data,
      required BuildContext context,
      required VoidCallback onPressed}) {
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onPressed,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight / 3),
          child: AspectRatio(
            aspectRatio: 9 / 3,
            child: Stack(
              children: [
                if ((data?.first.imageUrl ?? '').isNotEmpty)
                  Positioned.fill(
                    child: CachedNetworkImage(imageUrl: data!.first.imageUrl),
                  ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      backgroundBlendMode: BlendMode.darken),
                  padding: const EdgeInsets.only(left: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data?.first.title ?? 'Featured class',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: Colors.white)),
                      ElevatedButton(
                          onPressed: onPressed,
                          style:
                              ElevatedButton.styleFrom(backgroundColor: Colors.white),
                          child: Text(
                            data?.first.buttonText ?? 'Learn More',
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  HomepageSection _restOfPromotedContent(BuildContext context) {
    return HomepageSection(
        context: context,
        title: 'Daily Study',
        child: ElevatedButtonTheme(
          data: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.black45)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 7.5),
                        child: PossibleContentBuilder<SiteDataBase>(
                          mapper: (p0) => p0.timelyContent?.tanya?.value,
                          onTap: (data) => positionService.setActiveItem(data,
                              backToTop: true),
                          builder: (context, data, onTap) => ElevatedButton(
                            onPressed: onTap,
                            child: Text('Tanya'),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 7.5),
                        child: PossibleContentBuilder<SiteDataBase>(
                          mapper: (p0) => p0.timelyContent?.hayomYom?.value,
                          onTap: (data) => positionService.setActiveItem(data,
                              backToTop: true),
                          builder: (context, data, onTap) => ElevatedButton(
                            onPressed: onTap,
                            child: Text('Hayom Yom'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PossibleContentBuilder<SiteDataBase>(
                onTap: (data) =>
                    positionService.setActiveItem(data, backToTop: true),
                mapper: (p0) => p0.timelyContent?.parsha?.value,
                builder: (context, data, onTap) => _FullWidthButton(
                    onTap: onTap,
                    title: 'Current Parsha',
                    icon: FontAwesomeIcons.bookOpen),
              ),
              PossibleContentBuilder<SiteDataBase>(
                onTap: (data) =>
                    positionService.setActiveItem(data, backToTop: true),
                mapper: (p0) => p0.timelyContent?.monthly?.value,
                builder: (context, data, onTap) => _FullWidthButton(
                    onTap: onTap,
                    title: 'This Month',
                    icon: Icons.calendar_today),
              ),
              PossibleContentBuilder<List<ContentReference>>(
                mapper: (p0) => p0.popular,
                onTap: (data) =>
                    positionService.setVirtualSection(content: data),
                builder: (context, data, onTap) => _FullWidthButton(
                    icon: Icons.signal_cellular_alt,
                    onTap: onTap,
                    title: 'Most Popular Classes'),
              ),
              FutureBuilder<List<Media>>(
                future: dataLayer.recent(),
                builder: (context, data) {
                  VoidCallback? onPressed;

                  if (data.hasData) {
                    onPressed = () => positionService.setVirtualSection(
                        content: data.data!
                            .map((e) => ContentReference.fromData(data: e))
                            .toList());
                  }

                  return _FullWidthButton(
                    icon: Icons.schedule,
                    onTap: onPressed ?? () {},
                    title: 'Recently Uploaded Classes',
                  );
                },
              ),
            ],
          ),
        ));
  }

  Widget _sections(BuildContext context, List<Section> topLevel,
          SiteDataLayer dataLayer) =>
      FutureBuilder<bool>(
          future: waitForConnected(),
          builder: (context, snapshot) => GridView.extent(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  maxCrossAxisExtent: 200,
                  padding: const EdgeInsets.all(4),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: [
                    for (var topItem in topLevel)
                      _primarySection(dataLayer, topItem, context)
                  ]));

  Widget _primarySection(
      SiteDataLayer dataLayer, Section primaryInside, BuildContext context) {
    final image = dataLayer.getImageFor(primaryInside.id);
    return NavigateToSection(
      section: primaryInside,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.bottomLeft,
        children: <Widget>[
          if (image != null && image.isNotEmpty)
            CachedNetworkImage(
                errorWidget: (context, url, error) => FutureBuilder<void>(
                      builder: (context, snapshot) => _greyBox(),
                      future: CachedNetworkImage.evictFromCache(url),
                    ),
                imageUrl: image,
                repeat: ImageRepeat.noRepeat,
                fit: BoxFit.cover,
                height: 500,
                width: 500,
                color: Colors.black54,
                colorBlendMode: BlendMode.darken)
          else
            _greyBox(),
          Container(
              padding: EdgeInsets.fromLTRB(8, 0, 0, 8),
              child: Text(primaryInside.title.toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3)),
        ],
      ),
    );
  }

  SizedBox _greyBox() => SizedBox(
        height: 500,
        width: 500,
        child: Container(
          decoration: BoxDecoration(color: Colors.grey.shade700),
        ),
      );
}

class _FullWidthButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final IconData icon;

  _FullWidthButton(
      {Key? key, required this.onTap, required this.title, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey.shade800, padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
      onPressed: onTap,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            //TODO: We use this icon across the board, is it good? Should we make it smaller? Change it everywhere perhaps?
            child: Icon(icon),
          ),
          Text(title),
          Spacer(),
          Icon(Icons.arrow_forward_ios)
        ],
      ),
    );
  }
}

class HomepageSection extends StatelessWidget {
  const HomepageSection(
      {Key? key,
      required this.context,
      required this.title,
      required this.child,
      this.isFirst = false})
      : super(key: key);

  final BuildContext context;
  final String title;
  final Widget child;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(top: isFirst ? 0 : 10, bottom: 5),
            child: Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                  fontSize: Theme.of(context).textTheme.titleLarge!.fontSize),
              textScaleFactor: .8,
            ),
          ),
          child
        ],
      ),
    );
  }
}

/*
  widget: PossibleContentBuilder<InputT, UseT>
  args: FutureOrValue which resolves to data to use
  mapper UseT func(InputT) (default identity function) which extracts needed data
  builder(context, UseT?, voidcallback?) - if there's no data, the callback will open a toast with a message.
  If there's data, void callback will be null.

  (timely content is used for a few buttons, so for that we'd make the request outside, and pass in a value)
 */

/// Build a widget which hopes to get some dynamic content.
typedef Widget PossibleContentCallback<T>(
    BuildContext context, T? data, VoidCallback onTap);

/// A callback to call if we manage to get data.
typedef void PossibleContentOnTap<T>(T data);

class PossibleContentBuilder<UseT> extends StatelessWidget {
  final PossibleContentCallback<UseT> builder;

  /// Call for child to call when tapped, if and when we get data.
  final PossibleContentOnTap<UseT> onTap;
  final suggestedContent =
      BlocProvider.getDependency<SuggestedContentLoader>().suggestedContent;
  late final UseT? Function(SuggestedContent) mapper;

  PossibleContentBuilder({
    Key? key,
    required this.onTap,
    UseT? Function(SuggestedContent)? mapper,
    required this.builder,
  }) : super(key: key) {
    this.mapper = mapper ?? (input) => input as UseT?;
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<SuggestedContent?>(
        stream: suggestedContent,
        initialData: suggestedContent.valueOrNull,
        builder: (context, snapshot) {
          VoidCallback onClick;
          final mappedData =
              snapshot.data == null ? null : mapper(snapshot.data!);

          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active) {
            onClick = () => _showMessage(
                context: context,
                message:
                    "The classes are not loaded yet. Please try again soon. Ensure you have an active internet connection.");
          } else if (snapshot.hasError) {
            onClick = () => _showMessage(
                context: context,
                message:
                    'An error occured. Classes could not be retrieved, and may not be available now.'
                    ' If this error continues, please let us know.');
          } else if (mappedData == null) {
            onClick = () => _showMessage(
                context: context,
                message:
                    "These classes aren't available right now. Please try again later");
          } else {
            onClick = () => onTap(mappedData);
          }

          return builder(context, mappedData, onClick);
        },
      );

  Future<void> _showMessage(
      {required BuildContext context, required String message}) async {
    await showDialog(
        context: context,
        builder: (BuildContext c) => AlertDialog(
              title: Text(message),
              actions: [
                TextButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    child: Text('Ok'))
              ],
            ));
  }
}
