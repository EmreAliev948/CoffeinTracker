import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../coffee-pages/caffeine_calculator.dart';
import '../../coffee-pages/coffee_intake.dart';

class NotiService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initNotification() async {
    if (_initialized) return;

    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
    _initialized = true;
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_coffee',
        'Daily Notification',
        channelDescription: 'Notifications for caffeine tracking',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      await initNotification();
    }

    try {
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        _notificationDetails(),
        payload: 'caffeine_notification',
      );
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> schedulePeakCaffeineNotification({
    required List<CoffeeIntake> intakes,
  }) async {
    if (!_initialized) {
      await initNotification();
    }

    try {
      await cancelPeakNotification();

      final now = DateTime.now();
      final recentIntakes = intakes
          .where((intake) => now.difference(intake.time).inHours < 24)
          .toList();

      final peakTime = CaffeineCalculator.calculateNextPeakTime(recentIntakes);

      if (peakTime == null) {
        return;
      }

      final peakLevel =
          CaffeineCalculator.calculatePeakLevel(recentIntakes, peakTime);

      final timeUntilPeak = peakTime.difference(now);

      if (timeUntilPeak.inMinutes <= 0) {
        return;
      }

      // Schedule peak start notification
      if (timeUntilPeak.inMinutes > 1) {
        final scheduledTime = tz.TZDateTime.from(peakTime, tz.local);

        await flutterLocalNotificationsPlugin.zonedSchedule(
          1, // ID for peak start notification
          'Peak Caffeine Effect Starting',
          'Your caffeine level has reached ${peakLevel.toStringAsFixed(1)} mg and will remain elevated for ${CaffeineCalculator.PEAK_DURATION.inMinutes} minutes',
          scheduledTime,
          _notificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }

      // Schedule peak end notification
      final peakEndTime = peakTime.add(CaffeineCalculator.PEAK_DURATION);
      if (peakEndTime.isAfter(now)) {
        final scheduledEndTime = tz.TZDateTime.from(peakEndTime, tz.local);

        await flutterLocalNotificationsPlugin.zonedSchedule(
          2, // Different ID for peak end notification
          'Peak Caffeine Effect Ending',
          'Your caffeine peak effect is now ending. Current level: ${peakLevel.toStringAsFixed(1)} mg',
          scheduledEndTime,
          _notificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Test method to send an immediate notification
  Future<void> sendTestNotification() async {
    await showNotification(
      id: 999,
      title: 'Test Notification',
      body: 'This is a test notification',
    );
  }

  Future<void> cancelPeakNotification() async {
    // Cancel both notifications
    await flutterLocalNotificationsPlugin.cancel(1);
    await flutterLocalNotificationsPlugin.cancel(2);
  }
}
