import 'package:flutter/foundation.dart';

/// Abstract interface for notifications (Push, SMS, Email).
/// This allows us to swap providers (e.g., FCM to OneSignal or Twilio) 
/// without changing business logic.
abstract class NotificationService {
  Future<void> initialize();
  Future<void> sendNotification({
    required String title,
    required String body,
    String? recipientId,
    Map<String, dynamic>? data,
  });
}

/// Dummy implementation for local development or when 3rd party is not configured.
class MockNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {
    debugPrint("Notification Service Initialized (Mock)");
  }

  @override
  Future<void> sendNotification({
    required String title,
    required String body,
    String? recipientId,
    Map<String, dynamic>? data,
  }) async {
    debugPrint("Sending Mock Notification: $title - $body to $recipientId");
  }
}
