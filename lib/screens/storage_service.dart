import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _keyQuitDate = 'quitDate';
  static const _keyQuitTimeHour = 'quitTimeHour';
  static const _keyQuitTimeMinute = 'quitTimeMinute';
  static const _keyDailyAmount = 'dailyAmount';
  static const _keyCurrency = 'currency';

  static Future<bool> saveUserData({
    required DateTime quitDate,
    required TimeOfDay quitTime,
    required double dailyAmount,
    required String currency,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setInt(_keyQuitDate, quitDate.millisecondsSinceEpoch),
        prefs.setInt(_keyQuitTimeHour, quitTime.hour),
        prefs.setInt(_keyQuitTimeMinute, quitTime.minute),
        prefs.setDouble(_keyDailyAmount, dailyAmount),
        prefs.setString(_keyCurrency, currency),
      ]);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final quitDateMillis = prefs.getInt(_keyQuitDate);
      if (quitDateMillis == null) return null;

      return {
        'quitDate': DateTime.fromMillisecondsSinceEpoch(quitDateMillis),
        'quitTime': TimeOfDay(
          hour: prefs.getInt(_keyQuitTimeHour) ?? 0,
          minute: prefs.getInt(_keyQuitTimeMinute) ?? 0,
        ),
        'dailyAmount': prefs.getDouble(_keyDailyAmount) ?? 0,
        'currency': prefs.getString(_keyCurrency) ?? 'EUR',
      };
    } catch (_) {
      return null;
    }
  }
}
