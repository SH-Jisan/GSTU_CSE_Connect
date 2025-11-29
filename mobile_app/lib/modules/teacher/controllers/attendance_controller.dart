import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';

class AttendanceController extends GetxController {
  var isLoading = true.obs;
  var isClassFound = false.obs;
  var statusMessage = "".obs; // "No class found" বা ক্লাসের নাম

  var activeClass = {}.obs;   // বর্তমান ক্লাসের তথ্য
  var studentList = [].obs;   // ওই ক্লাসের স্টুডেন্ট লিস্ট

  // হাজিরা ট্র্যাক করার জন্য ম্যাপ (ID -> Status)
  var attendanceMap = <int, String>{}.obs;

  @override
  void onInit() {
    checkCurrentClass();
    super.onInit();
  }

  // 🕵️ ১. বর্তমান ক্লাস চেক করা
  void checkCurrentClass() async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      int? teacherId = prefs.getInt('userId');

      // বর্তমান সময় এবং দিন বের করা
      var now = DateTime.now();
      String day = DateFormat('EEEE').format(now); // e.g., "Sunday"
      String time = DateFormat('HH:mm').format(now); // e.g., "10:30"

      // টেস্ট করার জন্য হার্ডকোড করতে পারো যদি এখন ক্লাস না থাকে
      // day = "Sunday"; time = "10:00";

      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/attendance/check-class"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "teacherId": teacherId,
          "day": day,
          "time": time
        }),
      );

      var data = jsonDecode(response.body);

      if (data['found'] == true) {
        isClassFound(true);
        activeClass.value = data['classInfo'];
        studentList.value = data['students'];
        statusMessage.value = "${activeClass['course_title']} (${activeClass['room_no']})";

        // ডিফল্ট সব স্টুডেন্টকে 'Present' করে দিচ্ছি
        for (var student in studentList) {
          attendanceMap[student['id']] = 'Present';
        }
      } else {
        isClassFound(false);
        statusMessage.value = "No active class found at this time!";
      }

    } catch (e) {
      statusMessage.value = "Connection Error";
    } finally {
      isLoading(false);
    }
  }

  // 🔄 ২. প্রেজেন্ট/এবসেন্ট টগল করা
  void toggleAttendance(int studentId) {
    if (attendanceMap[studentId] == 'Present') {
      attendanceMap[studentId] = 'Absent';
    } else {
      attendanceMap[studentId] = 'Present';
    }
    attendanceMap.refresh(); // UI আপডেট করার জন্য
  }

  // 💾 ৩. সাবমিট করা
  void submitAttendance() async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      int? teacherId = prefs.getInt('userId');

      // ডাটা সাজানো
      List<Map<String, dynamic>> records = [];
      attendanceMap.forEach((studentId, status) {
        records.add({
          "student_id": studentId,
          "status": status
        });
      });

      var body = {
        "teacher_id": teacherId,
        "course_code": activeClass['course_code'],
        "semester": activeClass['semester'],
        "date": DateTime.now().toIso8601String().split('T')[0], // YYYY-MM-DD
        "records": records
      };

      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/attendance/submit"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Attendance Saved! ✅", backgroundColor: Colors.green, colorText: Colors.white);
        Get.back();
      } else {
        Get.snackbar("Error", "Failed to save");
      }

    } catch (e) {
      Get.snackbar("Error", "Connection Error");
    } finally {
      isLoading(false);
    }
  }
}