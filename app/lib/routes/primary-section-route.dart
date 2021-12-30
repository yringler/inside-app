import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/widgets/navigate-to-section.dart';
import 'package:inside_data/inside_data.dart';

class PrimarySectionsRoute extends StatelessWidget {
  static const String routeName = '/library';

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

  List<Widget> _promotedContent(BuildContext context) => [
        HomepageSection(
            context: context,
            title: 'Featured Classes',
            child: AspectRatio(
              aspectRatio: 9 / 3,
              child: Image.network(
                'https://media.insidechassidus.org/wp-content/uploads/20211125105910/chanuka.gif',
              ),
            )),
        HomepageSection(
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
                        child: ElevatedButton(
                          onPressed: () => null,
                          child: Text('Tanya'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 7.5),
                        child: ElevatedButton(
                          onPressed: () => null,
                          child: Text('Hayom Yom'),
                        ),
                      ),
                    ),
                  ],
                ),
                OutlinedButton(
                  onPressed: () => null,
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
            )),
      ];

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
  const HomepageSection({
    Key? key,
    required this.context,
    required this.title,
    required this.child,
  }) : super(key: key);

  final BuildContext context;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Text(title,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.headline6!.fontSize)),
        ),
        child
      ],
    );
  }
}
