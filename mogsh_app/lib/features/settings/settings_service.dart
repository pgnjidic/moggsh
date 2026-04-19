import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsService extends ChangeNotifier {
  static const _boxName = 'settings';
  Box? _box;

  double get fontSize => _box?.get('fontSize', defaultValue: 14.0) ?? 14.0;

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
