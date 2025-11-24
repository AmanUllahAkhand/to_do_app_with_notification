// lib/core/utils/notification_helper.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true, // Request critical alerts
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == 'REMINDER_POPUP') {
          _showReminderDialog(); // Popup on tap
        }
      },
    );

    // REQUEST PERMISSIONS (Critical for iOS)
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
      critical: true,   // ← This gives loud bypass-silent sound
    );
  }

  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    if (dateTime.isBefore(DateTime.now())) return;

    final tzDateTime = tz.TZDateTime.from(dateTime, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Task Alarms',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('alarm_clock'),
          enableVibration: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          fullScreenIntent: true,                    // Shows popup on lock screen
          category: AndroidNotificationCategory.alarm,
          additionalFlags: Int32List.fromList([4]),   // Repeats sound
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'alarm_clock.caf',
          interruptionLevel: InterruptionLevel.active,
        ),
      ),
      payload: 'SHOW_POPUP',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // This shows the popup on HomePage
  static void _showReminderDialog() {
    // Navigate to HomePage if not already there
    if (Get.currentRoute != '/home') {
      Get.offAllNamed('/home');
    }

    // Show popup
    Get.dialog(
      AlertDialog(
        title: const Text('Time\'s Up! ⏰'),
        content: const Text('Your task is due now! Complete it!'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Snooze')),
          ElevatedButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static Future<void> cancel(int id) => _notifications.cancel(id);
  static Future<void> cancelAll() => _notifications.cancelAll();
}