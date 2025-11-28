import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. Permission Request
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('🔔 User granted permission');

      // 2. Setup Local Notifications (Android)
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // অ্যাপ আইকন

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _localNotifications.initialize(initializationSettings);

      // 3. Token & Subscribe
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print("🔥 FCM Token: $token");
        _saveTokenToBackend(token);
        await _firebaseMessaging.subscribeToTopic('notices');
      }

      // 4. Foreground Message Listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("☀️ Foreground Message: ${message.notification?.title}");
        _showForegroundNotification(message);
      });
    }
  }

  void _showForegroundNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // id
            'High Importance Notifications', // name
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }

  Future<void> _saveTokenToBackend(String token) async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    if (userId != null) {
      try {
        await http.put(
          Uri.parse("${ApiConstants.baseUrl}/auth/fcm-token"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"id": userId, "fcm_token": token}),
        );
      } catch (e) {
        print("Token Save Error: $e");
      }
    }
  }
}