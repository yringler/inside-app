import 'package:inside_data/src/inside_data.dart';

/// A simple loader which is passed the object to return.
/// Useful as a roundabout way to pass data right to drift, like to create a DB
/// off device.
class MemoryLoader extends SiteDataLoader {
  final SiteData data;

  MemoryLoader({required this.data});

  @override
  Future<SiteData> initialLoad() => Future.value(data);

  @override
  Future<SiteData?> load(DateTime lastLoadTime) => Future.value(data);

  @override
  Future<void> prepareUpdate(DateTime lastLoadTime) async {}
}
