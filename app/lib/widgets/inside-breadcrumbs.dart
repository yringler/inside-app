import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb_menu/flutter_breadcrumb_menu.dart';
import 'package:inside_api/models.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';

class InsideBreadcrumbs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = BlocProvider.getDependency<LibraryPositionService>();

    if (service.sections.isEmpty) {
      return Container();
    }

    return Breadcrumb<SiteDataItem>(
      breads: [
        for (var position in service.sections)
          Bread(label: getLabel(position.data!), route: position.data)
      ],
      onValueChanged: (value) => service.setActiveItem(value),
    );
  }

  getLabel(SiteDataItem data) => data.title!.trim().split(' ').take(5).join(' ');
}
