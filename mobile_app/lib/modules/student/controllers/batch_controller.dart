import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../profile/profile_controller.dart'; // ⚠️ Import ProfileController

class BatchController extends GetxController {
  var isLoading = false.obs;

  var selectedYear = '1st Year'.obs;
  var selectedSemester = '1st Semester'.obs;

  // 🆕 Initial Value Set korar function
  void setInitialValues(String? year, String? semester) {
    if (year != null && year != "N/A") selectedYear.value = year;
    if (semester != null && semester != "N/A") selectedSemester.value = semester;
  }

  // 🚀 Update Function
  Future<void> updateBatchStatus() async {
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
        // ✅ Success: Ekhon Profile Refresh korbo
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchProfile();
        }
        // User ke alada snackbar dewar dorkar nai jodi amra 'Save Edits' button e kaj kori
      } else {
        Get.snackbar("Error", "Batch update failed");
      }
    } catch (e) {
      Get.snackbar("Error", "Connection error in batch update");
    } finally {
      isLoading(false);
    }
  }
}