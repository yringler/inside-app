import 'dart:convert';

import 'package:inside_data/inside_data.dart';

Future<void> main(List<String> args) async {
  const domain = 'insidechassidus.org';
  final repository =
      WordpressLoader(topCategoryIds: [1573], wordpressUrl: domain);
  final data = await repository.initialLoad();
  final encoder = JsonEncoder.withIndent('\t');
  print(encoder.convert(data.toJson()));
}
