import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InsidePreferences {
  final SharedPreferences preferences;
  late final BehaviorSubject<double> _speedStream =
      BehaviorSubject.seeded(currentSpeed);

  /// The current default speed saved to preferences.
  double get currentSpeed => preferences.getDouble('speed') ?? 1;

  Stream<double> get speedStream => _speedStream.stream.distinct();

  InsidePreferences({required this.preferences});

  static Future<InsidePreferences> newAsync() async {
    final preferences = await SharedPreferences.getInstance();

    return InsidePreferences(preferences: preferences);
  }

  Future<void> setSpeed(double speed) async {
    _speedStream.add(speed);
    await preferences.setDouble('speed', speed);
  }
}
