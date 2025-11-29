import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';

class StaffRoutineController extends GetxController {
  var isLoading = false.obs;

  // ⚡ Auto-fill Variables
  var allCourses = <dynamic>[];

  // 🆕 এই ভেরিয়েবলটি Obx এর জন্য জরুরি
  var isCourseMatched = false.obs;

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
    fetchCoursesForAutoFill();
    super.onInit();
  }

  void fetchCoursesForAutoFill() async {
    try {
      var response = await http.get(Uri.parse("${ApiConstants.baseUrl}/courses"));
      if (response.statusCode == 200) {
        allCourses = jsonDecode(response.body);
      }
    } catch (e) {
      print("Auto-fill data fetch failed");
    }
  }

  // 🪄 Auto-fill Logic (Updated)
  void onCourseCodeChanged(String code) {
    var matchedCourse = allCourses.firstWhere(
          (course) => course['course_code'].toString().toLowerCase() == code.trim().toLowerCase(),
      orElse: () => null,
    );

    if (matchedCourse != null) {
      // ডাটা পাওয়া গেছে
      courseTitleCtrl.text = matchedCourse['course_title'];
      selectedSemester.value = matchedCourse['semester'];

      // ⚠️ FIX: Observable আপডেট করা হলো
      isCourseMatched.value = true;

      Get.snackbar("Found!", "Matched: ${matchedCourse['course_title']}",
          backgroundColor: Colors.green.withOpacity(0.5),
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10)
      );
    } else {
      // ডাটা না মিললে
      isCourseMatched.value = false;
      courseTitleCtrl.clear();
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

        // Reset Everything
        courseCodeCtrl.clear();
        courseTitleCtrl.clear();
        roomCtrl.clear();
        isCourseMatched.value = false; // Reset status

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