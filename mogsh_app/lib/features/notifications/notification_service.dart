import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationService {
  static const _channel = MethodChannel('app.mogsh.terminal/notifications');
  static const _storage = FlutterSecureStorage();

  // Per-tab notification enabled map: tabId → bool
  final _tabEnabled = <String, bool>{};
  String? _quietStart;
  String? _quietEnd;

  Future<void> init() async {
    _quietStart = await _storage.read(key: 'quiet_start') ?? '23:00';
    _quietEnd   = await _storage.read(key: 'quiet_end') ?? '07:00';
  }

  void setTabEnabled(String tabId, bool enabled) => _tabEnabled[tabId] = enabled;
  bool isTabEnabled(String tabId) => _tabEnabled[tabId] ?? true;

  bool _inQuietHours() {
    final now = TimeOfDay.now();
    final start = _parseTime(_quietStart ?? '23:00');
    final end   = _parseTime(_quietEnd   ?? '07:00');
    final mins  = now.hour * 60 + now.minute;
    final s = start.hour * 60 + start.minute;
    final e = end.hour   * 60 + end.minute;
    if (s > e) return mins >= s || mins < e; // crosses midnight
    return mins >= s && mins < e;
  }

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// Send a notification when agent task completes
  Future<void> notifyAgentDone(String tabId, String tabTitle, String preview) async {
    if (!isTabEnabled(tabId)) return;
    if (_inQuietHours()) return;

    try {
      await _channel.invokeMethod('showNotification', {
        'title': 'mogsh — $tabTitle',
        'body': preview.length > 80 ? '${preview.substring(0, 80)}…' : preview,
        'tabId': tabId,
      });
    } catch (_) {}
  }

  /// Detect agent completion patterns in terminal output
  static bool isAgentDone(String data) {
    return data.contains('✓') ||
        data.contains('Task complete') ||
        data.contains('All done') ||
        data.contains('\$ ') && data.trimRight().endsWith('\$');
  }
}
