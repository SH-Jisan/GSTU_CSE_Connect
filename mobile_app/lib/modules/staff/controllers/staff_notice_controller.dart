//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\modules\staff\controllers\staff_notice_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../home/home_controller.dart';

class StaffNoticeController extends GetxController {
  var isLoading = false.obs;
  final titleController = TextEditingController();
  final descController = TextEditingController();
  var selectedCategory = 'General'.obs;

  void postNotice() async {
    if (titleController.text.isEmpty || descController.text.isEmpty) {
      Get.snackbar("Required", "All fields are required!", backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      var response = await http.post(
        Uri.parse(ApiConstants.noticeEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": titleController.text,
          "description": descController.text,
          "category": selectedCategory.value,
          "uploaded_by": userId ?? 1,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success! 🎉", "Notice Posted", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);

        // হোম কন্ট্রোলার রিফ্রেশ
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchNotices();
        } else {
          Get.put(HomeController()).fetchNotices();
        }

        titleController.clear();
        descController.clear();
        Get.back();
      } else {
        Get.snackbar("Failed", "Server Error", backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Check internet connection", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}