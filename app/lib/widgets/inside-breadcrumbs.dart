import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb_menu/flutter_breadcrumb_menu.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_data_flutter/inside_data_flutter.dart';

class InsideBreadcrumbs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = BlocProvider.getDependency<LibraryPositionService>();

    if (service.sections.isEmpty) {
      return Container();
    }

    return Breadcrumb<SiteDataBase>(
      breads: [
        for (var position in service.sections)
          Bread(label: getLabel(position.data!), route: position.data)
      ],
      onValueChanged: (value) => service.setActiveItem(value),
    );
  }

  getLabel(SiteDataBase data) => data.title.trim().split(' ').take(5).join(' ');
}
