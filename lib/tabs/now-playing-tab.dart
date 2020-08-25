import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/routes/player-route/index.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';

class NowPlayingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chosenClassService = BlocProvider.getDependency<ChosenClassService>();
    final mostRecentlyPlayingList = chosenClassService.getSorted(recent: true);

    if (mostRecentlyPlayingList.isEmpty) {
      return Center(
        child: Text('Nothing is playing. What do you want to learn?'),
      );
    }

    return PlayerRoute(media: mostRecentlyPlayingList.first.media);
  }


}
