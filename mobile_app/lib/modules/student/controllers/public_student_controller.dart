import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart'; // kDebugMode
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';

class PublicStudentController extends GetxController {
  var isLoading = false.obs;
  var allStudents = [].obs;
  var filteredStudents = [].obs;

  @override
  void onInit() {
    fetchStudents();
    super.onInit();
  }

  // 📥 সব স্টুডেন্ট ডাটা আনা
  void fetchStudents() async {
    try {
      isLoading(true);
      // আমরা আগের staff endpoint টাই রিইউজ করছি (কারণ ডাটা একই)
      var response = await http.get(Uri.parse(ApiConstants.allStudentsEndpoint));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List;
        // 🕵️ DEBUG PRINT: প্রথম স্টুডেন্টের ডাটা চেক করা
        if (kDebugMode && data.isNotEmpty) {
          print("🔍 Sample Student Data from API: ${data[0]}");
          print("🔍 Checking 'current_year': ${data[0]['current_year']}");
          print("🔍 Checking 'current_semester': ${data[0]['current_semester']}");
        }
        allStudents.value = data;
        filteredStudents.value = data;
      }
    } catch (e) {
      print("Error fetching students: $e");
    } finally {
      isLoading(false);
    }
  }

  // 🔍 সার্চ লজিক
  void filterList(String query) {
    if (query.isEmpty) {
      filteredStudents.value = allStudents;
    } else {
      filteredStudents.value = allStudents.where((student) {
        var name = student['name'].toString().toLowerCase();
        var id = student['student_id'].toString();
        return name.contains(query.toLowerCase()) || id.contains(query);
      }).toList();
    }
  }

  // 📂 গ্রুপিং লজিক (Magic Part)
  // আউটপুট হবে এমন: {'1st Year 1st Sem': [List], 'Graduated': [List]}
  Map<String, List<dynamic>> get groupedStudents {
    Map<String, List<dynamic>> grouped = {};

    for (var student in filteredStudents) {
      String groupName;

      if (student['current_year'] == 'Graduated') {
        groupName = "🎓 Graduated / Alumni";
      } else {
        // যদি ডাটা না থাকে তবে 'Unknown'
        String year = student['current_year'] ?? "Unknown";
        String sem = student['current_semester'] ?? "";

        // Trim kore dekhi
        String fullTitle = "$year $sem".trim();

        // Jodi Trim korar poreo empty ba just 'Unknown' hoy
        if(fullTitle.isEmpty || fullTitle == "Unknown") {
          groupName = "Unknown Year/Semester";
        } else {
          groupName = fullTitle;
        }      }

      if (!grouped.containsKey(groupName)) {
        grouped[groupName] = [];
      }
      grouped[groupName]!.add(student);
    }

    // কি-গুলো (Semester Name) সর্ট করা যেতে পারে, আপাতত ডিফল্ট অর্ডারে রাখছি
    return grouped;
  }
}