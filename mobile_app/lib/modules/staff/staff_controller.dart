import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // টেক্সট কন্ট্রোলারের জন্য
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../home/home_controller.dart';

class StaffController extends GetxController {
  var pendingList = [].obs;

  // ⚠️ ফিক্স ১: এটাকে 'false' করে দাও (আগে true ছিল)
  var isLoading = false.obs;

  // টেক্সট কন্ট্রোলার (নোটিসের জন্য)
  final titleController = TextEditingController();
  final descController = TextEditingController();
  var selectedCategory = 'General'.obs;

  // Routine Form Controllers
  final courseCodeCtrl = TextEditingController();
  final courseTitleCtrl = TextEditingController();
  final teacherEmailCtrl = TextEditingController();
  final roomCtrl = TextEditingController();

  var selectedSemester = '1st Year 1st Sem'.obs;
  var selectedDay = 'Sunday'.obs;

  // somoy rakhar jnno
  var startTime = TimeOfDay(hour:10, minute: 0).obs;
  var endTime = TimeOfDay(hour: 11, minute: 30).obs;

  //result form controllers
  final stdIdCtrl = TextEditingController();
  final courseCodeResultCtrl = TextEditingController();
  final gpaCtrl = TextEditingController();
  final examYearCtrl = TextEditingController();
  final gradeCtrl = TextEditingController();
  var resultSemester = '1st Year 1st Sem'.obs;
  var studentList = [].obs;     // সব স্টুডেন্টের লিস্ট
  var filteredStudents = [].obs; // সার্চ করার পর যেটা থাকবে
  // ... ক্লাসের ভেরিয়েবল সেকশনে ...
  var selectedStudentResults = [].obs; // সিলেক্ট করা স্টুডেন্টের রেজাল্ট



  // result upload function
  // 🎓 Rezult Upload Function (Updated)
  void uploadResult() async {
    // 1. Validation
    if (stdIdCtrl.text.isEmpty || courseCodeResultCtrl.text.isEmpty || gpaCtrl.text.isEmpty || gradeCtrl.text.isEmpty || examYearCtrl.text.isEmpty) {
      Get.snackbar(
        "Required",
        "All fields are required!",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Data Parsing
      String studentId = stdIdCtrl.text.trim();
      String courseCode = courseCodeResultCtrl.text.trim();
      String grade = gradeCtrl.text.trim();
      double gpa = double.parse(gpaCtrl.text.trim());
      int year = int.parse(examYearCtrl.text.trim());

      var response = await http.post(
        Uri.parse(ApiConstants.addResultEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student_id_no": studentId,
          "semester": resultSemester.value,
          "course_code": courseCode,
          "gpa": gpa,
          "grade": grade,
          "exam_year": year,
        }),
      );

      if (response.statusCode == 200) {
        // ✅ Success Notification
        Get.snackbar(
          "Success! 🎓",
          "Result Uploaded Successfully",
          backgroundColor: Colors.green, // Sobuj background
          colorText: Colors.white,       // Sada lekha
          snackPosition: SnackPosition.BOTTOM, // Niche dekhabe
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2), // 2 second thakbe
        );

        // Field Clear kora
        stdIdCtrl.clear();
        courseCodeResultCtrl.clear();
        gpaCtrl.clear();
        gradeCtrl.clear();
        examYearCtrl.clear();

        // Ektu wait kore page bondho hobe jate user message ta porte pare
        await Future.delayed(const Duration(seconds: 1));
        Get.back();

      } else {
        var error = jsonDecode(response.body);
        Get.snackbar(
          "Failed ⚠️",
          error['error'] ?? "Upload failed",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
      Get.snackbar(
        "Error ❌",
        "Check inputs (GPA must be number) or Internet.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  //time picker function
  Future<void> pickTime(BuildContext context , bool isStart) async{
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime.value : endTime.value,
    );
    if(picked != null){
      if(isStart) {
        startTime.value = picked;
      } else {
        endTime.value = picked;
      }
    }
  }

  // routine add korar function
  void addClassRoutine() async{
    if(courseCodeCtrl.text.isEmpty || teacherEmailCtrl.text.isEmpty){
      Get.snackbar("Error" , "Please fill all fields",
        backgroundColor: Color.fromARGB(155, 246, 6, 15),
        colorText: Colors.white,
      );
      return;
    }
    try{
      isLoading.value = true;

      // time format kora (10:00 Am style pathano)
      String startStr = "${startTime.value.hour}:${startTime.value.minute}";
      String endStr = "${endTime.value.hour}:${endTime.value.minute}";

      var response = await http.post(
        Uri.parse(ApiConstants.addRoutineEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "semester": selectedSemester.value,
          "course_code": courseCodeCtrl.text,
          "course_title": courseTitleCtrl.text,
          "teacher_email": teacherEmailCtrl.text.trim(), // টিচারের ইমেইল
          "room_no": roomCtrl.text,
          "day": selectedDay.value,
          "start_time": startStr,
          "end_time": endStr,
        }),
      );
      if(response.statusCode == 200){
        Get.snackbar("Success", "Class Added to Routine!",
          backgroundColor: Color.fromARGB(174, 9, 228, 17),
          colorText: Colors.white,
        );
        courseCodeCtrl.clear();
        courseTitleCtrl.clear();
        roomCtrl.clear();
        Get.back();
      }
      else{
        var error = jsonDecode(response.body);
        Get.snackbar("Failed", error['error'] ?? "Something went wrong",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }
    catch(e){
      Get.snackbar("Error", "Check internet connection");
    }
    finally{
      isLoading.value = false;
    }
  }

  // পেন্ডিং লিস্ট লোড করা
  void fetchPendingUsers() async {
    // ⚠️ ফিক্স ২: ডাটা আনা শুরু করার সময় লোডিং অন করো
    isLoading.value = true;

    try {
      var response = await http.get(Uri.parse(ApiConstants.pendingUsersEndpoint));
      if (response.statusCode == 200) {
        pendingList.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar("Error", "Could not fetch requests");
    } finally {
      isLoading.value = false; // কাজ শেষ, লোডিং বন্ধ
    }
  }

  // অ্যাপ্রুভ করা
  void approveUser(int id) async {
    try {
      var response = await http.post(
        Uri.parse(ApiConstants.approveUserEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );
      if (response.statusCode == 200) {
        Get.snackbar("Success", "User Approved!");
        fetchPendingUsers();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to approve");
    }
  }

// 📢 নোটিস পোস্ট করার ফাংশন (Updated)
  void postNotice() async {
    // ১. ভ্যালিডেশন: খালি থাকলে ওয়ার্নিং দেবে
    if (titleController.text.isEmpty || descController.text.isEmpty) {
      Get.snackbar(
        "Required",
        "Title and Description cannot be empty!",
        snackPosition: SnackPosition.BOTTOM, // নিচে দেখাবে
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
      return;
    }

    try {
      isLoading.value = true; // লোডিং শুরু

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

      // ২. সফল হলে (Success Notification)
      if (response.statusCode == 200) {
        Get.snackbar(
          "Success! 🎉",
          "Notice Posted Successfully",
          snackPosition: SnackPosition.BOTTOM, // নিচে দেখাবে
          backgroundColor: Colors.green, // সবুজ ব্যাকগ্রাউন্ড
          colorText: Colors.white,       // সাদা লেখা
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        );

        if(Get.isRegistered<HomeController>()){
          Get.find<HomeController>().fetchNotices();
        }
        else{
          Get.put(HomeController()).fetchNotices();
        }

        titleController.clear();
        descController.clear();

        // ১ সেকেন্ড অপেক্ষা করে পেজ বন্ধ হবে (যাতে নোটিফিকেশন পড়ার সময় পায়)
        await Future.delayed(const Duration(seconds: 1));
        Get.back();
      }
      // ৩. সার্ভার এরর হলে (Failed Notification)
      else {
        Get.snackbar(
          "Failed ⚠️",
          "Could not post notice. Server Error.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
        );
      }
    } catch (e) {
      // ৪. ইন্টারনেট বা অন্য এরর হলে
      Get.snackbar(
        "Error ❌",
        "Check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      isLoading.value = false; // লোডিং শেষ
    }
  }

  // 📋 সব স্টুডেন্ট লোড করা
  void fetchAllStudents() async {
    isLoading(true);
    try {
      var response = await http.get(Uri.parse(ApiConstants.allStudentsEndpoint));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List;
        studentList.value = data;
        filteredStudents.value = data; // শুরুতে সব দেখাবে
      }
    } catch (e) {
      Get.snackbar("Error", "Could not fetch students");
    } finally {
      isLoading(false);
    }
  }

  // 🔍 সার্চ ফাংশন
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

  // 🗑️ রেজাল্ট ডিলিট ফাংশন
  Future<bool> deleteResult(int id) async {
    try {
      var response = await http.delete(Uri.parse("${ApiConstants.resultEndpoint}/$id"));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 📥 নির্দিষ্ট স্টুডেন্টের রেজাল্ট আনা
  void fetchStudentResults(String email) async {
    try {
      isLoading(true);
      var response = await http.post(
        Uri.parse(ApiConstants.resultEndpoint), // আগের রেজাল্ট দেখার API-ই ব্যবহার করব
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        selectedStudentResults.value = jsonDecode(response.body);
      } else {
        selectedStudentResults.clear();
      }
    } catch (e) {
      Get.snackbar("Error", "Could not fetch results");
    } finally {
      isLoading(false);
    }
  }

  // 🗑️ রেজাল্ট ডিলিট ফাংশন
  void deleteResultAPI(int id, String studentEmail) async {
    Get.defaultDialog(
        title: "Delete Result?",
        middleText: "Are you sure? This cannot be undone.",
        textConfirm: "Yes, Delete",
        textCancel: "Cancel",
        confirmTextColor: Colors.white,
        onConfirm: () async {
          Get.back(); // ডায়ালগ বন্ধ
          try {
            var response = await http.delete(Uri.parse("${ApiConstants.resultEndpoint}/$id"));
            if (response.statusCode == 200) {
              Get.snackbar("Deleted", "Result removed successfully");
              fetchStudentResults(studentEmail); // লিস্ট রিফ্রেশ
            }
          } catch (e) {
            Get.snackbar("Error", "Failed to delete");
          }
        }
    );
  }

  // ✏️ রেজাল্ট এডিট ডায়ালগ
  void showEditResultDialog(Map result, String studentEmail) {
    final codeCtrl = TextEditingController(text: result['course_code']);
    final gpaCtrl = TextEditingController(text: result['gpa'].toString());
    final gradeCtrl = TextEditingController(text: result['grade']);

    Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Update Result", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const SizedBox(height: 20),
                  TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: "Course Code", border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: gpaCtrl, decoration: const InputDecoration(labelText: "GPA", border: OutlineInputBorder()))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: gradeCtrl, decoration: const InputDecoration(labelText: "Grade", border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: const Text("Cancel"))),
                      const SizedBox(width: 10),
                      Expanded(child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                          onPressed: () async {
                            Get.back();
                            // API Call
                            try {
                              var response = await http.put(
                                Uri.parse("${ApiConstants.resultEndpoint}/${result['id']}"),
                                headers: {"Content-Type": "application/json"},
                                body: jsonEncode({
                                  "course_code": codeCtrl.text,
                                  "gpa": double.parse(gpaCtrl.text),
                                  "grade": gradeCtrl.text
                                }),
                              );
                              if (response.statusCode == 200) {
                                Get.snackbar("Success", "Result Updated");
                                fetchStudentResults(studentEmail); // রিফ্রেশ
                              }
                            } catch (e) {
                              Get.snackbar("Error", "Update Failed");
                            }
                          },
                          child: const Text("Update", style: TextStyle(color: Colors.white))
                      )),
                    ],
                  )
                ],
              ),
            ),
          ),
        )
    );
  }
}