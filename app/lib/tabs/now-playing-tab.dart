import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/routes/player-route/index.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';
import 'package:inside_data/inside_data.dart';

class NowPlayingTab extends StatelessWidget {
  final chosenClassService = BlocProvider.getDependency<ChosenClassService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Media?>(
        stream: chosenClassService.mostRecent,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'Nothing is playing. What do you want to learn?',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            );
          }

          return PlayerRoute(media: snapshot.data!);
        });
  }
}
