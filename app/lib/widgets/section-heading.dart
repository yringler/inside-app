import 'package:flutter/material.dart';
import 'package:inside_data/inside_data.dart';
import 'package:share_plus/share_plus.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    Key? key,
    required this.section,
  }) : super(key: key);

  final Section section;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          Expanded(
              child: Text(section.title,
                  style: Theme.of(context).textTheme.titleLarge)),
          if (section.link.isNotEmpty)
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () => Share.share('${section.title} ${section.link}'),
            )
        ]),
        if (section.description.isNotEmpty)
          Text(
            section.description,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Colors.grey.shade600),
          )
      ],
    );
  }
}
