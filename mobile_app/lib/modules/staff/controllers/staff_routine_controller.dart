import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';

class StaffRoutineController extends GetxController {
  var isLoading = false.obs;

  // অটো-ফিলের জন্য সব কোর্সের লিস্ট এখানে রাখব
  var allCourses = <dynamic>[];

  final courseCodeCtrl = TextEditingController();
  final courseTitleCtrl = TextEditingController();
  final teacherEmailCtrl = TextEditingController();
  final roomCtrl = TextEditingController();

  var selectedSemester = '1st Year 1st Sem'.obs;
  var selectedDay = 'Sunday'.obs;
  var startTime = TimeOfDay(hour: 10, minute: 0).obs;
  var endTime = TimeOfDay(hour: 11, minute: 30).obs;

  @override
  void onInit() {
    fetchCoursesForAutoFill(); // ১. পেজে ঢুকেই কোর্স লিস্ট মুখস্থ করে নেবে
    super.onInit();
  }

  // 📥 ব্যাকগ্রাউন্ডে সব কোর্স লোড করা
  void fetchCoursesForAutoFill() async {
    try {
      // আমরা আগের Course API টাই ব্যবহার করছি
      var response = await http.get(Uri.parse("${ApiConstants.baseUrl}/courses"));
      if (response.statusCode == 200) {
        allCourses = jsonDecode(response.body);
      }
    } catch (e) {
      print("Auto-fill data fetch failed");
    }
  }

  // 🪄 জাদুর ফাংশন (Auto-fill Logic)
  void onCourseCodeChanged(String code) {
    // ইউজার যা টাইপ করছে, সেটা দিয়ে লিস্টে খুঁজব
    var matchedCourse = allCourses.firstWhere(
          (course) => course['course_code'].toString().toLowerCase() == code.trim().toLowerCase(),
      orElse: () => null,
    );

    if (matchedCourse != null) {
      // ম্যাচ পেলে টাইটেল এবং সেমিস্টার অটো বসিয়ে দেব
      courseTitleCtrl.text = matchedCourse['course_title'];
      selectedSemester.value = matchedCourse['semester'];
      Get.snackbar("Found!", "Course details auto-filled ✨",
          backgroundColor: Colors.green.withOpacity(0.5), colorText: Colors.white, duration: const Duration(seconds: 1));
    }
  }

  Future<void> pickTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime.value : endTime.value,
    );
    if (picked != null) {
      if (isStart) startTime.value = picked;
      else endTime.value = picked;
    }
  }

  void addClassRoutine() async {
    if (courseCodeCtrl.text.isEmpty || teacherEmailCtrl.text.isEmpty) {
      Get.snackbar("Error", "Please fill fields", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    try {
      isLoading.value = true;
      String startStr = "${startTime.value.hour}:${startTime.value.minute}";
      String endStr = "${endTime.value.hour}:${endTime.value.minute}";

      var response = await http.post(
        Uri.parse(ApiConstants.addRoutineEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "semester": selectedSemester.value,
          "course_code": courseCodeCtrl.text,
          "course_title": courseTitleCtrl.text,
          "teacher_email": teacherEmailCtrl.text.trim(),
          "room_no": roomCtrl.text,
          "day": selectedDay.value,
          "start_time": startStr,
          "end_time": endStr,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Class Added!", backgroundColor: Colors.green, colorText: Colors.white);
        courseCodeCtrl.clear();
        courseTitleCtrl.clear();
        roomCtrl.clear();
        Get.back();
      } else {
        Get.snackbar("Failed", "Error adding routine", backgroundColor: Colors.orange);
      }
    } catch (e) {
      Get.snackbar("Error", "Check internet");
    } finally {
      isLoading.value = false;
    }
  }
}