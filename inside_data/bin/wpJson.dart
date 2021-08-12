import 'dart:convert';

import 'package:inside_data/src/loaders/wordpress/wordpress_repository.dart';

Future<void> main(List<String> args) async {
  final id = args.isNotEmpty ? int.tryParse(args.first) ?? 16 : 16;

  const domain = 'insidechassidus.org';
  final repository = WordpressRepository(wordpressDomain: domain);
  final data = await repository.category(id);

  print(jsonEncode(data.toJson()));
}
