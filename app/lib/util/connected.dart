import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:rxdart/rxdart.dart';

Future<bool> waitForConnected() async {
  final internet = {
    ConnectivityResult.mobile,
    ConnectivityResult.ethernet,
    ConnectivityResult.wifi
  };
  final connectivityResult = await (Connectivity().checkConnectivity());

  // Wait for internet.
  // If app switches to background, check for internet when we're back to forground -
  // the onConnectivityChanged doesn't get updated by background changes.
  await Rx.merge([
    Connectivity().onConnectivityChanged.startWith(connectivityResult),
    FGBGEvents.stream
        .where((event) => event == FGBGType.foreground)
        .asyncMap((event) => (Connectivity().checkConnectivity()))
  ]).firstWhere((connectivity) => internet.contains(connectivity));

  return true;
}
