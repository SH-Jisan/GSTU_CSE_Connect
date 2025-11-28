import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';

class BatchController extends GetxController {
  var isLoading = false.obs;

  // Selected Values
  var selectedYear = '1st Year'.obs;
  var selectedSemester = '1st Semester'.obs;

  var isCR = false.obs; // User CR kina seta track korbo

  @override
  void onInit() {
    loadUserStatus();
    super.onInit();
  }

  void loadUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Profile API theke 'is_cr' load kora uchit chilo,
    // tobe amra dhore nicchi login/profile data theke pabo.
    // Simplicity er jonno amra profile theke data ene ekhane set korbo UI te.
  }

  // 🚀 Update Function
  void updateBatchStatus() async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      var response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/student/update-semester"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": userId,
          "year": selectedYear.value,
          "semester": selectedSemester.value
        }),
      );

      if (response.statusCode == 200) {
        var msg = jsonDecode(response.body)['message'];
        Get.snackbar("Success 🎉", msg, backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Error", "Update failed");
      }
    } catch (e) {
      Get.snackbar("Error", "Connection error");
    } finally {
      isLoading(false);
    }
  }
}