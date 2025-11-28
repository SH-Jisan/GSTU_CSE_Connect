//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'modules/auth/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  await NotificationService().initialize();
  runApp(const GSTUConnectApp());
}

class GSTUConnectApp extends StatelessWidget {
  const GSTUConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GSTU CSE Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}