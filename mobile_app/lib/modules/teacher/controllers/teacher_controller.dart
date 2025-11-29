import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // 📅 Date formatting (Package ta na thakle add koro)
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';

class TeacherController extends GetxController {
  var isLoading = true.obs;

  // 📁 Data Lists (এই ভেরিয়েবলগুলো মিসিং ছিল)
  var myClasses = [].obs;        // All classes (Raw)
  var allClasses = [].obs;       // All classes (For UI check)
  var tomorrowClasses = [].obs;  // Shudhu agamikaler class
  var groupedClasses = <String, List<dynamic>>{}.obs; // Semester wise class

  var teacherList = [].obs;

  @override
  void onInit() {
    fetchTeachers();
    fetchMyClasses();
    super.onInit();
  }

  void fetchTeachers() async {
    try {
      var response = await http.get(Uri.parse(ApiConstants.teacherEndpoint));
      if (response.statusCode == 200) {
        teacherList.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar("Error", "Could not fetch teacher list");
    }
  }

  // 📥 Class Fetch Logic (Updated)
  void fetchMyClasses() async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      if (userId == null) return;

      var response = await http.get(Uri.parse("${ApiConstants.baseUrl}/routines/teacher/$userId"));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List;

        myClasses.value = data;
        allClasses.value = data; // ⚠️ UI তে এই ভেরিয়েবলটাই চেক করা হচ্ছে

        // 🧠 Smart Filtering Call
        _filterClasses(data);
      }
    } catch (e) {
      Get.snackbar("Error", "Could not fetch your classes");
    } finally {
      isLoading(false);
    }
  }

  // 🪄 Filtering Logic
  void _filterClasses(List data) {
    // 1. Agamikal ki bar? (e.g., "Sunday")
    var tomorrowDate = DateTime.now().add(const Duration(days: 1));
    String tomorrowName = DateFormat('EEEE').format(tomorrowDate);

    var tList = [];
    var otherList = [];

    for (var item in data) {
      // Database er 'day' er sathe match kora
      if (item['day'].toString().trim() == tomorrowName) {
        tList.add(item);
      } else {
        otherList.add(item);
      }
    }

    tomorrowClasses.value = tList;

    // 2. Baki class gulo Semester onujayi Group kora
    Map<String, List<dynamic>> grouped = {};
    for (var item in otherList) {
      String sem = item['semester'] ?? "Unknown";
      if (!grouped.containsKey(sem)) {
        grouped[sem] = [];
      }
      grouped[sem]!.add(item);
    }

    // Sort keys (Optional)
    groupedClasses.value = Map.fromEntries(
        grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
  }

  // 🔴 Toggle Status
  void toggleClassStatus(int id) async {
    try {
      var response = await http.post(
        Uri.parse(ApiConstants.cancelClassEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Class status updated!");
        fetchMyClasses(); // List refresh
      }
    } catch (e) {
      Get.snackbar("Error", "Connection Error");
    }
  }
}