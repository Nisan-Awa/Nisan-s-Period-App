import 'package:flutter/services.dart';

import '../../data_model/app_state.dart';

class DeviceServices {
  static const _channel = MethodChannel('luna_cycle/device');

  static Future<bool> areNotificationsEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('areNotificationsEnabled') ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<bool> requestNotificationPermission() async {
    try {
      return await _channel.invokeMethod<bool>('requestNotifications') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<bool> scheduleReminders(
    List<ReminderItem> reminders, {
    required bool enabled,
    required bool hideSensitive,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('scheduleReminders', {
            'enabled': enabled,
            'hideSensitive': hideSensitive,
            'reminders': reminders
                .where((reminder) => reminder.enabled)
                .map(
                  (reminder) => {
                    'title': reminder.title,
                    'message': hideSensitive
                        ? 'You have a LunaCycle reminder.'
                        : reminder.message,
                    'hour': reminder.time.hour,
                    'minute': reminder.time.minute,
                  },
                )
                .toList(),
          }) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<bool> showTestNotification({
    required bool hideSensitive,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('showTestNotification', {
            'title': 'LunaCycle',
            'message': hideSensitive
                ? 'You have a LunaCycle reminder.'
                : 'Reminders are ready. LunaCycle will gently check in with you.',
            'hideSensitive': hideSensitive,
          }) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<bool> unlockWithDeviceCredential() async {
    try {
      return await _channel.invokeMethod<bool>('unlock') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
