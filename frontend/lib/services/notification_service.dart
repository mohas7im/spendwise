import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/subscription.dart';
import '../models/vault_models.dart';
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

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
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

  Future<void> scheduleVaultExpiryReminder({required String id, required String name, required String type, required DateTime expiryDate}) async {
    // 30 days before expiry
    DateTime reminderTime = expiryDate.subtract(const Duration(days: 30));
    
    // If 30 days before is in the past, maybe try 7 days before
    if (reminderTime.isBefore(DateTime.now())) {
      reminderTime = expiryDate.subtract(const Duration(days: 7));
    }
    
    // If still in the past, don't schedule
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      id: id.hashCode,
      title: '$type Expiring Soon',
      body: 'Your $name is expiring on ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}. Please renew it soon!',
      scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'vault_channel',
          'Vault Reminders',
          channelDescription: 'Reminders for document and card expiries',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleVaultReminder(VaultReminder reminder) async {
    if (reminder.isCompleted) return;

    DateTime reminderTime = reminder.date;
    
    // If it's already past, don't schedule
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      id: reminder.id.hashCode,
      title: reminder.title,
      body: reminder.description.isNotEmpty ? reminder.description : 'You have a scheduled reminder!',
      scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'vault_reminder_channel',
          'General Reminders',
          channelDescription: 'Reminders for your custom vault notes and tasks',
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
