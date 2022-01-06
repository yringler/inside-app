import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_chassidus/widgets/navigate-to-section.dart';
import 'package:inside_data/inside_data.dart';

class PrimarySectionsRoute extends StatelessWidget {
  static const String routeName = '/library';
  final SuggestedContentLoader suggestedContentLoader =
      BlocProvider.getDependency<SuggestedContentLoader>();
  final positionService = BlocProvider.getDependency<LibraryPositionService>();

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
    final data = suggestedContentLoader.load();

    return [
      PossibleContentBuilder<List<FeaturedSectionVerified>>(
          future: data,
          mapper: (p0) => p0.featured,
          onTap: (featuredSections) => positionService
              .setActiveItem(featuredSections.first.section, backToTop: true),
          builder: (context, data, onPressed) {
            return HomepageSection(
                isFirst: true,
                context: context,
                title: 'Featured Classes',
                child: AspectRatio(
                  aspectRatio: 9 / 3,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: data?.first.imageUrl ??
                              'https://media.insidechassidus.org/wp-content/uploads/20211125105910/chanuka.gif',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data?.first.title ?? 'Featured class',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(color: Colors.white)),
                            ElevatedButton(
                                onPressed: onPressed,
                                child: Text(
                                  data?.first.buttonText ?? 'Learn More',
                                ))
                          ],
                        ),
                      )
                    ],
                  ),
                ));
          }),
      OutlinedButtonTheme(
          data: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(primary: Colors.grey.shade700)),
          child: _restOfPromotedContent(context, data)),
    ];
  }

  HomepageSection _restOfPromotedContent(
      BuildContext context, Future<SuggestedContent> data) {
    return HomepageSection(
        context: context,
        title: 'Daily Study',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 7.5),
                    child: PossibleContentBuilder<SiteDataBase>(
                      future: data,
                      mapper: (p0) => p0.timelyContent?.tanya?.value,
                      onTap: (data) =>
                          positionService.setActiveItem(data, backToTop: true),
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
                      future: data,
                      mapper: (p0) => p0.timelyContent?.hayomYom?.value,
                      onTap: (data) =>
                          positionService.setActiveItem(data, backToTop: true),
                      builder: (context, data, onTap) => ElevatedButton(
                        onPressed: onTap,
                        child: Text('Hayom Yom'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // TODO: Parsha
            // TODO: month classes, when API is updated
            PossibleContentBuilder<List<ContentReference>>(
              future: data,
              mapper: (p0) => p0.popular,
              onTap: (data) => positionService.setVirtualSection(content: data),
              builder: (context, data, onTap) {
                return OutlinedButton(
                  onPressed: onTap,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        //TODO: We use this icon across the board, is it good? Should we make it smaller? Change it everywhere perhaps?
                        child: Icon(Icons.signal_cellular_alt),
                      ),
                      Text('Most Popular Classes'),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios)
                    ],
                  ),
                );
              },
            ),
            OutlinedButton(
              onPressed: () => null,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Icon(Icons.schedule),
                  ),
                  Text('Recently Uploaded Classes'),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios)
                ],
              ),
            ),
          ],
        ));
  }

  Widget _sections(BuildContext context, List<Section> topLevel,
          SiteDataLayer dataLayer) =>
      GridView.extent(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          maxCrossAxisExtent: 200,
          padding: const EdgeInsets.all(4),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: [
            for (var topItem in topLevel)
              _primarySection(dataLayer, topItem, context)
          ]);

  Widget _primarySection(
      SiteDataLayer dataLayer, Section primaryInside, BuildContext context) {
    final image = dataLayer.getImageFor(primaryInside.id);
    return NavigateToSection(
      section: primaryInside,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.bottomLeft,
        children: <Widget>[
          if (image != null)
            CachedNetworkImage(
                imageUrl: image,
                repeat: ImageRepeat.noRepeat,
                fit: BoxFit.cover,
                height: 500,
                width: 500,
                color: Colors.black54,
                colorBlendMode: BlendMode.darken),
          Container(
              padding: EdgeInsets.fromLTRB(8, 0, 0, 8),
              child: Text(primaryInside.title.toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: Theme.of(context).textTheme.headline6!.fontSize,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(top: isFirst ? 0 : 10, bottom: 5),
          child: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
                fontSize: Theme.of(context).textTheme.headline6!.fontSize),
            textScaleFactor: .8,
          ),
        ),
        child
      ],
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
    BuildContext context, T? data, VoidCallback? onTap);

/// A callback to call if we manage to get data.
typedef void PossibleContentOnTap<T>(T data);

class PossibleContentBuilder<UseT> extends StatelessWidget {
  final PossibleContentCallback<UseT> builder;

  /// Call for child to call when tapped, if and when we get data.
  final PossibleContentOnTap<UseT> onTap;
  final Future<SuggestedContent> future;
  late final UseT? Function(SuggestedContent) mapper;

  PossibleContentBuilder(
      {Key? key,
      required this.builder,
      required this.onTap,
      required this.future,
      UseT? Function(SuggestedContent)? mapper})
      : super(key: key) {
    this.mapper = mapper ?? (input) => input as UseT?;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<SuggestedContent>(
        future: future,
        builder: (context, snapshot) {
          VoidCallback onClick;
          final mappedData =
              snapshot.data == null ? null : mapper(snapshot.data!);

          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active) {
            onClick = () => _showMessage(
                context: context,
                message:
                    "The classes are not loaded yet. Please try again soon.");
          } else if (snapshot.hasError) {
            onClick = () => _showMessage(
                context: context,
                message:
                    'An error occured. Classes could not be retrieved. Do you have an internet connection?'
                    ' Classes may not be available now.'
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
