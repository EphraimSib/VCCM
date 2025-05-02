import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaunchReadinessProvider with ChangeNotifier {
  static const _launchReadyKey = 'launch_ready';

  bool _isLaunchReady = false;

  bool get isLaunchReady => _isLaunchReady;

  LaunchReadinessProvider() {
    _loadLaunchReadiness();
  }

  Future<void> _loadLaunchReadiness() async {
    final prefs = await SharedPreferences.getInstance();
    _isLaunchReady = prefs.getBool(_launchReadyKey) ?? false;
    notifyListeners();
  }

  Future<void> setLaunchReady(bool ready) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_launchReadyKey, ready);
    _isLaunchReady = ready;
    notifyListeners();
  }
}
