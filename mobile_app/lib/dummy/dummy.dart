import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';

class StaffResultController extends GetxController {
  var isLoading = false.obs;

  // ⚡ Auto-fill এর জন্য সব কোর্সের লিস্ট এখানে থাকবে
  var allCourses = <dynamic>[];
  var isCodeTyped = false.obs;

  // Upload Form Controllers
  final stdIdCtrl = TextEditingController();
  final courseCodeResultCtrl = TextEditingController();
  final gpaCtrl = TextEditingController();
  final gradeCtrl = TextEditingController();
  final examYearCtrl = TextEditingController();
  var resultSemester = '1st Year 1st Sem'.obs;

  // Detail View Variable (রেজাল্ট লিস্ট রাখার জন্য)
  var selectedStudentResults = [].obs;

  @override
  void onInit() {
    fetchCoursesForAutoFill(); // ১. পেজে ঢুকেই কোর্স লিস্ট মুখস্থ করে নেবে
    super.onInit();
  }

  // 📥 ব্যাকগ্রাউন্ডে সব কোর্স লোড করা (Auto-fill এর জন্য)
  void fetchCoursesForAutoFill() async {
    try {
      // আগের Course API টাই ব্যবহার করছি
      var response = await http.get(Uri.parse("${ApiConstants.baseUrl}/courses"));
      if (response.statusCode == 200) {
        allCourses = jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Auto-fill data fetch failed");
      }
    }
  }

  // 🪄 জাদুর ফাংশন (Auto-fill Logic)
  void onCourseCodeChanged(String code) {
    isCodeTyped.value = code.isNotEmpty;
    // ইউজার যা টাইপ করছে, সেটা দিয়ে লিস্টে খুঁজব
    var matchedCourse = allCourses.firstWhere(
          (course) => course['course_code'].toString().toLowerCase() == code.trim().toLowerCase(),
      orElse: () => null,
    );

    if (matchedCourse != null) {
      // ম্যাচ পেলে সেমিস্টার অটো বসিয়ে দেব
      resultSemester.value = matchedCourse['semester'];

      Get.snackbar(
          "Matched!",
          "Semester set to: ${matchedCourse['semester']} ✨",
          backgroundColor: Colors.teal.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10)
      );
    }
  }

  // 1. Upload Result
  void uploadResult() async {
    if (stdIdCtrl.text.isEmpty || courseCodeResultCtrl.text.isEmpty || gpaCtrl.text.isEmpty || gradeCtrl.text.isEmpty || examYearCtrl.text.isEmpty) {
      Get.snackbar("Required", "All fields are required!", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      var response = await http.post(
        Uri.parse(ApiConstants.addResultEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student_id_no": stdIdCtrl.text.trim(),
          "semester": resultSemester.value,
          "course_code": courseCodeResultCtrl.text.trim(),
          "gpa": double.parse(gpaCtrl.text.trim()),
          "grade": gradeCtrl.text.trim(),
          "exam_year": int.parse(examYearCtrl.text.trim()),
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success! 🎓", "Result Uploaded", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
        // Clear fields
        stdIdCtrl.clear();
        courseCodeResultCtrl.clear();
        gpaCtrl.clear();
        gradeCtrl.clear();
        isCodeTyped.value = false;

        Get.back();
      } else {
        var error = jsonDecode(response.body); // এরর মেসেজ হ্যান্ডেল করা হলো
        Get.snackbar("Failed", error['error'] ?? "Upload failed", backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Check inputs or internet", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Fetch Single Student Results
  void fetchStudentResults(String email) async {
    try {
      isLoading(true);
      var response = await http.post(
        Uri.parse(ApiConstants.resultEndpoint),
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

  // 3. Delete Result
  void deleteResultAPI(int id, String studentEmail) {
    Get.defaultDialog(
        title: "Delete Result?",
        middleText: "This cannot be undone.",
        textConfirm: "Yes, Delete",
        textCancel: "Cancel",
        confirmTextColor: Colors.white,
        onConfirm: () async {
          Get.back();
          try {
            var response = await http.delete(Uri.parse("${ApiConstants.resultEndpoint}/$id"));
            if (response.statusCode == 200) {
              Get.snackbar("Deleted", "Result removed");
              fetchStudentResults(studentEmail);
            }
          } catch (e) {
            Get.snackbar("Error", "Failed to delete");
          }
        }
    );
  }

  // 4. Edit Result Dialog (Updated & Fixed)
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

                  TextField(
                      controller: codeCtrl,
                      decoration: const InputDecoration(labelText: "Course Code", border: OutlineInputBorder())
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                              controller: gpaCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "GPA", border: OutlineInputBorder())
                          )
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: TextField(
                              controller: gradeCtrl,
                              decoration: const InputDecoration(labelText: "Grade", border: OutlineInputBorder())
                          )
                      ),
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
                            Get.back(); // ডায়ালগ বন্ধ

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
                                Get.snackbar("Success", "Result Updated Successfully ✅", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                                fetchStudentResults(studentEmail); // রিফ্রেশ
                              } else {
                                Get.snackbar("Error", "Update Failed");
                              }
                            } catch (e) {
                              Get.snackbar("Error", "Check input formatting");
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