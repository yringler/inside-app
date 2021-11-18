import 'package:flutter/widgets.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

//import 'json_loader.mock.dart';

@GenerateMocks([AssetBundle])
void main() {
  // final mock = MockAssetBundle();
  group('json loader', () {});
}

class Mocks {
  final AssetBundle assetBundle;

  Mocks({required this.assetBundle});

  // factory Mocks.createMocks() {}
}
