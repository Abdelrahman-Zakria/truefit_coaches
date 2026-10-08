import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:truefit_coaches/core/theme/app_theme.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static Future<void> init() async {
    // 1. Request Permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // 2. Local Notifications Setup
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle local notification tap
        print("Local notification tapped: ${response.payload}");
      },
    );

    // 3. Create Android Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      
      if (notification != null && !kIsWeb) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    });

    // 5. Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification tapped while in background: ${message.data}");
    });

    // 6. Handle notification tap when app is opened from terminated state
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print("App opened from notification: ${initialMessage.data}");
    }

    // 7. Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Updates FCM token in 'Gym_Coaches' for [userId].
  /// If [context] is supplied and an error occurs during FCM token retrieval,
  /// displays an error dialog with full details.
  static Future<String?> updateToken(String userId, {BuildContext? context}) async {
    try {
      try {
        await _messaging.subscribeToTopic('coaches');
      } catch (e) {
        print("Error subscribing to coaches topic: $e");
      }

      final String? token = await _messaging.getToken();

      if (token == null || token.trim().isEmpty) {
        throw Exception("FirebaseMessaging.instance.getToken() returned null or empty token.");
      }

      await FirebaseFirestore.instance
          .collection('Gym_Coaches')
          .doc(userId)
          .set({
            'fcm_token': token.trim(),
            'fcmToken': token.trim(),
            'fcm_updated_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      print("✅ [FCM Token Updated] Gym_Coaches/$userId -> ${token.trim().substring(0, 15)}...");

      _messaging.onTokenRefresh.listen((newToken) {
        if (newToken.isNotEmpty) {
          FirebaseFirestore.instance
              .collection('Gym_Coaches')
              .doc(userId)
              .set({
                'fcm_token': newToken.trim(),
                'fcmToken': newToken.trim(),
                'fcm_updated_at': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
        }
      });

      return token.trim();
    } catch (e, stackTrace) {
      final String fullError = "$e\n\nStackTrace:\n$stackTrace";
      print("❌ [NotificationService Error] $fullError");

      if (context != null && context.mounted) {
        _showFcmErrorDialog(context, e.toString(), stackTrace.toString());
      }
      return null;
    }
  }

  static void _showFcmErrorDialog(BuildContext context, String error, String stackTrace) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(LucideIcons.alertTriangle, color: AppTheme.primaryRed, size: 24),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "FCM Token Error",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Failed to retrieve or update FCM token in 'Gym_Coaches' collection:",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.5)),
                ),
                child: SelectableText(
                  "$error\n\n$stackTrace",
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("DISMISS", style: TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
