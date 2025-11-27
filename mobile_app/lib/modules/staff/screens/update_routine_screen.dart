import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/staff_routine_controller.dart';

class UpdateRoutineScreen extends StatelessWidget {
  final StaffRoutineController controller = Get.put(StaffRoutineController());

  UpdateRoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Class"), backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Day Dropdown (এটা রাখা দরকার)
            _buildDropdown("Select Day", controller.selectedDay, [
              'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday'
            ]),

            const SizedBox(height: 15),

            // 2. Course Code (The Main Input)
            TextField(
              controller: controller.courseCodeCtrl,
              onChanged: (value) => controller.onCourseCodeChanged(value),
              decoration: const InputDecoration(
                labelText: "Course Code",
                hintText: "e.g. CSE-101",
                prefixIcon: Icon(Icons.qr_code, color: Colors.orange),
                suffixIcon: Icon(Icons.flash_on, color: Colors.orange),
                border: OutlineInputBorder(),
              ),
            ),

            // 🪄 Magic Info Display (অটো-ফিল কনফার্মেশন)
            Obx(() {
              if (controller.courseTitleCtrl.text.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Matched Course:", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(
                          "${controller.courseTitleCtrl.text}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
                      ),
                      Text(
                          "Semester: ${controller.selectedSemester.value}",
                          style: const TextStyle(fontSize: 14, color: Colors.deepOrange)
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            }),

            const SizedBox(height: 20),

            // 3. Other Fields
            _buildTextField(controller.teacherEmailCtrl, "Teacher Email", Icons.email),
            _buildTextField(controller.roomCtrl, "Room No", Icons.room),

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

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
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
      ],
    );
  }

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
                time.value.format(context),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )),
            ),
          ),
        ),
      ],
    );
  }
}