import 'dart:convert';

import 'package:inside_data/src/loaders/wordpress_loader.dart';

Future<void> main(List<String> args) async {
  final id = args.isNotEmpty ? int.tryParse(args.first) ?? 16 : 16;

  const domain = 'insidechassidus.org';
  final repository =
      WordpressLoader(topCategoryIds: [id], wordpressUrl: domain);
  final data = await repository.initialLoad();
  final encoder = JsonEncoder.withIndent('\t');
  print(encoder.convert(data.toJson()));
}
