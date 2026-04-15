import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsService extends ChangeNotifier {
  static const _boxName = 'settings';
  late Box _box;

  double get fontSize => _box.get('fontSize', defaultValue: 14.0);
  bool get approvalMode => _box.get('approvalMode', defaultValue: true);
  bool get analyticsEnabled => _box.get('analyticsEnabled', defaultValue: true);
  bool get autoSwitch => _box.get('autoSwitch', defaultValue: true);
  String get quietHoursStart => _box.get('quietHoursStart', defaultValue: '23:00');
  String get quietHoursEnd => _box.get('quietHoursEnd', defaultValue: '07:00');
  bool get landscapeSplit => _box.get('landscapeSplit', defaultValue: true);

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> set(String key, dynamic value) async {
    await _box.put(key, value);
    notifyListeners();
  }

  Future<void> clearCredentials() async {
    await _box.delete('oauth_claude');
    await _box.delete('oauth_github');
    notifyListeners();
  }
}
