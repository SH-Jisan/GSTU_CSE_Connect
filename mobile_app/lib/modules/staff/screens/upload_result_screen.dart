import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/staff_result_controller.dart';

class UploadResultScreen extends StatelessWidget {
  final StaffResultController controller = Get.put(StaffResultController());

  UploadResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Student Result"), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Student ID
            _buildTextField(controller.stdIdCtrl, "Student ID / Roll (e.g. 202055)", Icons.badge),

            // 2. Course Code (Main Auto-fill Input)
            TextField(
              controller: controller.courseCodeResultCtrl,
              onChanged: (value) => controller.onCourseCodeChanged(value),
              decoration: const InputDecoration(
                labelText: "Course Code",
                hintText: "e.g. CSE-201",
                prefixIcon: Icon(Icons.book, color: Colors.teal),
                suffixIcon: Icon(Icons.flash_on, color: Colors.teal),
                border: OutlineInputBorder(),
              ),
            ),

            // 🪄 Magic Info Display (সেমিস্টার কনফার্মেশন)
            Obx(() {
              // ⚠️ আমরা এখানে .value চেক করছি, যা একটি Observable
              if (controller.isCodeTyped.value && controller.resultSemester.value.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.teal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Auto-Selected: ${controller.resultSemester.value}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                );
              }
              // যদি কন্ডিশন না মেলে, খালি উইজেট রিটার্ন করো
              return const SizedBox(height: 20);
            }),

            // 3. GPA & Grade (Row)
            Row(
              children: [
                Expanded(child: _buildTextField(controller.gpaCtrl, "GPA (e.g. 3.75)", Icons.numbers, isNumber: true)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(controller.gradeCtrl, "Grade (e.g. A-)", Icons.grade)),
              ],
            ),

            const SizedBox(height: 5),

            // 4. Exam Year
            _buildTextField(controller.examYearCtrl, "Exam Year (e.g. 2024)", Icons.calendar_today, isNumber: true),

            const SizedBox(height: 30),

            // 5. Submit Button
            SizedBox(
              width: double.infinity,
              child: Obx(() => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: () => controller.uploadResult(),
                icon: const Icon(Icons.upload, color: Colors.white),
                label: const Text("Upload Result", style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              )
              ),
            )
          ],
        ),
      ),
    );
  }

  // হেল্পার উইজেট
  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}