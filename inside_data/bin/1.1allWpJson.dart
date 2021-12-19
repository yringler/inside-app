import 'dart:convert';

import 'package:inside_data/inside_data.dart';
import 'package:inside_data/src/loaders/wordpress/wordpress_repository.dart';

Future<void> main(List<String> args) async {
  const domain = 'insidechassidus.org';
  final repository = WordpressRepository(wordpressDomain: domain);

  await Future.wait(
      topImagesInside.keys.map((e) => repository.category(e)).toList());

  final encoder = JsonEncoder.withIndent('\t');
  print(encoder.convert([
    ...repository.groups.values.toList(),
    ...repository.posts.values.toList()
  ]));
}
