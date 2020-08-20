import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inside_api/models.dart';
import 'package:inside_chassidus/routes/player-route/index.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class.dart';

/// A list of media, with navigation to a player.
class MediaListTab extends StatelessWidget {
  final List<ChoosenClass> data;

  MediaListTab({this.data});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        Widget route;

        if (settings.name == '/') {
          route = ChosenDataList(data: data);
        } else if (settings.name == PlayerRoute.routeName) {
          final Media media = settings.arguments;
          route = PlayerRoute(media: media);
        }

        return CupertinoPageRoute(builder: (_) => route);
      },
    );
  }
}

/// A list of media.
class ChosenDataList extends StatelessWidget {
  final List<ChoosenClass> data;

  ChosenDataList({this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container();
    }

    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];

          return ListTile(
            title: Text(item.media.title),
            subtitle: Text(
              item.media.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(PlayerRoute.routeName, arguments: item.media);
            },
          );
        });
  }
}
