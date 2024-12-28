import 'dart:async';
import 'dart:io';
import 'package:app_usage/app_usage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsageService {
  static const String _limitKey = 'data_limit';
  static const String _usageKey = 'data_usage';
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  late final SharedPreferences _prefs;

  UsageService() {
    _initialize();
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<double> getTotalDataUsage() async {
    // Wait for initialization if needed
    try {
      if (Platform.isAndroid) {
        return await _getAndroidDataUsage();
      } else if (Platform.isIOS) {
        return await _getIOSDataUsage();
      }
      return 0;
    } catch (e) {
      print('Error getting data usage: $e');
      return 0;
    }
  }

  Future<double> _getAndroidDataUsage() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(hours: 24));

    final List<AppUsageInfo> appUsageList =
        await AppUsage().getAppUsage(startDate, endDate);

    double totalUsage = 0;
    for (var usage in appUsageList) {
      final hours = usage.usage.inHours;
      totalUsage += hours * 100;
    }

    await _saveUsage(totalUsage);
    return totalUsage;
  }

  Future<double> _getIOSDataUsage() async {
    return _prefs.getDouble(_usageKey) ?? 0;
  }

  Future<void> _saveUsage(double usage) async {
    await _prefs.setDouble(_usageKey, usage);
  }

  Future<List<AppUsageInfo>> getAppUsageList() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(hours: 24));
      return await AppUsage().getAppUsage(startDate, endDate);
    } catch (e) {
      print('Error getting app usage list: $e');
      return [];
    }
  }

  Future<void> setDataLimit(double limitMB) async {
    await _prefs.setDouble(_limitKey, limitMB);
    await checkDataLimit();
  }

  Future<double> getDataLimit() async {
    return _prefs.getDouble(_limitKey) ?? 1000;
  }

  Future<void> checkDataLimit() async {
    final usage = await getTotalDataUsage();
    final limit = await getDataLimit();

    if (usage >= limit) {
      await _sendNotification(usage, limit);
    }
  }

  Future<void> _sendNotification(double usage, double limit) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'data_usage_channel',
      'Data Usage Alerts',
      channelDescription: 'Alerts for data usage limits',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notifications.show(
      0,
      'Data Usage Alert',
      'You have used ${usage.toStringAsFixed(1)}MB out of ${limit.toStringAsFixed(1)}MB daily limit',
      platformDetails,
    );
  }

  Future<void> resetUsage() async {
    await _prefs.remove(_usageKey);
  }

  void startBackgroundMonitoring() {
    Timer.periodic(const Duration(minutes: 15), (timer) async {
      await checkDataLimit();
    });
  }
}
