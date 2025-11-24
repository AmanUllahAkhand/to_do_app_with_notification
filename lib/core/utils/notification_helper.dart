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

    const AndroidInitializationSettings android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(android: android, iOS: ios);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // This runs when user taps notification OR when alarm fires
        if (details.payload == 'SHOW_POPUP') {
          _showAlarmPopup();
        }
      },
    );

    // Create high-priority alarm channel (Android)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'alarm_channel',
      'Task Alarms',
      description: 'Critical alarms that wake you up',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
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
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'alarm_clock.caf',
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
      payload: 'SHOW_POPUP',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // This shows the popup on HomePage
  static void _showAlarmPopup() {
    if (Get.currentRoute != '/home') {
      Get.offAllNamed('/home'); // Go to HomePage first
    }

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.red.shade50,
          title: Row(
            children: [
              Icon(Icons.alarm, color: Colors.red, size: 40),
              SizedBox(width: 12),
              Text("TIME'S UP!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 22)),
            ],
          ),
          content: Text(
            "Your task is due right now!\nComplete it before it's too late!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text("Snooze 5 min", style: TextStyle(color: Colors.orange, fontSize: 16)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Get.back(),
              child: Text("Dismiss", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  static Future<void> cancel(int id) => _notifications.cancel(id);
  static Future<void> cancelAll() => _notifications.cancelAll();
}