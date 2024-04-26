import 'dart:convert';

import 'package:inside_data/inside_data.dart';
import 'package:inside_data/src/loaders/wordpress/wordpress_repository.dart';

Future<void> main(List<String> args) async {
  final id = args.isNotEmpty ? int.tryParse(args.first) ?? 16 : 16;

  const domain = homedomain;
  final repository = WordpressRepository(wordpressDomain: domain);
  await repository.category(id);

  final encoder = JsonEncoder.withIndent('\t');
  print(encoder.convert([
    ...repository.groups.values.toList(),
    ...repository.posts.values.toList()
  ]));
}
