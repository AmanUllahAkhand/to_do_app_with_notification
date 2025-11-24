import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:typed_data';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // THIS IS CALLED WHEN USER TAPS THE NOTIFICATION OR PRESSES ACTION BUTTON
        if (response.payload == 'REMINDER_POPUP') {
          _showReminderDialog(response.notificationResponseType);
        }
      },
    );
  }

  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tz.TZDateTime scheduled = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Task Alarms',
          channelDescription: 'Critical task reminder alarms',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('alarm_clock'),
          enableVibration: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          additionalFlags: Int32List.fromList(<int>[4]), // ← CORRECT: Convert List<int> to Int32List
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'alarm_clock.caf',
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
      payload: 'REMINDER_POPUP', // Triggers our popup
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // BEAUTIFUL POPUP WHEN REMINDER FIRES
  static void _showReminderDialog(NotificationResponseType type) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent back button dismiss
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.alarm, color: Colors.red, size: 32),
              SizedBox(width: 10),
              Text("Time's Up!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            "Your task is due now!\nDon't forget to complete it.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                _notifications.cancelAll(); // Optional: stop repeating alarm
              },
              child: Text("Snooze 5 min", style: TextStyle(color: Colors.orange)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Get.back(),
              child: Text("OK, Got it!", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Helper methods
  static void setReminder({required int taskId, required String taskTitle, required DateTime dateTime}) {
    scheduleReminder(
      id: taskId,
      title: "Reminder",
      body: taskTitle,
      scheduledDate: dateTime,
    );
  }

  static Future<void> cancel(int id) async => await _notifications.cancel(id);
  static Future<void> cancelAll() async => await _notifications.cancelAll();
}