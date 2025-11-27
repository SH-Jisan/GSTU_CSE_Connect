//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\modules\staff\controllers\staff_student_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';

class StaffStudentController extends GetxController {
  var isLoading = false.obs;
  var pendingList = [].obs;

  // Directory Variables
  var studentList = [].obs;
  var filteredStudents = [].obs;

  // 1. Pending List
  void fetchPendingUsers() async {
    isLoading.value = true;
    try {
      var response = await http.get(Uri.parse(ApiConstants.pendingUsersEndpoint));
      if (response.statusCode == 200) {
        pendingList.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar("Error", "Could not fetch requests");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Approve User
  void approveUser(int id) async {
    try {
      var response = await http.post(
        Uri.parse(ApiConstants.approveUserEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );
      if (response.statusCode == 200) {
        Get.snackbar("Success", "User Approved!", backgroundColor: Colors.green, colorText: Colors.white);
        fetchPendingUsers();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to approve");
    }
  }

  // 3. Directory & Search
  void fetchAllStudents() async {
    isLoading(true);
    try {
      var response = await http.get(Uri.parse(ApiConstants.allStudentsEndpoint));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List;
        studentList.value = data;
        filteredStudents.value = data;
      }
    } catch (e) {
      Get.snackbar("Error", "Could not fetch students");
    } finally {
      isLoading(false);
    }
  }

  void filterStudents(String query) {
    if (query.isEmpty) {
      filteredStudents.value = studentList;
    } else {
      filteredStudents.value = studentList.where((student) {
        return student['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
            student['student_id'].toString().contains(query);
      }).toList();
    }
  }
}