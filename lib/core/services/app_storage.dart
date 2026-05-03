import 'dart:convert';

import 'package:flutter/services.dart';

import '../../data_model/app_state.dart';

class AppStorage {
  static const _channel = MethodChannel('luna_cycle/storage');

  static Future<AppState?> load() async {
    String? raw;
    try {
      raw = await _channel.invokeMethod<String>('load');
    } catch (_) {
      return null;
    }
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AppState.fromJson(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(AppState state) async {
    try {
      await _channel.invokeMethod<void>('save', jsonEncode(state.toJson()));
    } catch (_) {
      // Tests and unsupported platforms can run without the native storage bridge.
    }
  }

  static Future<void> clear() async {
    try {
      await _channel.invokeMethod<void>('clear');
    } catch (_) {
      // Tests and unsupported platforms can run without the native storage bridge.
    }
  }
}
