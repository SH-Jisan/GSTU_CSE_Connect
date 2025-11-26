import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import 'login_screen.dart';

class SignUpController extends GetxController {
  var isLoading = false.obs;
  var selectedRole = 'student'.obs; // ডিফল্ট রোল স্টুডেন্ট

  // টেক্সট ফিল্ড কন্ট্রোলার
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // স্টুডেন্টদের জন্য স্পেশাল ফিল্ড
  final studentIdController = TextEditingController();
  final sessionController = TextEditingController();

  // টিচার/স্টাফদের জন্য স্পেশাল ফিল্ড
  final designationController = TextEditingController();

  // 📝 রেজিস্ট্রেশন ফাংশন
  Future<void> registerUser() async {
    // বেসিক ভ্যালিডেশন
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error", "All basic fields are required", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // ডাটা প্রস্তুত করা (রোল অনুযায়ী)
      Map<String, dynamic> bodyData = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "role": selectedRole.value,
      };

      // যদি স্টুডেন্ট হয়, আইডি আর সেশন যোগ করো
      if (selectedRole.value == 'student') {
        bodyData['student_id'] = studentIdController.text.trim();
        bodyData['session'] = sessionController.text.trim();
      }
      // যদি টিচার বা স্টাফ হয়, ডেজিগনেশন যোগ করো
      else {
        bodyData['designation'] = designationController.text.trim();
      }

      // API কল
      var response = await http.post(
        Uri.parse(ApiConstants.signupEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 201) {
        // সফল হলে
        Get.snackbar("Success", "Registration Successful! Please wait for Admin approval.",
            backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 4));

        // সব ফিল্ড ক্লিয়ার করে লগইন পেজে পাঠানো
        clearFields();
        Get.off(() => LoginScreen());

      } else {
        // ভুল হলে
        var error = jsonDecode(response.body);
        Get.snackbar("Registration Failed", error['error'] ?? "Try again", backgroundColor: Colors.red, colorText: Colors.white);
      }

    } catch (e) {
      Get.snackbar("Error", "Server connection failed", backgroundColor: Colors.red, colorText: Colors.white);
      if (kDebugMode) {
        print(e);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void clearFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    studentIdController.clear();
    designationController.clear();
  }
}