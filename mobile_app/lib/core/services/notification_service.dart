import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // 🚀 ইনিশিয়ালাইজেশন
  Future<void> initialize() async {
    // ১. পারমিশন চাওয়া
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('🔔 User granted permission');

      // ২. টোকেন নেওয়া এবং সার্ভারে পাঠানো
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print("🔥 FCM Token: $token");
        _saveTokenToBackend(token);
        await _firebaseMessaging.subscribeToTopic('notices');
        print("🔔 Subscribed to 'notices' topic");
      }

      // ৩. ফোরগ্রাউন্ড নোটিফিকেশন সেটআপ (অ্যাপ খোলা থাকলে যাতে পপ-আপ আসে)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showForegroundNotification(message);
      });
    }
  }

  // 💾 সার্ভারে টোকেন সেভ করা
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
        print("✅ FCM Token Saved to Backend");
      } catch (e) {
        print("❌ Token Save Error: $e");
      }
    }
  }

  // 🔔 অ্যাপ খোলা অবস্থায় নোটিফিকেশন দেখানো
  void _showForegroundNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
    );
  }
}