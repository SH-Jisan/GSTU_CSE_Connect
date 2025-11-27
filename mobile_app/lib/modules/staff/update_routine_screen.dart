//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\modules\staff\update_routine_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'staff_controller.dart';

class UpdateRoutineScreen extends StatelessWidget {
  final StaffController controller = Get.put(StaffController());

  UpdateRoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Class"), backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Semester Dropdown
            _buildDropdown("Select Semester", controller.selectedSemester, [
              '1st Year 1st Sem', '1st Year 2nd Sem',
              '2nd Year 1st Sem', '2nd Year 2nd Sem',
              '3rd Year 1st Sem', '3rd Year 2nd Sem',
              '4th Year 1st Sem', '4th Year 2nd Sem',
            ]),

            // 2. Day Dropdown
            _buildDropdown("Select Day", controller.selectedDay, [
              'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday'
            ]),

            const SizedBox(height: 10),

            // 3. Text Fields
            _buildTextField(controller.courseCodeCtrl, "Course Code (e.g. CSE-101)"),
            _buildTextField(controller.courseTitleCtrl, "Course Title (e.g. C Programming)"),
            _buildTextField(controller.teacherEmailCtrl, "Teacher Email (e.g. tanvir@gstucse.com)"),
            _buildTextField(controller.roomCtrl, "Room No (e.g. 302)"),

            const SizedBox(height: 20),

            // 4. Time Pickers
            Row(
              children: [
                Expanded(child: _buildTimePicker(context, "Start Time", controller.startTime, true)),
                const SizedBox(width: 10),
                Expanded(child: _buildTimePicker(context, "End Time", controller.endTime, false)),
              ],
            ),

            const SizedBox(height: 30),

            // 5. Submit Button
            SizedBox(
              width: double.infinity,
              child: Obx(() => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: () => controller.addClassRoutine(),
                icon: const Icon(Icons.add_circle, color: Colors.white),
                label: const Text("Add to Routine", style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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

  // হেল্পার উইজেট: ড্রপডাউন
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

  // হেল্পার উইজেট: টেক্সট ফিল্ড
  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // হেল্পার উইজেট: টাইম পিকার বাটন
  Widget _buildTimePicker(BuildContext context, String title, Rx<TimeOfDay> time, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        InkWell(
          onTap: () => controller.pickTime(context, isStart),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: Obx(() => Text(
                "${time.value.format(context)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )),
            ),
          ),
        ),
      ],
    );
  }
}