//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\modules\staff\upload_result_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'staff_controller.dart';

class UploadResultScreen extends StatelessWidget {
  final StaffController controller = Get.put(StaffController());

  UploadResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Student Result"), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Student ID
            _buildTextField(controller.stdIdCtrl, "Student ID / Roll (e.g. 202055)", Icons.badge),

            // 2. Semester
            _buildDropdown("Select Semester", controller.resultSemester, [
              '1st Year 1st Sem', '1st Year 2nd Sem',
              '2nd Year 1st Sem', '2nd Year 2nd Sem',
              '3rd Year 1st Sem', '3rd Year 2nd Sem',
              '4th Year 1st Sem', '4th Year 2nd Sem',
            ]),

            // 3. Course Details
            _buildTextField(controller.courseCodeResultCtrl, "Course Code (e.g. CSE-201)", Icons.book),

            // 4. GPA & Grade (Row)
            Row(
              children: [
                Expanded(child: _buildTextField(controller.gpaCtrl, "GPA (e.g. 3.75)", Icons.numbers, isNumber: true)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(controller.gradeCtrl, "Grade (e.g. A-)", Icons.grade)),
              ],
            ),

            // 5. Exam Year
            _buildTextField(controller.examYearCtrl, "Exam Year (e.g. 2024)", Icons.calendar_today, isNumber: true),

            const SizedBox(height: 30),

            // 6. Submit Button
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

  Widget _buildDropdown(String title, RxString value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.value,
              isExpanded: true,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => value.value = val!,
            ),
          )),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}