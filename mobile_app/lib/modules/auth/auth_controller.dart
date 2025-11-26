import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/dashboard_screen.dart';


class AuthController extends GetxController {
  // লোডিং হচ্ছে কিনা বোঝার জন্য
  var isLoading = false.obs;

  // টেক্সট ফিল্ড কন্ট্রোলার
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // 🔐 লগইন ফাংশন
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error", "All fields are required",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true; // লোডিং শুরু

      var response = await http.post(
        Uri.parse(ApiConstants.loginEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      // যদি রেসপন্স ঠিক থাকে (Status 200)
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var token = data['token'];
        var userName = data['user']['name'];

        Get.snackbar("Success", "Welcome back, $userName!",
            backgroundColor: Colors.green, colorText: Colors.white);

        // TODO: টোকেন সেভ করা এবং হোম পেজে যাওয়া
        if(response.statusCode == 200){
          var data = jsonDecode(response.body);
          var token = data['token'];
          var userName = data['user']['name'];
          var userEmail = data['user']['email'];

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token' , token);
          await prefs.setString('userName' , userName);
          await prefs.setString('userEmail' , userEmail);
          await prefs.setString('userRole', data['user']['role']); //role save korlam

          Get.snackbar("Success" , "Welcome back , $userName!",
          backgroundColor: Color.fromARGB(161, 16, 227, 101), colorText: Colors.black87);

          String role = data['user']['role'];
          Get.offAll(() => const DashboardScreen());
        }

      } else {
        // যদি ভুল হয়
        var error = jsonDecode(response.body);
        Get.snackbar("Login Failed", error['error'] ?? "Something went wrong",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Check your internet or server connection.",
          backgroundColor: Colors.red, colorText: Colors.white);
      if (kDebugMode) {
        print("Login Error: $e");
      }
    } finally {
      isLoading.value = false; // লোডিং শেষ
    }
  }
}