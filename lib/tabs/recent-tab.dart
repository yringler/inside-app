import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/tabs/widgets/simple-media-list-widgets.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';

class RecentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MediaListTab(
        data: BlocProvider.getDependency<ChosenClassService>()
            .getSorted(recent: true));
  }
}
