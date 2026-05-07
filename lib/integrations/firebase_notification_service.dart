import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class FirebaseNotificationService implements NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  Future<void> initialize() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get token for this device (could be stored in Firestore for targeted push)
    try {
      String? token = await _fcm.getToken();
      debugPrint("FCM Token: $token");
    } catch (e) {
      debugPrint("Could not get FCM token: $e");
    }
  }

  @override
  Future<void> sendNotification({
    required String title,
    required String body,
    String? recipientId,
    Map<String, dynamic>? data,
  }) async {
    // In a real app, you'd call your backend/Cloud Function to send a push via FCM
    debugPrint("FCM Push Queued: $title - $body to $recipientId");
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}
