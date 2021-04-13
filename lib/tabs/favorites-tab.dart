import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/tabs/widgets/simple-media-list-widgets.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';

class FavoritesTab extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final MediaListTabRoute routeState;

  FavoritesTab({required this.navigatorKey, required this.routeState});

  @override
  Widget build(BuildContext context) {
    return MediaListTab(
        navigatorKey: navigatorKey,
        mediaTabRoute: routeState,
        emptyMessage:
            'No favorites set. You can set favorites from the player.',
        data: BlocProvider.getDependency<ChosenClassService>()
            .getSorted(favorite: true));
  }
}
