import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/subscription.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );
    _isInitialized = true;
  }

  Future<void> scheduleSubscriptionReminder(SubscriptionModel sub) async {
    if (sub.isPaused) return;

    // Default to 1 day before
    DateTime reminderTime = sub.nextBilling.subtract(const Duration(days: 1));
    
    // If the reminder time is in the past, don't schedule it
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    // Schedule notification
    await _notificationsPlugin.zonedSchedule(
      id: sub.id.hashCode,
      title: 'Subscription Renewal Tomorrow',
      body: 'Your ${sub.name} subscription (${sub.currency}${sub.cost}) renews tomorrow!',
      scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_channel',
          'Subscription Reminders',
          channelDescription: 'Reminders for upcoming subscription renewals',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder(String id) async {
    await _notificationsPlugin.cancel(id: id.hashCode);
  }
}
