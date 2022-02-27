import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb_menu/flutter_breadcrumb_menu.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_data/inside_data.dart';

class InsideBreadcrumbs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = BlocProvider.getDependency<LibraryPositionService>();
    // The last item in the list is the currrent item, and that will be shown more
    // prominantly somewhere else.
    if (service.sections.length < 2) {
      return Container();
    }
    final sectionsToShow =
        service.sections.sublist(0, service.sections.length - 1);
    return Breadcrumb<SiteDataBase>(
      isLastActive: true,
      breads: [
        for (var section in sectionsToShow)
          Bread(label: getLabel(section.data!), route: section.data)
      ],
      onValueChanged: (value) => service.setActiveItem(value),
    );
  }

  getLabel(SiteDataBase data) => data.title.trim().split(' ').take(5).join(' ');
}
