import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'modules/auth/splash_screen.dart';


void main() {
  runApp(const GSTUConnectApp());
}

class GSTUConnectApp extends StatelessWidget {
  const GSTUConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GSTU CSE Connect',
      debugShowCheckedModeBanner: false, // কোণায় debug লেখা সরাবে
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(), // সুন্দর ফন্ট
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}