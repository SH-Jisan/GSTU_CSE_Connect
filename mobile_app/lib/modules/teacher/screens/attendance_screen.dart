import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';

class AttendanceScreen extends StatelessWidget {
  final AttendanceController controller = Get.put(AttendanceController());

  AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Take Attendance"), backgroundColor: Colors.teal),

      // সাবমিট বাটন (শুধুমাত্র যদি ক্লাস পাওয়া যায়)
      bottomNavigationBar: Obx(() => controller.isClassFound.value
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => controller.submitAttendance(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: const Text("Submit Attendance", style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      )
          : const SizedBox()),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // ক্লাস না পাওয়া গেলে মেসেজ
        if (!controller.isClassFound.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_busy, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                Text(
                  controller.statusMessage.value,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.checkCurrentClass(),
                  child: const Text("Refresh / Check Again"),
                )
              ],
            ),
          );
        }

        // ক্লাস পাওয়া গেলে লিস্ট
        return Column(
          children: [
            // ক্লাস হেডার
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.teal.withOpacity(0.1),
              width: double.infinity,
              child: Column(
                children: [
                  Text(controller.activeClass['course_title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)),
                  Text("${controller.activeClass['course_code']} | Room: ${controller.activeClass['room_no']}"),
                  Text(controller.activeClass['semester'], style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const Divider(height: 1),

            // স্টুডেন্ট লিস্ট
            Expanded(
              child: ListView.builder(
                itemCount: controller.studentList.length,
                itemBuilder: (context, index) {
                  var student = controller.studentList[index];
                  int id = student['id'];
                  bool isPresent = controller.attendanceMap[id] == 'Present';

                  return Card(
                    color: isPresent ? Colors.white : Colors.red[50], // এবসেন্ট হলে লাল
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isPresent ? Colors.teal : Colors.red,
                        child: Text(
                            student['name'][0],
                            style: const TextStyle(color: Colors.white)
                        ),
                      ),
                      title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("ID: ${student['student_id']}"),

                      // চেকবক্স
                      trailing: Checkbox(
                        value: isPresent,
                        activeColor: Colors.teal,
                        onChanged: (val) => controller.toggleAttendance(id),
                      ),
                      onTap: () => controller.toggleAttendance(id),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}