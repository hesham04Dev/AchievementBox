import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:achievement_box/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterLocalNotificationsPlugin extends FlutterLocalNotificationsPlatform
    with MockPlatformInterfaceMixin {
  List<String> calls = [];
  Map<String, dynamic> lastPayload = {};

  @override
  Future<bool?> initialize(
    InitializationSettings? initializationSettings, {
    void Function(NotificationResponse)? onDidReceiveNotificationResponse,
    void Function(NotificationResponse)? onDidReceiveBackgroundNotificationResponse,
  }) async {
    calls.add('initialize');
    return true;
  }

  @override
  Future<void> cancelAll() async {
    calls.add('cancelAll');
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails? notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    bool androidAllowWhileIdle = false,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    calls.add('zonedSchedule');
    lastPayload = {
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlutterLocalNotificationsPlugin mockPlugin;

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    FlutterLocalNotificationsPlatform.instance = mockPlugin;
  });

  test('NotificationService init initializes plugin', () async {
    final service = NotificationService();
    await service.init();

    expect(mockPlugin.calls, contains('initialize'));
  });

  test('scheduleDailyNotification schedules notification', () async {
    final service = NotificationService();
    await service.init();
    mockPlugin.calls.clear();

    await service.scheduleDailyNotification(const TimeOfDay(hour: 9, minute: 0));

    // cancelAll is called first
    expect(mockPlugin.calls[0], 'cancelAll');
    // then zonedSchedule
    expect(mockPlugin.calls[1], 'zonedSchedule');
    
    expect(mockPlugin.lastPayload['title'], 'Achievement Box');
    expect(mockPlugin.lastPayload['body'], 'Time to check your achievements!');
  });

  test('cancelNotifications cancels all', () async {
    final service = NotificationService();
    await service.cancelNotifications();

    expect(mockPlugin.calls, contains('cancelAll'));
  });
}
