import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // kDebugMode er jonno
import '../constants/api_constants.dart';

class NotificationService {
  // Singleton Pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // 🚀 Main Init Function
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Permission (User ke prompt korbe)
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) print('🔔 Permission Granted');

        // 2. Local Notification Setup (Android)
        const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

        const InitializationSettings initSettings = InitializationSettings(
          android: androidSettings,
        );

        await _localNotifications.initialize(initSettings);

        // 3. Token & Topic Setup
        await _setupTokenAndTopics();

        // 4. Foreground Listener
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (kDebugMode) print("☀️ Foreground Message: ${message.notification?.title}");
          _showForegroundNotification(message);
        });

        // 5. Token Refresh Listener (Token change hole update korbe)
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          if (kDebugMode) print("🔄 Token Refreshed: $newToken");
          _saveTokenToBackend(newToken);
        });

        _isInitialized = true;
      } else {
        if (kDebugMode) print('🚫 Permission Denied');
      }
    } catch (e) {
      if (kDebugMode) print("⚠️ Notification Init Warning: $e");
    }
  }

  // 🔥 Token ney ebong Server e pathay + Topic Subscribe kore
  Future<void> _setupTokenAndTopics() async {
    try {
      // Topic e subscribe kora (Sobai 'notices' topic e thakbe)
      await _firebaseMessaging.subscribeToTopic('notices');
      if (kDebugMode) print("✅ Subscribed to 'notices' topic");

      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        if (kDebugMode) print("🔥 FCM Token: $token");
        _saveTokenToBackend(token);
      }
    } catch (e) {
      if (kDebugMode) print("Token/Topic Error: $e");
    }
  }

  // 💾 Backend API Call (Non-blocking)
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
        if (kDebugMode) print("✅ Token updated on Server for User ID: $userId");
      } catch (e) {
        if (kDebugMode) print("❌ Token Sync Fail: $e");
      }
    } else {
      if (kDebugMode) print("⚠️ User ID not found, cannot save token.");
    }
  }

  // 🔔 Heads-up Notification
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
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }
}
