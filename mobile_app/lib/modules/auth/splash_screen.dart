//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\modules\auth\splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../../core/services/notification_service.dart';
import '../staff/staff_dashboard.dart';
import '../home/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    // 🚀 1. Notification Setup (Non-blocking)
    // Amra 'await' korbo NA, jate nicher code deri na kore
    NotificationService().initialize();

    // 2. Wait for Splash Animation (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    // 3. Login Check
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? role = prefs.getString('userRole');

    if (token != null && token.isNotEmpty) {

        Get.offAll(() => const DashboardScreen());
    } else {
      Get.offAll(() => LoginScreen());
    }
  }
  // 🕵️ চেক করি ইউজার আগে থেকে লগইন করা আছে কিনা

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent, // ডিপার্টমেন্টের থিম কালার
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // লোগো (আইকন)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1))
                  ]
              ),
              child: const Icon(Icons.school, size: 60, color: Colors.blueAccent),
            ),
            const SizedBox(height: 20),

            // অ্যাপের নাম
            const Text(
              "GSTU CSE Connect",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Smart Department, Smart Future",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),

            const SizedBox(height: 50),
            // লোডিং এনিমেশন
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}