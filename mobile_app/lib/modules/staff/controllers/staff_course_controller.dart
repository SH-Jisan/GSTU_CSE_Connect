import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';

class StaffCourseController extends GetxController {
  var isLoading = false.obs;
  var courseList = [].obs;

  // Form Controllers
  final codeCtrl = TextEditingController();
  final titleCtrl = TextEditingController();
  final syllabusCtrl = TextEditingController();
  var selectedSemester = '1st Year 1st Sem'.obs;

  // 📂 সেমিস্টার অনুযায়ী কোর্স সাজানোর লজিক (Getter)
  Map<String, List<dynamic>> get groupedCourses {
    Map<String, List<dynamic>> grouped = {};
    for (var course in courseList) {
      String sem = course['semester'];
      if (!grouped.containsKey(sem)) {
        grouped[sem] = [];
      }
      grouped[sem]!.add(course);
    }
    return grouped; // যেমন: {'1st Year': [Course A, Course B], ...}
  }

  @override
  void onInit() {
    fetchCourses();
    super.onInit();
  }

  void fetchCourses() async {
    try {
      isLoading(true);
      var response = await http.get(Uri.parse("${ApiConstants.baseUrl}/courses"));
      if (response.statusCode == 200) {
        courseList.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar("Error", "Could not fetch courses");
    } finally {
      isLoading(false);
    }
  }

  // 🆕 Add Course
  void addCourse() async {
    if (_validate()) return;
    try {
      isLoading(true);
      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/courses/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "course_code": codeCtrl.text.trim(),
          "course_title": titleCtrl.text.trim(),
          "semester": selectedSemester.value,
          "syllabus": syllabusCtrl.text.trim()
        }),
      );
      _handleResponse(response, "Course Added! 📚");
    } catch (e) {
      Get.snackbar("Error", "Connection Error");
    } finally {
      isLoading(false);
    }
  }

  // ✏️ Update Course
  void updateCourse(int id) async {
    if (_validate()) return;
    try {
      isLoading(true);
      var response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/courses/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "course_code": codeCtrl.text.trim(),
          "course_title": titleCtrl.text.trim(),
          "semester": selectedSemester.value,
          "syllabus": syllabusCtrl.text.trim()
        }),
      );
      _handleResponse(response, "Course Updated! ✅");
    } catch (e) {
      Get.snackbar("Error", "Connection Error");
    } finally {
      isLoading(false);
    }
  }

  // 🗑️ Delete Course
  void deleteCourse(int id) {
    Get.defaultDialog(
        title: "Delete Course?",
        middleText: "Are you sure?",
        textConfirm: "Yes",
        textCancel: "No",
        confirmTextColor: Colors.white,
        onConfirm: () async {
          Get.back();
          try {
            var response = await http.delete(Uri.parse("${ApiConstants.baseUrl}/courses/$id"));
            if (response.statusCode == 200) {
              Get.snackbar("Deleted", "Course removed");
              fetchCourses();
            }
          } catch (e) {
            Get.snackbar("Error", "Failed to delete");
          }
        }
    );
  }

  // 🛠️ Helpers
  bool _validate() {
    if (codeCtrl.text.isEmpty || titleCtrl.text.isEmpty) {
      Get.snackbar("Required", "Code and Title are mandatory", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return true;
    }
    return false;
  }

  void _handleResponse(http.Response response, String successMsg) {
    if (response.statusCode == 200) {
      Get.snackbar("Success", successMsg, backgroundColor: Colors.green, colorText: Colors.white);
      clearFields();
      fetchCourses();
      Get.back(); // Close sheet
    } else {
      var error = jsonDecode(response.body);
      Get.snackbar("Failed", error['error'] ?? "Error occurred", backgroundColor: Colors.orange);
    }
  }

  void clearFields() {
    codeCtrl.clear();
    titleCtrl.clear();
    syllabusCtrl.clear();
    selectedSemester.value = '1st Year 1st Sem';
  }

  // এডিটের সময় ডাটা লোড করার জন্য
  void setFieldsForEdit(Map course) {
    codeCtrl.text = course['course_code'];
    titleCtrl.text = course['course_title'];
    syllabusCtrl.text = course['syllabus'] ?? "";
    selectedSemester.value = course['semester'];
  }
}