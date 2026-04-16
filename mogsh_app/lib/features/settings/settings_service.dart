import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsService extends ChangeNotifier {
  static const _boxName = 'settings';
  Box? _box;

  double get fontSize => _box?.get('fontSize', defaultValue: 14.0) ?? 14.0;
  bool get approvalMode => _box?.get('approvalMode', defaultValue: true) ?? true;
  bool get analyticsEnabled => _box?.get('analyticsEnabled', defaultValue: true) ?? true;
  bool get autoSwitch => _box?.get('autoSwitch', defaultValue: true) ?? true;
  String get quietHoursStart => _box?.get('quietHoursStart', defaultValue: '23:00') ?? '23:00';
  String get quietHoursEnd => _box?.get('quietHoursEnd', defaultValue: '07:00') ?? '07:00';
  bool get landscapeSplit => _box?.get('landscapeSplit', defaultValue: true) ?? true;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    notifyListeners();
  }

  Future<void> set(String key, dynamic value) async {
    await _box?.put(key, value);
    notifyListeners();
  }

  Future<void> clearCredentials() async {
    await _box?.delete('oauth_claude');
    await _box?.delete('oauth_github');
    notifyListeners();
  }
}
